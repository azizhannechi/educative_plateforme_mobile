// lib/services/storage_service.dart
import 'dart:io';

class StorageService {
  /// Cette méthode ne fait plus d'upload réel
  /// On utilise uniquement des URLs externes (Google Drive, YouTube, etc.)
  Future<Map<String, dynamic>> uploadFile({
    File? file,
    required String courseId,
    required String fileName,
  }) async {
    // Pas d'upload réel vers Firebase Storage
    // On retourne juste un succès vide
    return {
      'success': true,
      'url': '',        // L'URL viendra de l'utilisateur
      'storagePath': '',
      'size': 0,
    };
  }

  /// Pas de suppression non plus (car pas de fichiers uploadés)
  Future<bool> deleteFile(String storagePath) async {
    // Rien à supprimer sur Firebase Storage
    return true;
  }

  /// Méthode pour valider une URL externe
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;

    // Vérifier si c'est une URL valide
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    // Doit commencer par http:// ou https://
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  /// Détecter le type de plateforme depuis l'URL
  static String detectPlatform(String url) {
    final urlLower = url.toLowerCase();

    if (urlLower.contains('youtube.com') || urlLower.contains('youtu.be')) {
      return '🎬 YouTube';
    } else if (urlLower.contains('drive.google.com')) {
      return '📁 Google Drive';
    } else if (urlLower.contains('vimeo.com')) {
      return '🎬 Vimeo';
    } else if (urlLower.contains('dropbox.com')) {
      return '📦 Dropbox';
    } else if (urlLower.contains('onedrive.live.com')) {
      return '☁️ OneDrive';
    } else {
      return '🔗 Lien externe';
    }
  }
}