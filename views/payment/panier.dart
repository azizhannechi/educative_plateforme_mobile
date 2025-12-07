import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/course_model.dart';
import '../../models/purchase_model.dart';
import '../../models/review_model.dart';
import '../../controllers/purchase_controller.dart';
import '../../controllers/course_controller.dart';
import '../../controllers/review_controller.dart';

class PanierPage extends StatefulWidget {
  const PanierPage({Key? key}) : super(key: key);

  @override
  State<PanierPage> createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  final PurchaseController _purchaseController = PurchaseController();
  final CourseController _courseController = CourseController();
  final ReviewController _reviewController = ReviewController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // SIDEBAR GAUCHE
          _buildSidebar(),

          // CONTENU PRINCIPAL
          Expanded(
            child: Column(
              children: [
                // EN-TÊTE
                _buildHeader(),

                // LISTE DES COURS ACHETÉS
                Expanded(
                  child: _buildPurchasedCoursesList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== SIDEBAR ==========
  Widget _buildSidebar() {
    return Container(
      width: 180,
      color: Colors.white,
      child: Column(
        children: [
          // Profil utilisateur
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
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
                const SizedBox(height: 10),
                Text(
                  _getUserName(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                GestureDetector(
                  onTap: _logout,
                  child: const Text(
                    'déconnexion',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Navigation
          ListTile(
            leading: const Icon(Icons.arrow_back),
            title: const Text('Retour'),
            dense: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            dense: true,
            onTap: () => Navigator.pushReplacementNamed(context, '/student-home'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Mes Cours'),
            dense: true,
            selected: true,
            selectedTileColor: Colors.blue.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  // ========== HEADER ==========
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.shopping_bag, size: 32, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mes Cours Achetés',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gérez vos cours et laissez vos avis',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== LISTE DES COURS ACHETÉS ==========
  Widget _buildPurchasedCoursesList() {
    if (_currentUser == null) {
      return const Center(
        child: Text('Veuillez vous connecter'),
      );
    }

    return StreamBuilder<List<Purchase>>(
      stream: _purchaseController.listenToUserPurchases(_currentUser!.uid),
      builder: (context, purchaseSnapshot) {
        if (purchaseSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (purchaseSnapshot.hasError) {
          return Center(
            child: Text('Erreur: ${purchaseSnapshot.error}'),
          );
        }

        if (!purchaseSnapshot.hasData || purchaseSnapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final purchases = purchaseSnapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: purchases.length,
          itemBuilder: (context, index) {
            final purchase = purchases[index];
            return _buildPurchasedCourseCard(purchase);
          },
        );
      },
    );
  }

  // ========== CARTE DE COURS ACHETÉ ==========
  Widget _buildPurchasedCourseCard(Purchase purchase) {
    return FutureBuilder<Course?>(
      future: _courseController.getCourseById(purchase.courseId),
      builder: (context, courseSnapshot) {
        if (!courseSnapshot.hasData) {
          return const Card(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Chargement...'),
            ),
          );
        }

        final course = courseSnapshot.data!;

        return FutureBuilder<Review?>(
          future: _reviewController.getUserReview(_currentUser!.uid, course.id),
          builder: (context, reviewSnapshot) {
            final existingReview = reviewSnapshot.data;
            final hasReview = existingReview != null;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EN-TÊTE DU COURS
                    Row(
                      children: [
                        // Badge Type
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(course.type),
                            borderRadius: BorderRadius.circular(20),
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

                        // Titre
                        Expanded(
                          child: Text(
                            course.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Prix payé
                        Text(
                          '${purchase.price} DT',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Description
                    Text(
                      course.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // RESSOURCES
                    Row(
                      children: [
                        Icon(Icons.folder, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          '${course.resources.length} ressource(s)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          'Acheté le ${_formatDate(purchase.createdAt)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32),

                    // SECTION AVIS
                    if (hasReview)
                      _buildExistingReview(existingReview!)
                    else
                      _buildAddReviewButton(purchase, course),

                    const SizedBox(height: 12),

                    // BOUTONS D'ACTION
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _viewCourseResources(course),
                            icon: const Icon(Icons.book),
                            label: const Text('Voir les ressources'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        if (!hasReview) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showReviewDialog(purchase, course),
                              icon: const Icon(Icons.star),
                              label: const Text('Laisser un avis'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                                side: const BorderSide(color: Colors.orange),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ========== AFFICHAGE AVIS EXISTANT ==========
  Widget _buildExistingReview(Review review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Votre avis :',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              _buildStarRating(review.rating, isReadOnly: true),
              const Spacer(),
              TextButton(
                onPressed: () => _editReview(review),
                child: const Text('Modifier'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Publié le ${_formatDate(review.createdAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ========== BOUTON AJOUTER AVIS ==========
  Widget _buildAddReviewButton(Purchase purchase, Course course) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Vous n\'avez pas encore laissé d\'avis sur ce cours',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  // ========== DIALOGUE POUR LAISSER UN AVIS ==========
  void _showReviewDialog(Purchase purchase, Course course) {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.rate_review, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Évaluer "${course.title}"',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Votre note :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: _buildInteractiveStarRating(
                    selectedRating,
                        (rating) {
                      setDialogState(() {
                        selectedRating = rating;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Votre commentaire :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Partagez votre expérience avec ce cours...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez écrire un commentaire'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                await _submitReview(
                  purchase,
                  course,
                  selectedRating,
                  commentController.text.trim(),
                );

                Navigator.pop(context);
              },
              icon: const Icon(Icons.send),
              label: const Text('Publier l\'avis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== SOUMETTRE UN AVIS ==========
  Future<void> _submitReview(
      Purchase purchase,
      Course course,
      int rating,
      String comment,
      ) async {
    try {
      final reviewId = DateTime.now().millisecondsSinceEpoch.toString();

      final review = Review(
        id: reviewId,
        userId: _currentUser!.uid,
        courseId: course.id,
        purchaseId: purchase.id,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await _reviewController.createReview(review);

      setState(() {}); // Rafraîchir l'UI

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Avis publié avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ========== MODIFIER UN AVIS ==========
  void _editReview(Review review) {
    int selectedRating = review.rating;
    final commentController = TextEditingController(text: review.comment);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Modifier votre avis'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Votre note :', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Center(
                  child: _buildInteractiveStarRating(
                    selectedRating,
                        (rating) {
                      setDialogState(() {
                        selectedRating = rating;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Votre commentaire :', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _reviewController.updateReview(
                  review.id,
                  {
                    'rating': selectedRating,
                    'comment': commentController.text.trim(),
                  },
                );

                setState(() {});
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Avis modifié !'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== WIDGETS ÉTOILES ==========
  Widget _buildStarRating(int rating, {bool isReadOnly = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: isReadOnly ? 20 : 30,
        );
      }),
    );
  }

  Widget _buildInteractiveStarRating(int currentRating, Function(int) onRatingChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 40,
          ),
          onPressed: () => onRatingChanged(index + 1),
        );
      }),
    );
  }

  // ========== VOIR RESSOURCES ==========
  void _viewCourseResources(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ressources - ${course.title}'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: course.resources.isEmpty
              ? const Center(child: Text('Aucune ressource disponible'))
              : ListView.builder(
            itemCount: course.resources.length,
            itemBuilder: (context, index) {
              final resource = course.resources[index];
              return ListTile(
                leading: Icon(
                  _getResourceIcon(resource.type),
                  color: _getResourceColor(resource.type),
                ),
                title: Text(resource.title),
                subtitle: Text(resource.type.toUpperCase()),
                trailing: IconButton(
                  icon: const Icon(Icons.download, color: Colors.blue),
                  onPressed: () {
                    // TODO: Télécharger la ressource
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Téléchargement de ${resource.title}...'),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // ========== ÉTAT VIDE ==========
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Aucun cours acheté',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Commencez par acheter un cours pour le voir ici',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/student-home'),
            icon: const Icon(Icons.school),
            label: const Text('Parcourir les cours'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ========== MÉTHODES UTILITAIRES ==========
  String _getUserName() {
    if (_currentUser?.displayName != null) {
      return _currentUser!.displayName!;
    }
    if (_currentUser?.email != null) {
      return _currentUser!.email!.split('@')[0];
    }
    return 'Étudiant';
  }

  String _getUserInitials() {
    String name = _getUserName();
    if (name.split(' ').length >= 2) {
      return '${name.split(' ')[0][0]}${name.split(' ')[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'TD': return Colors.purple;
      case 'TP': return Colors.orange;
      case 'COUR': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getResourceIcon(String type) {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'video': return Icons.videocam;
      case 'link': return Icons.link;
      default: return Icons.insert_drive_file;
    }
  }

  Color _getResourceColor(String type) {
    switch (type) {
      case 'pdf': return Colors.red;
      case 'video': return Colors.blue;
      case 'link': return Colors.green;
      default: return Colors.grey;
    }
  }
}