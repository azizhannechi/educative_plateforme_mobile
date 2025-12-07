import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/course_controller.dart';
import '../controllers/purchase_controller.dart';
import '../models/course_model.dart';
import '../models/quiz_model.dart';
import '../controllers/quiz_controller.dart';
import 'quiz_page.dart';
import 'detail_cours.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  bool filterTD = false;
  bool filterTP = false;
  bool filterCOUR = true;
  String currentPage = 'Accueil';
  User? currentUser;

  final CourseController _courseController = CourseController();
  final PurchaseController _purchaseController = PurchaseController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Row(
        children: [
          // SIDEBAR GAUCHE
          Container(
            width: 170,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                _getUserInitials(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getUserName(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _logout,
                                  child: const Text(
                                    'déconnexion',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'filtres',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CheckboxListTile(
                  title: const Text('TD', style: TextStyle(fontSize: 12)),
                  value: filterTD,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) {
                    setState(() {
                      filterTD = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('TP', style: TextStyle(fontSize: 12)),
                  value: filterTP,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) {
                    setState(() {
                      filterTP = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('COUR', style: TextStyle(fontSize: 12)),
                  value: filterCOUR,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) {
                    setState(() {
                      filterCOUR = value ?? false;
                    });
                  },
                ),
                const Divider(),

                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.home, size: 20),
                  title: const Text('Accueil', style: TextStyle(fontSize: 13)),
                  dense: true,
                  selected: currentPage == 'Accueil',
                  selectedTileColor: Colors.red.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      currentPage = 'Accueil';
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart, size: 20),
                  title: const Text('Statistiques', style: TextStyle(fontSize: 13)),
                  dense: true,
                  selected: currentPage == 'Statistiques',
                  selectedTileColor: Colors.red.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      currentPage = 'Statistiques';
                    });
                  },
                ),
                const SizedBox(height: 20),

                ListTile(
                  leading: const Icon(Icons.quiz, size: 20), // Nouvelle icône
                  title: const Text('Quiz', style: TextStyle(fontSize: 13)),
                  dense: true,
                  selected: currentPage == 'Quiz',
                  selectedTileColor: Colors.red.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      currentPage = 'Quiz';
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: currentPage == 'Accueil'
                ? _buildAccueilPage()
                : currentPage == 'Statistiques'
                ? _buildStatistiquesPage()
                : currentPage == 'Quiz'
                ? _buildQuizPage() // Nouvelle page
                : _buildAccueilPage(),
          ),
          Container(
            width: 200,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'recommendation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // Méthode pour obtenir le nom de l'utilisateur
  String _getUserName() {
    if (currentUser == null) return 'Étudiant';

    if (currentUser!.displayName != null && currentUser!.displayName!.isNotEmpty) {
      return currentUser!.displayName!;
    }

    if (currentUser!.email != null) {
      return currentUser!.email!.split('@')[0];
    }

    return 'Étudiant';
  }

  // Méthode pour obtenir les initiales
  String _getUserInitials() {
    String name = _getUserName();
    if (name == 'Étudiant') return 'SH';

    List<String> parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }

    return 'SH';
  }

  // Méthode pour la déconnexion
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  // PAGE D'ACCUEIL - Cours depuis Firestore
  Widget _buildAccueilPage() {
    return StreamBuilder<List<Course>>(
      stream: _courseController.listenToPublishedCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            children: [
              // Barre de recherche
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un cours',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              // Message aucun cours
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun cours disponible',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Les cours publiés apparaîtront ici',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        List<Course> allCourses = snapshot.data!;

        // Appliquer les filtres
        List<Course> filteredCourses = allCourses.where((course) {
          if (!filterTD && !filterTP && !filterCOUR) return true;
          if (filterTD && course.type == 'TD') return true;
          if (filterTP && course.type == 'TP') return true;
          if (filterCOUR && course.type == 'COUR') return true;
          return false;
        }).toList();

        return Column(
          children: [
            // Barre de recherche
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un cours',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (value) {
                  setState(() {}); // Refresh pour filtrer
                },
              ),
            ),

            // Bannière TOP 10
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.red,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flash_on, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'TOUS LES COURS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Grille des cours
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index];

                    // ✅ COURS GRATUIT = PAS BESOIN DE VÉRIFIER L'ACHAT
                    if (course.price == 0.0) {
                      return StudentCourseCard(
                        course: course,
                        hasPurchased: true, // ✅ Gratuit = accès immédiat
                        onTap: () => _openCourseDetail(context, course, true),
                      );
                    }

                    // ✅ COURS PAYANT = VÉRIFIER L'ACHAT
                    return FutureBuilder<bool>(
                      future: _purchaseController.userOwnsCourse(
                        currentUser?.uid ?? '',
                        course.id,
                      ),
                      builder: (context, purchaseSnapshot) {
                        bool hasPurchased = purchaseSnapshot.data ?? false;

                        return StudentCourseCard(
                          course: course,
                          hasPurchased: hasPurchased,
                          onTap: () => _openCourseDetail(context, course, hasPurchased),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  // PAGE QUIZ PRINCIPALE
  Widget _buildQuizPage() {
    return StreamBuilder<List<Course>>(
      stream: _courseController.listenToPublishedCourses(),
      builder: (context, coursesSnapshot) {
        if (coursesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!coursesSnapshot.hasData || coursesSnapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun cours avec quiz disponible'));
        }

        return Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz et Évaluations',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Testez vos connaissances et suivez votre progression',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Liste des cours avec quiz
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: coursesSnapshot.data!.length,
                itemBuilder: (context, index) {
                  final course = coursesSnapshot.data![index];
                  return _buildCourseQuizCard(course);
                },
              ),
            ),
          ],
        );
      },
    );
  }

// Carte de cours avec quiz
  Widget _buildCourseQuizCard(Course course) {
    final quizController = QuizController();

    return StreamBuilder<List<Quiz>>(
      stream: quizController.listenToCourseQuizzes(course.id),
      builder: (context, quizSnapshot) {
        if (!quizSnapshot.hasData || quizSnapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // Ne pas afficher les cours sans quiz
        }

        final quizzes = quizSnapshot.data!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(course.type),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        course.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Statistiques du cours
                StreamBuilder<Map<String, dynamic>>(
                  stream: quizController.getQuizStats(course.id),
                  builder: (context, statsSnapshot) {
                    final stats = statsSnapshot.data ?? {};

                    return Row(
                      children: [
                        _buildStatItem(
                          'Quiz',
                          quizzes.length.toString(),
                          Icons.quiz,
                          Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        _buildStatItem(
                          'Score Moyen',
                          stats['averageScore'] != null
                              ? '${stats['averageScore']!.toStringAsFixed(1)}%'
                              : '--',
                          Icons.trending_up,
                          Colors.green,
                        ),
                        const SizedBox(width: 16),
                        _buildStatItem(
                          'Réussite',
                          stats['successRate'] != null
                              ? '${stats['successRate']!.toStringAsFixed(1)}%'
                              : '--',
                          Icons.emoji_events,
                          Colors.orange,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Liste des quiz
                const Text(
                  'Quiz disponibles:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                ...quizzes.map((quiz) => _buildQuizItem(quiz, course)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

// Élément de quiz individuel
  Widget _buildQuizItem(Quiz quiz, Course course) {
    final quizController = QuizController();

    return StreamBuilder<QuizResult?>(
      stream: quizController.getQuizResult(quiz.id),
      builder: (context, resultSnapshot) {
        final result = resultSnapshot.data;
        final hasAttempted = result != null;
        final bestScore = result?.percentage ?? 0;
        final isPassed = result?.passed ?? false;

        return Card(
          color: Colors.grey[50],
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPassed ? Colors.green : Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasAttempted ? Icons.assignment_turned_in : Icons.assignment,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              quiz.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: hasAttempted ? Colors.green[800] : Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${quiz.questions.length} questions • ${quiz.timeLimit.inMinutes} min',
                  style: const TextStyle(fontSize: 12),
                ),
                if (hasAttempted)
                  Text(
                    'Meilleur score: ${bestScore.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isPassed ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                _startQuiz(context, quiz, course);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasAttempted ? Colors.orange : Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(hasAttempted ? 'REFAIRE' : 'COMMENCER'),
            ),
          ),
        );
      },
    );
  }

// Widget helper pour les statistiques
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

// Démarrer un quiz
  void _startQuiz(BuildContext context, Quiz quiz, Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(quiz: quiz, course: course),
      ),
    ).then((value) {
      if (value == true) {
        setState(() {}); // Rafraîchir les données
      }
    });
  }

  // PAGE STATISTIQUES
  Widget _buildStatistiquesPage() {
    return StreamBuilder<List<Course>>(
      stream: _courseController.listenToPublishedCourses(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Course> courses = snapshot.data!;
        int totalCourses = courses.length;
        int tdCount = courses.where((c) => c.type == 'TD').length;
        int tpCount = courses.where((c) => c.type == 'TP').length;
        int courCount = courses.where((c) => c.type == 'COUR').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistiques de ${_getUserName()}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total des cours',
                      totalCourses.toString(),
                      Icons.book,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Cours TD',
                      tdCount.toString(),
                      Icons.assignment,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Cours TP',
                      tpCount.toString(),
                      Icons.computer,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Répartition par type',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildTypeCard('TD', tdCount, Colors.purple)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTypeCard('TP', tpCount, Colors.orange)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTypeCard('COUR', courCount, Colors.red)),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Liste des cours',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ...courses.map((course) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(course.type),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      course.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(course.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Prix: ${course.price == 0.0 ? 'GRATUIT' : '${course.price} DT'}'),
                      const SizedBox(height: 4),
                      Text('Ressources: ${course.resources.length}'),
                    ],
                  ),
                  trailing: Text(
                    course.price == 0.0 ? 'GRATUIT' : '${course.price} DT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: course.price == 0.0 ? Colors.blue : Colors.green,
                    ),
                  ),
                  onTap: () async {
                    bool hasPurchased = await _purchaseController.userOwnsCourse(
                      currentUser?.uid ?? '',
                      course.id,
                    );
                    _openCourseDetail(context, course, hasPurchased);
                  },
                ),
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  // WIDGETS HELPER
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(String type, int count, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              type,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('cours', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'TD':
        return Colors.purple;
      case 'TP':
        return Colors.orange;
      case 'COUR':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ✅ MÉTHODE D'INTERACTION MODIFIÉE
  void _openCourseDetail(BuildContext context, Course course, bool hasPurchased) {
    // ✅ VÉRIFIER SI COURS GRATUIT
    bool isFreeCourse = course.price == 0.0;

    // Si cours gratuit, forcer hasPurchased à true
    bool accessGranted = isFreeCourse ? true : hasPurchased;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsPage(
          course: course,
          hasPurchased: accessGranted, // ✅ Gratuit = accès immédiat
        ),
      ),
    ).then((value) {
      // Rafraîchir si l'achat a été effectué
      if (value == true) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// ✅ CARTE DE COURS ÉTUDIANT MODIFIÉE
class StudentCourseCard extends StatelessWidget {
  final Course course;
  final bool hasPurchased;
  final VoidCallback onTap;

  const StudentCourseCard({
    super.key,
    required this.course,
    required this.hasPurchased,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ DÉTERMINER LE BOUTON EN FONCTION DU PRIX
    bool isFreeCourse = course.price == 0.0;
    String buttonText = 'ACCÉDER';
    Color buttonColor = Colors.green;

    if (!isFreeCourse) {
      // Cours payant
      buttonText = hasPurchased ? 'ACCÉDER' : 'ACHETER';
      buttonColor = hasPurchased ? Colors.green : Colors.red;
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec type et prix
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(course.type),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      course.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // ✅ AFFICHAGE PRIX AVEC INDICATEUR GRATUIT
                  Text(
                    isFreeCourse ? 'GRATUIT' : '${course.price} DT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isFreeCourse ? Colors.blue : Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            // Image du cours
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.grey),
                ),
                child: course.thumbnailUrl != null
                    ? Image.network(
                  course.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    );
                  },
                )
                    : const Center(
                  child: Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),

            // Titre du cours
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 30,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  course.title,
                  style: const TextStyle(fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Info ressources
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '${course.resources.length} ressource(s)',
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 4),

            // ✅ BOUTON D'ACTION MODIFIÉ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: SizedBox(
                height: 30,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'TD':
        return Colors.purple;
      case 'TP':
        return Colors.orange;
      case 'COUR':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}