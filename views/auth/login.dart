import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import 'sign_up.dart';
import '../espace_etudiant.dart';
import '../admin/admin_view.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController _controller = AuthController();
  bool _isLoading = false;

  void login() async {
    setState(() => _isLoading = true);

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    Map<String, dynamic> result = await _controller.login(email, password);

    setState(() => _isLoading = false);

    if (result["success"] == true) {
      if (result["isAdmin"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminView()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentHomePage()),
        );
      }
    }

    _showMessage(result["message"]);
  }

  // 🔹 NOUVELLE MÉTHODE : Connexion avec Google
  void loginWithGoogle() async {
    setState(() => _isLoading = true);

    Map<String, dynamic> result = await _controller.signInWithGoogle();

    setState(() => _isLoading = false);

    if (result["success"] == true) {
      if (result["isAdmin"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminView()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentHomePage()),
        );
      }
    }

    _showMessage(result["message"]);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Log In'),
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
                Image.asset(
                  'assets/image/logo_studyhub.png',
                  width: 120,
                  height: 120,
                ),
                SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Bienvenue !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Email*',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Mot de passe*',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : login,
                          child: _isLoading
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text('Continuer'),
                        ),
                      ),

                      SizedBox(height: 20),

                      // 🔹 SÉPARATEUR "OU"
                      Row(
                        children: [
                          Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('OU', style: TextStyle(color: Colors.grey)),
                          ),
                          Expanded(child: Divider(thickness: 1)),
                        ],
                      ),

                      SizedBox(height: 20),

                      // 🔹 BOUTON GOOGLE SIGN-IN
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : loginWithGoogle,
                          icon: Image.asset(
                            'assets/image/google_logo.png',
                            height: 24,
                            width: 24,
                          ),
                          label: Text(
                            'Continuer avec Google',
                            style: TextStyle(color: Colors.black87),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignupPage()),
                          );
                        },
                        child: Text("Créer un compte"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}