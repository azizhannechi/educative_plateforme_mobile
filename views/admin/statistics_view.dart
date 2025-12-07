import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({Key? key}) : super(key: key);

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _totalUsers = 0;
  int _totalCourses = 0;
  int _publishedCourses = 0;
  int _adminCourses = 0;
  int _newUsersThisMonth = 0;
  bool _isLoading = true;

  Map<String, int> _levelStats = {};
  Map<String, int> _establishmentStats = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  // Emails admin à exclure
  final List<String> _adminEmails = [
    'admin@studyhub.com',
    'administrateur@studyhub.com',
    'superadmin@studyhub.com'
  ];

  bool _isAdminEmail(String email) {
    return _adminEmails.contains(email.toLowerCase());
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      // ==========================================
      // 1. STATISTIQUES DES UTILISATEURS
      // ==========================================
      final usersSnapshot = await _firestore.collection('users').get();

      // Filtrer les étudiants (exclure les admins)
      final students = usersSnapshot.docs.where((doc) {
        final email = doc.data()['email'] ?? '';
        return !_isAdminEmail(email);
      }).toList();

      _totalUsers = students.length;

      // Nouveaux utilisateurs ce mois
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      _newUsersThisMonth = students.where((doc) {
        final createdAt = doc.data()['createdAt'] as Timestamp?;
        if (createdAt != null) {
          return createdAt.toDate().isAfter(firstDayOfMonth);
        }
        return false;
      }).length;

      // Répartition par niveau
      _levelStats.clear();
      for (var doc in students) {
        final niveau = doc.data()['niveau'] ?? 'Non renseigné';
        _levelStats[niveau] = (_levelStats[niveau] ?? 0) + 1;
      }

      // Répartition par établissement
      _establishmentStats.clear();
      for (var doc in students) {
        final etablissement = doc.data()['etablissement'] ?? 'Non renseigné';
        _establishmentStats[etablissement] = (_establishmentStats[etablissement] ?? 0) + 1;
      }

      // ==========================================
      // 2. STATISTIQUES DES COURS
      // ==========================================
      final coursesSnapshot = await _firestore.collection('courses').get();
      _totalCourses = coursesSnapshot.docs.length;

      // Cours publiés
      _publishedCourses = coursesSnapshot.docs.where((doc) {
        return doc.data()['status'] == 'published';
      }).length;

      // Cours créés par l'admin actuel
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId != null) {
        _adminCourses = coursesSnapshot.docs.where((doc) {
          return doc.data()['createdBy'] == currentUserId;
        }).length;
      }

    } catch (e) {
      print('Erreur chargement statistiques: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('📊 Statistiques'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadStatistics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // CARTES KPI PRINCIPALES
              // ==========================================
              _buildKPICards(),
              const SizedBox(height: 30),

              // ==========================================
              // STATISTIQUES PAR NIVEAU
              // ==========================================
              _buildSectionTitle('📊 Répartition par niveau'),
              const SizedBox(height: 15),
              _buildLevelStats(),
              const SizedBox(height: 30),

              // ==========================================
              // STATISTIQUES PAR ÉTABLISSEMENT
              // ==========================================
              _buildSectionTitle('🏫 Répartition par établissement'),
              const SizedBox(height: 15),
              _buildEstablishmentStats(),
              const SizedBox(height: 30),

              // ==========================================
              // STATISTIQUES DES COURS
              // ==========================================
              _buildCoursesSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CARTES KPI
  // ==========================================
  Widget _buildKPICards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildKPICard(
          icon: Icons.people,
          title: 'Étudiants inscrits',
          value: '$_totalUsers',
          color: Colors.blue,
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        _buildKPICard(
          icon: Icons.person_add,
          title: 'Nouveaux ce mois',
          value: '$_newUsersThisMonth',
          color: Colors.green,
          gradient: const LinearGradient(
            colors: [Color(0xFF10b981), Color(0xFF059669)],
          ),
        ),
        _buildKPICard(
          icon: Icons.book,
          title: 'Cours créés',
          value: '$_totalCourses',
          color: Colors.orange,
          gradient: const LinearGradient(
            colors: [Color(0xFFF59e0b), Color(0xFFd97706)],
          ),
        ),
        _buildKPICard(
          icon: Icons.publish,
          title: 'Cours publiés',
          value: '$_publishedCourses',
          color: Colors.purple,
          gradient: const LinearGradient(
            colors: [Color(0xFF8b5cf6), Color(0xFF7c3aed)],
          ),
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TITRE DE SECTION
  // ==========================================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1f2937),
      ),
    );
  }

  // ==========================================
  // STATISTIQUES PAR NIVEAU
  // ==========================================
  Widget _buildLevelStats() {
    if (_levelStats.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Aucune donnée disponible'),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: _levelStats.entries.map((entry) {
            final percentage = (_totalUsers > 0)
                ? (entry.value / _totalUsers * 100).toStringAsFixed(1)
                : '0.0';

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${entry.value} ($percentage%)',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _totalUsers > 0 ? entry.value / _totalUsers : 0,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF667eea),
                      ),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ==========================================
  // STATISTIQUES PAR ÉTABLISSEMENT
  // ==========================================
  Widget _buildEstablishmentStats() {
    if (_establishmentStats.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Aucune donnée disponible'),
        ),
      );
    }

    // Trier par nombre décroissant et prendre les 5 premiers
    final sortedEntries = _establishmentStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEstablishments = sortedEntries.take(5);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: topEstablishments.map((entry) {
            final percentage = (_totalUsers > 0)
                ? (entry.value / _totalUsers * 100).toStringAsFixed(1)
                : '0.0';

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${entry.value} ($percentage%)',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _totalUsers > 0 ? entry.value / _totalUsers : 0,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF3b82f6),
                      ),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ==========================================
  // SECTION COURS
  // ==========================================
  Widget _buildCoursesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📚 Statistiques des cours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildCourseStatRow('Total des cours', _totalCourses, Colors.blue),
            const Divider(height: 30),
            _buildCourseStatRow('Cours publiés', _publishedCourses, Colors.green),
            const Divider(height: 30),
            _buildCourseStatRow(
              'Cours en brouillon',
              _totalCourses - _publishedCourses,
              Colors.orange,
            ),
            const Divider(height: 30),
            _buildCourseStatRow('Mes cours créés', _adminCourses, Colors.purple),
            const SizedBox(height: 20),
            if (_totalCourses > 0)
              _buildPublicationRate(),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseStatRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPublicationRate() {
    final rate = (_publishedCourses / _totalCourses * 100).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Taux de publication',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '$rate%',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3b82f6),
            ),
          ),
        ],
      ),
    );
  }
}