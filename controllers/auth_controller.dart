import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController {
  final AuthModel _model = AuthModel();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    var user = await _model.login(email, password);
    if (user != null) {
      bool isAdmin = await _isAdmin(email);
      return {
        "success": true,
        "message": "Connexion réussie",
        "isAdmin": isAdmin
      };
    } else {
      return {
        "success": false,
        "message": "Email ou mot de passe incorrect",
        "isAdmin": false
      };
    }
  }

  // Méthode pour vérifier si l'email appartient à un admin
  Future<bool> _isAdmin(String email) async {
    List<String> adminEmails = [
      'admin@studyhub.com',
      'administrateur@studyhub.com',
      'superadmin@studyhub.com'
    ];
    return adminEmails.contains(email.toLowerCase());
  }

  Future<String> signupUser({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String etablissement,
    String? userType,
    String? niveau,
  }) async {
    if (await _isAdmin(email)) {
      return "Cet email est réservé à l'administration";
    }

    var user = await _model.signupWithDetails(
      nom: nom,
      prenom: prenom,
      email: email,
      password: password,
      etablissement: etablissement,
      userType: userType ?? 'Étudiant',
      niveau: niveau,
    );

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'etablissement': etablissement,
        'niveau': niveau,
        'userType': userType ?? 'Étudiant',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return "Inscription réussie";
    } else {
      return "Impossible de créer le compte";
    }
  }


  // Méthode pour récupérer tous les utilisateurs (CORRIGÉE)
// Méthode pour récupérer tous les utilisateurs
  Stream<List<Map<String, dynamic>>> getUsers() {
    return _firestore.collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final userEmail = data['email'] ?? '';
        final userType = data['userType'] ?? 'Étudiant';

        return {
          'id': doc.id,
          'uid': doc.id, // l'ID du document = UID
          'nom': data['nom'] ?? '',
          'prenom': data['prenom'] ?? '',
          'email': userEmail,
          'etablissement': data['etablissement'] ?? '',
          'niveau': data['niveau'] ?? '',
          'type': userType,
          'dateInscription': data['createdAt'],
          'status': 'Actif',
        };
      })
          .where((user) => !_isAdminEmail(user['email'])) // 👍 exclure admins
          .toList();
    });
  }


    // Méthode pour vérifier si un email est admin
    bool _isAdminEmail(String email) {
      List<String> adminEmails = [
        'admin@studyhub.com',
        'administrateur@studyhub.com',
        'superadmin@studyhub.com'
      ];
      return adminEmails.contains(email.toLowerCase());
    }
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print("🔍 AuthController: Appel de _model.signInWithGoogle()...");

      User? user = await _model.signInWithGoogle();

      print("🔍 AuthController: User retourné = ${user?.email ?? 'null'}");

      if (user == null) {
        print("❌ AuthController: User est null");
        return {
          "success": false,
          "message": "Connexion Google annulée",
          "isAdmin": false
        };
      }

      print("✅ AuthController: User authentifié = ${user.email}");

      // Vérifier si c'est un admin
      bool isAdmin = await _isAdmin(user.email ?? '');
      print("🔍 AuthController: isAdmin = $isAdmin");

      // Vérifier si l'utilisateur existe déjà dans Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      print("🔍 AuthController: userDoc.exists = ${userDoc.exists}");

      if (!userDoc.exists) {
        print("🔍 AuthController: Création du document Firestore...");
        // Créer un nouveau document utilisateur
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'nom': user.displayName?.split(' ').last ?? '',
          'prenom': user.displayName?.split(' ').first ?? '',
          'email': user.email ?? '',
          'etablissement': '',
          'niveau': '',
          'userType': 'Étudiant',
          'createdAt': FieldValue.serverTimestamp(),
          'photoURL': user.photoURL,
        });
        print("✅ AuthController: Document Firestore créé");
      }

      print("✅ AuthController: Connexion Google réussie !");
      return {
        "success": true,
        "message": "Connexion Google réussie",
        "isAdmin": isAdmin
      };
    } catch (e) {
      print("❌ Erreur signInWithGoogle dans AuthController: $e");
      return {
        "success": false,
        "message": "Erreur lors de la connexion Google: $e",
        "isAdmin": false
      };
    }
  }

  // 🔹 DÉCONNEXION
  Future<void> signOut() async {
    await _model.signOut();
  }
}
