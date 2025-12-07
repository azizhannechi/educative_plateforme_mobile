import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/course_controller.dart';
import '../../services/storage_service.dart';
import '../../models/course_model.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';

class AjouterRessourceDialog extends StatefulWidget {
  final String courseId;
  final Function(CourseResource) onRessourceAdded;

  const AjouterRessourceDialog({
    super.key,
    required this.courseId,
    required this.onRessourceAdded,
  });

  @override
  State<AjouterRessourceDialog> createState() => _AjouterRessourceDialogState();
}

class _AjouterRessourceDialogState extends State<AjouterRessourceDialog> {
  final CourseController _courseController = CourseController();
  final StorageService _storageService = StorageService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  String? _selectedResourceType; // 'pdf', 'video'
  Uint8List? _selectedFileBytes;
  String? _fileName;
  bool _isUploading = false;

  // Fonction pour sélectionner le fichier
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'mp4', 'mov', 'avi'],
      withData: true, // nécessaire pour obtenir les bytes sur Web
    );

    if (result != null) {
      setState(() {
        _selectedFileBytes = result.files.single.bytes;
        _fileName = result.files.single.name;

        String extension = result.files.single.extension?.toLowerCase() ?? '';
        if (extension == 'pdf') {
          _selectedResourceType = 'pdf';
        } else {
          _selectedResourceType = 'video';
        }

        _urlController.clear();
      });
    }
  }

  // Fonction pour ajouter la ressource au cours existant
  void _ajouterRessource() async {
    if (_selectedResourceType == null || _titleController.text.isEmpty) {
      _showErrorSnackBar('Type et titre sont requis');
      return;
    }

    // ✅ Validation : URL obligatoire
    if (_urlController.text.isEmpty) {
      _showErrorSnackBar('Veuillez entrer une URL valide');
      return;
    }

    // ✅ Valider que c'est une URL valide
    if (!StorageService.isValidUrl(_urlController.text)) {
      _showErrorSnackBar('URL invalide. Elle doit commencer par https://');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String finalUrl = _urlController.text.trim();

      // Détecter la plateforme
      String platform = StorageService.detectPlatform(finalUrl);
      print("📌 Plateforme détectée: $platform");

      // ✅ Créer la ressource (pas d'upload, juste l'URL)
      CourseResource newResource = CourseResource(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedResourceType!,
        title: _titleController.text,
        url: finalUrl,
        storagePath: null,  // Pas de storagePath car hébergement externe
        size: null,         // Pas de taille car pas d'upload
        mime: _getMimeType(_selectedResourceType!),
        uploadedBy: FirebaseAuth.instance.currentUser?.uid ?? 'admin_id',
        createdAt: DateTime.now(),
      );

      // Ajouter au cours existant
      await _courseController.addResource(widget.courseId, newResource);
      widget.onRessourceAdded(newResource);

      Navigator.pop(context);
      _showSuccessSnackBar('Ressource ajoutée avec succès! ($platform)');

    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  String _getMimeType(String type) {
    switch (type) {
      case 'pdf': return 'application/pdf';
      case 'video': return 'video/mp4';
      default: return 'application/octet-stream';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
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
                    'Ajouter une ressource',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isUploading ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Type de ressource
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<String>(
                  value: _selectedResourceType,
                  hint: const Text('Type de ressource*'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: 'pdf',
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('PDF Document'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'video',
                      child: Row(
                        children: [
                          Icon(Icons.videocam, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text('Vidéo'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: _isUploading ? null : (String? newValue) {
                    setState(() {
                      _selectedResourceType = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Titre de la ressource
              TextField(
                controller: _titleController,
                enabled: !_isUploading,
                decoration: const InputDecoration(
                  hintText: 'Titre de la ressource*',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ URL EXTERNE UNIQUEMENT
              if (_selectedResourceType != null) ...[
                Text(
                  'Lien de la ressource hébergée*',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _urlController,
                  enabled: !_isUploading,
                  decoration: InputDecoration(
                    hintText: _selectedResourceType == 'pdf'
                        ? 'https://drive.google.com/file/d/...'
                        : 'https://www.youtube.com/watch?v=...',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    prefixIcon: const Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 8),

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
                        _getInstructions(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '💡 Assurez-vous que le lien est public/partageable',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isUploading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: _isUploading ? Colors.grey : Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _ajouterRessource,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isUploading ? Colors.grey : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text('Ajouter la ressource'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInstructions() {
    switch (_selectedResourceType) {
      case 'pdf':
        return '📁 Pour les PDFs: Hébergez sur Google Drive, OneDrive ou Dropbox.\n'
            '1. Uploadez votre PDF\n'
            '2. Cliquez sur "Partager" → "Obtenir le lien"\n'
            '3. Choisissez "Tous ceux qui ont le lien peuvent consulter"\n'
            '4. Copiez l\'URL ici';
      case 'video':
        return '🎬 Pour les vidéos: Hébergez sur YouTube ou Vimeo.\n'
            '1. Uploadez votre vidéo\n'
            '2. Définissez comme "Non répertorié" ou "Public"\n'
            '3. Copiez l\'URL de la vidéo ici';
      default:
        return 'Sélectionnez un type de ressource';
    }
  }



  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }
}