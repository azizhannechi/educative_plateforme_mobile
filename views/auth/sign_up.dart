import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../controllers/auth_controller.dart';
// ---- PAGE PRINCIPALE ----
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 LOGO STUDYHUB
                Image.asset(
                  'assets/image/logo_studyhub.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 40),

                // 🔹 FORMULAIRE
                const SignupForm(),

                const SizedBox(height: 40),

                // 🔹 TERMS OF USE & PRIVACY POLICY
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Terms of Use')),
                        );
                      },
                      child: const Text(
                        'Terms of Use',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Text(
                      '  |  ',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Privacy Policy')),
                        );
                      },
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---- FORMULAIRE ----
class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  SignupFormState createState() => SignupFormState();
}

class SignupFormState extends State<SignupForm> {
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final etablissementController = TextEditingController();

  String? userType = 'Étudiant'; // Défini par défaut sur Étudiant
  String? niveau; // Niveau scolaire pour étudiant
  // String? matiere; // Matière pour enseignant - SUPPRIMÉ

  // Liste des niveaux scolaires
  final List<String> niveaux = [
    '1ère année',
    '2ème année',
    '3ème année',
    'Master M1',
    'Master M2',
  ];


  void signup() async {
    String nom = nomController.text.trim();
    String prenom = prenomController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String etablissement = etablissementController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || email.isEmpty || password.isEmpty || etablissement.isEmpty || niveau == null) {
      _showMessage('Veuillez remplir tous les champs obligatoires');
      return;
    }

    try {
      // Créer un utilisateur Firebase
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ajouter éventuellement des infos supplémentaires dans Firestore (optionnel)
      // await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      //   'nom': nom,
      //   'prenom': prenom,
      //   'etablissement': etablissement,
      //   'niveau': niveau,
      //   'role': 'etudiant',
      // });

      _showMessage('Inscription réussie pour $prenom $nom !');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showMessage('Le mot de passe est trop faible.');
      } else if (e.code == 'email-already-in-use') {
        _showMessage('Un compte existe déjà avec cet email.');
      } else {
        _showMessage('Erreur : ${e.message}');
      }
    } catch (e) {
      _showMessage('Erreur inattendue : $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // 🔹 TITRE
          const Text(
            'Créer un compte',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          // 🔹 NOM
          TextField(
            controller: nomController,
            decoration: const InputDecoration(
              hintText: 'Nom*',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 🔹 PRÉNOM
          TextField(
            controller: prenomController,
            decoration: const InputDecoration(
              hintText: 'Prénom*',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 🔹 EMAIL
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              hintText: 'Email*',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 🔹 MOT DE PASSE
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Mot de passe*',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
            ),
          ),
          const SizedBox(height: 20),


          TextField(
            controller: etablissementController,
            decoration: const InputDecoration(
              hintText: 'Établissement*',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 🔹 NIVEAU SCOLAIRE (Puisque c'est toujours Étudiant)
          // La condition `if (userType == 'Étudiant')` n'est plus nécessaire
          DropdownButtonFormField<String>(
            value: niveau,
            decoration: const InputDecoration(
              hintText: 'Niveau scolaire*',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
            ),
            items: niveaux.map((String niv) {
              return DropdownMenuItem<String>(
                value: niv,
                child: Text(niv),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                niveau = newValue;
              });
            },
          ),
          const SizedBox(height: 25),

          // 🔹 BOUTON S'INSCRIRE
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                'S\'inscrire',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 🔹 LIEN CONNEXION
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Vous avez déjà un compte ? ',
                style: TextStyle(fontSize: 14),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                  // TODO: Naviguer vers la page de connexion
                },
                child: const Text(
                  'Connectez-vous',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    passwordController.dispose();
    etablissementController.dispose();
    super.dispose();
  }

}