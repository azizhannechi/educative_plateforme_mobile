import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailView extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Sidebar avec bouton retour
          Container(
            width: 180,
            color: Colors.white,
            child: Column(
              children: [
                // Header avec logo
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Logo studyhub
                      ClipOval(
                        child: Image.asset(
                          'assets/image/logo_studyhub.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Admin et déconnexion
                      Column(
                        children: const [
                          Text('Admin',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('déconnexion',
                              style: TextStyle(
                                  color: Colors.red, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Bouton retour
                ListTile(
                  leading: const Icon(Icons.arrow_back),
                  title: const Text('Retour'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Contenu principal
          Expanded(
            child: Column(
              children: [
                // Barre de recherche
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Rechercher',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenu de la page
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Type d'utilisateur
                          Text(
                            user['type'] ?? 'Étudiant',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Avatar
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.lightBlue[100],
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Champs d'information
                          Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Column(
                              children: [
                                _buildInfoField('ID', user['id'] ?? 'N/A'),
                                const SizedBox(height: 12),
                                _buildInfoField('Nom', user['nom'] ?? 'Non renseigné'),
                                const SizedBox(height: 12),
                                _buildInfoField('Prénom', user['prenom'] ?? 'Non renseigné'),
                                const SizedBox(height: 12),
                                _buildInfoField('Email', user['email'] ?? 'Non renseigné'),
                                const SizedBox(height: 12),
                                _buildInfoField('Établissement', user['etablissement'] ?? 'Non renseigné'),
                                const SizedBox(height: 12),
                                _buildInfoField('Niveau', user['niveau'] ?? 'Non renseigné'),
                                const SizedBox(height: 12),
                                _buildInfoField('Date d\'inscription',
                                    _formatDate(user['dateInscription'])),
                                const SizedBox(height: 12),
                                _buildPasswordField(),
                              ],
                            ),
                          ),

                          // Note explicative sur la sécurité
                          const SizedBox(height: 20),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              border: Border.all(color: Colors.orange[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.security, color: Colors.orange[700], size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Pour des raisons de sécurité, les mots de passe ne sont jamais stockés en clair et ne peuvent pas être consultés.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Boutons d'action
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _showResetPasswordDialog(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Réinitialiser le mot de passe',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () {
                                  _showDeleteDialog(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[700],
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Supprimer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Mot de passe',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '••••••••',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Non renseigné';

    try {
      if (timestamp is Timestamp) {
        return '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
      }
      return timestamp.toString();
    } catch (e) {
      return 'Non renseigné';
    }
  }

  void _showResetPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Réinitialiser le mot de passe'),
          content: Text(
            'Un email de réinitialisation sera envoyé à ${user['email']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // Ici vous pouvez appeler FirebaseAuth.instance.sendPasswordResetEmail()
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Email de réinitialisation envoyé à ${user['email']}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text(
                'Envoyer',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer ${user['prenom']} ${user['nom']} ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer le dialog
                Navigator.pop(context); // Retourner à la page précédente
                // Ajouter ici la logique de suppression
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Utilisateur ${user['prenom']} ${user['nom']} supprimé'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
