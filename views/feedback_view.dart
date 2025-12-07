import 'package:flutter/material.dart';

class FeedbackView extends StatelessWidget {
  const FeedbackView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> feedbacks = [
      {
        "user": "Ahmed Ben Salah",
        "message": "Très bonne application, facile à utiliser.",
        "rating": 5,
      },
      {
        "user": "Mariem Trabelsi",
        "message": "Manque quelques fonctionnalités, mais ça avance bien.",
        "rating": 4,
      },
      {
        "user": "Youssef Messaoud",
        "message": "L’interface est propre, j’aime bien.",
        "rating": 4,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Feedbacks",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: feedbacks.length,
        itemBuilder: (context, index) {
          final fb = feedbacks[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom utilisateur
                  Text(
                    fb["user"],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Message
                  Text(
                    fb["message"],
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),

                  // Étoiles
                  Row(
                    children: List.generate(
                      fb["rating"],
                          (i) => const Icon(Icons.star,
                          size: 18, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}