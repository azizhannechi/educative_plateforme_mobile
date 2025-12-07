// lib/views/payments/direct_payment_test.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/paymee_service.dart';

class DirectPaymentTestPage extends StatefulWidget {
  final double amount;
  final String courseTitle;
  final String purchaseId;

  const DirectPaymentTestPage({
    Key? key,
    required this.amount,
    required this.courseTitle,
    required this.purchaseId,
  }) : super(key: key);

  @override
  State<DirectPaymentTestPage> createState() => _DirectPaymentTestPageState();
}

class _DirectPaymentTestPageState extends State<DirectPaymentTestPage> {
  bool _isLoading = false;
  String _paymentUrl = '';
  String? _token;

  @override
  void initState() {
    super.initState();
    _createRealPaymeePayment();
  }

  /// ****************************************
  /// Génère un vrai paiement Sandbox Paymee
  /// ****************************************
  Future<void> _createRealPaymeePayment() async {
    setState(() => _isLoading = true);

    final paymee = PaymeeService();
    final result = await paymee.createDirectTestPayment(
      amount: widget.amount,
      orderId: widget.purchaseId,
    );

    if (!mounted) return;

    if (result["success"] == true) {
      setState(() {
        _paymentUrl = result["payment_url"];
        _token = result["token"];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      _showError("Erreur Paymee: ${result["error"]}");
    }
  }

  /// *******************************
  /// Ouvrir gateway Paymee Sandbox
  /// *******************************
  Future<void> _openPaymentPage() async {
    if (_paymentUrl.isEmpty) {
      _showError("Aucune URL Paymee générée.");
      return;
    }

    final uri = Uri.parse(_paymentUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      _showPaymentInstructions();
    } else {
      _showError("Impossible d'ouvrir Paymee.");
    }
  }

  /// Instructions de test Paymee
  void _showPaymentInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Instructions de test"),
        content: const Text(
          "Pour le test Sandbox Paymee :\n\n"
              "Carte: 4111 1111 1111 1111\n"
              "Date: 12/30\n"
              "CVV: 123\n"
              "OTP: 123456\n\n"
              "Après le paiement, cliquez sur 'J'ai payé'.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _askForConfirmation();
            },
            child: const Text("J'ai payé"),
          ),
        ],
      ),
    );
  }

  Future<void> _askForConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Le paiement a-t-il réussi sur Paymee ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Non"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Oui"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _showSuccess("Paiement confirmé !");
      Navigator.pop(context, true);
    } else {
      _showError("Paiement non confirmé.");
    }
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Paiement Paymee"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(widget.courseTitle,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("${widget.amount} DT",
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Bouton Paymee
            _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text("Payer avec Paymee"),
              onPressed: _openPaymentPage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 20),

            if (_paymentUrl.isNotEmpty)
              Text(
                "URL Paymee : $_paymentUrl",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
