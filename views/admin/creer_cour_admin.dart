import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ajouter_ressource_dialog.dart';
import '../../controllers/course_controller.dart';
import '../../models/course_model.dart';
import '../../services/storage_service.dart';
import  'admin_view.dart';

class EspaceAdminCours extends StatefulWidget {
  const EspaceAdminCours({super.key});

  @override
  State<EspaceAdminCours> createState() => _EspaceAdminCoursState();
}

class _EspaceAdminCoursState extends State<EspaceAdminCours> {
  bool filterTD = false;
  bool filterTP = false;
  bool filterCOUR = false;

  final CourseController _courseController = CourseController();
  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    String adminId = FirebaseAuth.instance.currentUser?.uid ?? 'admin_id';

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
                // En-tête avec logo et info utilisateur
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
                            child: const Center(
                              child: Text(
                                'SH',
                                style: TextStyle(
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
                                const Text(
                                  'Admin',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await FirebaseAuth.instance.signOut();
                                    Navigator.pushReplacementNamed(context, '/login');
                                  },
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

                // Filtres
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

                // Navigation
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.home, size: 20),
                  title: const Text('Accueil', style: TextStyle(fontSize: 13)),
                  dense: true,
                  selected: true,
                  selectedTileColor: Colors.red.withOpacity(0.1),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_back, size: 20),
                  title: const Text('Retour', style: TextStyle(fontSize: 13)),
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // CONTENU PRINCIPAL
          Expanded(
            child: Column(
              children: [
                // Barre de recherche
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),

                // Grille de cours - StreamBuilder Firebase
                Expanded(
                  child: StreamBuilder<List<Course>>(
                    stream: _courseController.listenToAdminCourses(adminId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Erreur: ${snapshot.error}'),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
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
                                'Aucun cours créé',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Cliquez sur + pour créer votre premier cours',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Filtrer les cours
                      List<Course> filteredCourses = snapshot.data!.where((course) {
                        if (!filterTD && !filterTP && !filterCOUR) return true;
                        if (filterTD && course.type == 'TD') return true;
                        if (filterTP && course.type == 'TP') return true;
                        if (filterCOUR && course.type == 'COUR') return true;
                        return false;
                      }).toList();

                      return Padding(
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
                            return TeacherCourseCard(
                              course: course,
                              onDelete: () => _deleteCourse(course.id, course.resources),
                              onAddResource: () => _showAddResourceDialog(context, course.id),
                              onPublish: () => _publishCourse(course.id),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // BOUTON FLOTTANT +
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCourseDialog(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  // ==================== MÉTHODES ====================

  void _showCreateCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateCourseDialog(
        onCourseCreated: () {
          _showSuccess('Cours créé avec succès!');
        },
      ),
    );
  }

  void _showAddResourceDialog(BuildContext context, String courseId) {
    showDialog(
      context: context,
      builder: (context) => AjouterRessourceDialog(
        courseId: courseId,
        onRessourceAdded: (resource) {
          _showSuccess('Ressource ajoutée avec succès!');
        },
      ),
    );
  }

  void _deleteCourse(String courseId, List<CourseResource> resources) async {
    // Confirmation
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce cours et toutes ses ressources ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Supprimer les fichiers du Storage Firebase
      for (var resource in resources) {
        if (resource.storagePath != null) {
          await _storageService.deleteFile(resource.storagePath!);
        }
      }

      // Supprimer le cours de Firestore
      await _courseController.deleteCourse(courseId);
      _showSuccess('Cours supprimé avec succès');
    } catch (e) {
      _showError('Erreur lors de la suppression: $e');
    }
  }

  void _publishCourse(String courseId) async {
    try {
      await _courseController.updateStatus(courseId, 'published');
      _showSuccess('Cours publié avec succès! Il est maintenant visible par les étudiants.');
    } catch (e) {
      _showError('Erreur lors de la publication: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

// ==================== CARTE DE COURS ====================
class TeacherCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onDelete;
  final VoidCallback onAddResource;
  final VoidCallback onPublish;

  const TeacherCourseCard({
    super.key,
    required this.course,
    required this.onDelete,
    required this.onAddResource,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge du type + Statut
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(course.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        course.status == 'published' ? 'PUBLIÉ' : 'BROUILLON',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
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
                  '${course.resources.length} ressource(s) • ${course.price == 0 ? 'GRATUIT' : '${course.price} DT'}',
                  style: TextStyle(
                    fontSize: 9,
                    color: course.price == 0 ? Colors.green : Colors.grey[600],
                    fontWeight: course.price == 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Bouton d'action
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: SizedBox(
                  height: 30,
                  child: course.status == 'draft'
                      ? ElevatedButton(
                    onPressed: onPublish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'PUBLIER',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        'EN LIGNE ✓',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Boutons d'action en overlay
          Positioned(
            top: 4,
            right: 4,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 18, color: Colors.blue),
                  onPressed: onAddResource,
                  tooltip: 'Ajouter ressource',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Supprimer cours',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'TD': return Colors.purple;
      case 'TP': return Colors.orange;
      case 'COUR': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'published': return Colors.green;
      case 'draft': return Colors.orange;
      default: return Colors.grey;
    }
  }
}

// ==================== DIALOG CRÉATION DE COURS ====================
// ==================== DIALOG CRÉATION DE COURS ====================
class CreateCourseDialog extends StatefulWidget {
  final VoidCallback onCourseCreated;

  const CreateCourseDialog({super.key, required this.onCourseCreated});

  @override
  State<CreateCourseDialog> createState() => _CreateCourseDialogState();
}

class _CreateCourseDialogState extends State<CreateCourseDialog> {
  final CourseController _courseController = CourseController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(text: '0.0');
  final TextEditingController _thumbnailUrlController = TextEditingController();

  String? _selectedType = 'COUR';
  bool _isCreating = false;
  bool _isFree = true;

  void _createCourse() async {
    if (_titleController.text.isEmpty) {
      _showError('Le titre est requis');
      return;
    }

    if (_thumbnailUrlController.text.isEmpty) {
      _showError('Veuillez ajouter une URL d\'image de couverture');
      return;
    }

    if (!StorageService.isValidUrl(_thumbnailUrlController.text)) {
      _showError('URL d\'image invalide');
      return;
    }

    if (!_isFree) {
      double? price = double.tryParse(_priceController.text);
      if (price == null || price <= 0) {
        _showError('Le prix doit être supérieur à 0 pour un cours payant');
        return;
      }
    }

    setState(() {
      _isCreating = true;
    });

    try {
      String adminId = FirebaseAuth.instance.currentUser?.uid ?? 'admin_id';
      String courseId = DateTime.now().millisecondsSinceEpoch.toString();
      String thumbnailUrl = _thumbnailUrlController.text.trim();
      double price = _isFree ? 0.0 : (double.tryParse(_priceController.text) ?? 0.0);

      Course newCourse = Course(
        id: courseId,
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType!,
        createdBy: adminId,
        createdAt: DateTime.now(),
        status: 'draft',
        price: price,
        category: 'general',
        thumbnailUrl: thumbnailUrl,
        resources: [],
      );

      await _courseController.createCourse(newCourse);

      widget.onCourseCreated();
      Navigator.pop(context);

    } catch (e) {
      setState(() {
        _isCreating = false;
      });
      _showError('Erreur: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Créer un nouveau cours',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isCreating ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Type
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<String>(
                  value: _selectedType,
                  hint: const Text('Type de cours'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ['TD', 'TP', 'COUR'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: _isCreating ? null : (String? newValue) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Titre
              TextField(
                controller: _titleController,
                enabled: !_isCreating,
                decoration: const InputDecoration(
                  hintText: 'Titre du cours*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextField(
                controller: _descriptionController,
                enabled: !_isCreating,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Switch Gratuit/Payant
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isFree ? Icons.lock_open : Icons.lock,
                          color: _isFree ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isFree ? 'Cours gratuit' : 'Cours payant',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: !_isFree,
                      onChanged: _isCreating ? null : (bool value) {
                        setState(() {
                          _isFree = !value;
                          if (_isFree) {
                            _priceController.text = '0.0';
                          }
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Prix (si payant)
              if (!_isFree) ...[
                TextField(
                  controller: _priceController,
                  enabled: !_isCreating,
                  decoration: InputDecoration(
                    hintText: 'Prix (DT)*',
                    prefixText: 'DT ',
                    border: const OutlineInputBorder(),
                    helperText: 'Le prix doit être supérieur à 0',
                    helperStyle: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],

              // Image de couverture (URL)
              Text(
                'Image de couverture*',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _thumbnailUrlController,
                enabled: !_isCreating,
                onChanged: (value) => setState(() {}), // Pour rafraîchir la prévisualisation
                decoration: const InputDecoration(
                  hintText: 'https://i.imgur.com/... ou https://...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  prefixIcon: Icon(Icons.image),
                  helperText: 'URL publique d\'une image (JPG, PNG, WebP)',
                  helperMaxLines: 2,
                ),
              ),
              const SizedBox(height: 8),

              // Prévisualisation de l'image
              if (_thumbnailUrlController.text.isNotEmpty &&
                  StorageService.isValidUrl(_thumbnailUrlController.text)) ...[
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _thumbnailUrlController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.red[50],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, color: Colors.red, size: 40),
                              const SizedBox(height: 8),
                              Text(
                                'Impossible de charger l\'image',
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Instructions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Hébergez votre image sur:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• Imgur (https://imgur.com) - Gratuit et illimité\n'
                          '• Postimages (https://postimages.org)\n'
                          '• ImgBB (https://imgbb.com)\n'
                          '• Google Drive (partage public)',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isCreating ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: _isCreating ? Colors.grey : Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isCreating ? null : _createCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCreating ? Colors.grey : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isCreating
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text('Créer le cours'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }
}