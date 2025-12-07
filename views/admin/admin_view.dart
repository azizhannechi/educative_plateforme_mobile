import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/views/admin/creer_cour_admin.dart';
import 'statistics_view.dart';
import 'user_detail_view.dart';
import '../../controllers/auth_controller.dart';

class AdminView extends StatefulWidget {
  const AdminView({Key? key}) : super(key: key);

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final AuthController _authController = AuthController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // ==========================
          //          SIDEBAR
          // ==========================
          _buildSidebar(),

          // ==========================
          //      MAIN CONTENT
          // ==========================
          Expanded(
            child: Column(
              children: [
                _buildSearchBar(),
                Expanded(child: _buildUserGrid()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------
  //                          SIDEBAR
  // --------------------------------------------------------------
  Widget _buildSidebar() {
    return Container(
      width: 200,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/image/logo_studyhub.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _logout,
                  child: Column(
                    children: const [
                      Text('Admin', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        'déconnexion',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                Icon(Icons.school, size: 30),
                SizedBox(height: 8),
                Text(
                  'Liste des étudiants',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5),
                Text(
                  'Tous les étudiants\ninscrits dans la plateforme',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          const Spacer(),

          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistiques'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsView()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Créer cours'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EspaceAdminCours()),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --------------------------------------------------------------
  //                          SEARCH BAR
  // --------------------------------------------------------------
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un étudiant...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(width: 10),

          // Nombre d'étudiants
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _authController.getUsers(),
            builder: (context, snapshot) {
              final count = snapshot.hasData ? snapshot.data!.length : 0;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count étudiants',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------
  //                     GRID OF USERS
  // --------------------------------------------------------------
  Widget _buildUserGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _authController.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Erreur de chargement', style: TextStyle(color: Colors.red)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun étudiant inscrit'));
          }

          List<Map<String, dynamic>> users = snapshot.data!;

          // 🔥 Filtre recherche
          users = users.where((user) {
            final nom = (user['nom'] ?? '').toString().toLowerCase();
            final prenom = (user['prenom'] ?? '').toString().toLowerCase();
            final email = (user['email'] ?? '').toString().toLowerCase();

            return nom.contains(_searchQuery) ||
                prenom.contains(_searchQuery) ||
                email.contains(_searchQuery);
          }).toList();

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) {
              return _buildUserCard(users[index]);
            },
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------
  //                        USER CARD
  // --------------------------------------------------------------
  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailView(user: user),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                user['userType'] ?? 'Étudiant',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 30, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),

              Text('ID (UID)', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              Text(
                user['uid']?.substring(0, 8) ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Text('Nom', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(user['nom'] ?? 'Non renseigné'),

              const SizedBox(height: 4),
              Text('Prénom', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(user['prenom'] ?? 'Non renseigné'),

              const SizedBox(height: 4),
              Text('Email', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(
                user['email'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  //                          LOGOUT
  // --------------------------------------------------------------
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
