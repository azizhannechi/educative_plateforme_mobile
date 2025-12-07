import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Configuration GoogleSignIn (version 6.1.0)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  // LOGIN
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } catch (e) {
      print("Erreur login: $e");
      return null;
    }
  }

  // SIMPLE SIGNUP
  Future<User?> signup(String email, String password) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } catch (e) {
      print("Erreur signup: $e");
      return null;
    }
  }

  // SIGNUP + DETAILS
  Future<User?> signupWithDetails({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String etablissement,
    String? userType,
    String? niveau,
    String? matiere,
  }) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'etablissement': etablissement,
        'userType': userType ?? "etudiant",
        'niveau': niveau,
        'matiere': matiere,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCred.user;
    } catch (e) {
      print("Erreur signupWithDetails: $e");
      return null;
    }
  }

  // 🔹 AUTHENTIFICATION GOOGLE (version 6.1.0)
  Future<User?> signInWithGoogle() async {
    try {
      print("🔍 [UserModel] Début signInWithGoogle()");

      // Déclencher la connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      print("🔍 [UserModel] googleUser = ${googleUser?.email ?? 'null'}");

      if (googleUser == null) {
        print("❌ [UserModel] Connexion annulée");
        return null;
      }

      // Obtenir les tokens d'authentification
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print("🔍 [UserModel] idToken présent: ${googleAuth.idToken != null}");
      print("🔍 [UserModel] accessToken présent: ${googleAuth.accessToken != null}");

      // Créer les credentials Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      print("🔍 [UserModel] Connexion à Firebase...");

      // Se connecter à Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      print("✅ [UserModel] Connexion réussie: ${userCredential.user?.email}");
      return userCredential.user;

    } catch (e, stackTrace) {
      print("❌ [UserModel] Erreur: $e");
      print("❌ [UserModel] StackTrace: $stackTrace");
      return null;
    }
  }

  // DÉCONNEXION
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print("✅ Déconnexion réussie");
    } catch (e) {
      print("❌ Erreur déconnexion: $e");
    }
  }

  User? getCurrentUser() => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
