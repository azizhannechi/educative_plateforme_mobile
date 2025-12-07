// lib/views/payments/paymee_payment_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/paymee_service.dart';
import '../../../controllers/purchase_controller.dart';
import '../../../models/purchase_model.dart';
import '../../../models/course_model.dart';

class PaymeePaymentPage extends StatefulWidget {
  final Course course;
  final User currentUser;

  const PaymeePaymentPage({
    Key? key,
    required this.course,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<PaymeePaymentPage> createState() => _PaymeePaymentPageState();
}

class _PaymeePaymentPageState extends State<PaymeePaymentPage> {
  final PurchaseController _purchaseController = PurchaseController();
  final PaymeeService _paymeeService = PaymeeService();

  bool _isProcessing = false;
  bool _paymentInitiated = false;
  String? _purchaseId;
  String? _paymentToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement Paymee'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(),
            const SizedBox(height: 20),

            // Contenu principal
            Expanded(
              child: _paymentInitiated
                  ? _buildPaymentVerification()
                  : _buildPaymentInitialization(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.course.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getTypeColor(widget.course.type),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.course.type,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${widget.course.price} DT',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentInitialization() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.payment,
          size: 80,
          color: Colors.blue,
        ),
        const SizedBox(height: 20),
        const Text(
          'Paiement sécurisé via Paymee',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Cliquez sur "Démarrer le paiement" pour être redirigé '
              'vers la plateforme sécurisée Paymee.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: _isProcessing
              ? ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Traitement en cours...'),
              ],
            ),
          )
              : ElevatedButton.icon(
            onPressed: _initiatePayment,
            icon: const Icon(Icons.lock),
            label: const Text('Démarrer le paiement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildSandboxInfo(),
      ],
    );
  }

  Widget _buildPaymentVerification() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.hourglass_bottom,
          size: 80,
          color: Colors.orange,
        ),
        const SizedBox(height: 20),
        const Text(
          'Paiement en cours de vérification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Veuillez compléter le paiement dans l\'onglet ouvert '
              'puis revenez ici pour confirmer.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _verifyPayment,
            icon: const Icon(Icons.check_circle),
            label: const Text('J\'ai terminé le paiement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: _cancelPayment,
          icon: const Icon(Icons.close),
          label: const Text('Annuler le paiement'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSandboxInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: Colors.amber, size: 16),
              SizedBox(width: 8),
              Text(
                'MODE TEST SANDBOX',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Pour tester le paiement, utilisez :',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '• Carte : 4111 1111 1111 1111',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          Text(
            '• Date : 12/30 | CVV : 123 | OTP : 123456',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // 🔹 INITIER LE PAIEMENT
  Future<void> _initiatePayment() async {
    setState(() => _isProcessing = true);

    try {
      // 1. Générer un ID de commande
      _purchaseId = "${DateTime.now().millisecondsSinceEpoch}_${widget.currentUser.uid.substring(0, 5)}";

      // 2. Créer la commande dans Firestore
      await _purchaseController.createPurchase(
        Purchase(
          id: _purchaseId!,
          userId: widget.currentUser.uid,
          courseId: widget.course.id,
          price: widget.course.price,
          paymentMethod: 'paymee',
          status: 'pending',
          transactionId: '',
          createdAt: DateTime.now(),
        ),
      );

      // 3. Appeler Paymee
      final paymentResponse = await _paymeeService.createDirectTestPayment(
        amount: widget.course.price,
        orderId: _purchaseId!,
      );

      if (!paymentResponse['success']) {
        throw Exception(paymentResponse['error']);
      }

      final paymentUrl = paymentResponse['payment_url'];
      _paymentToken = paymentResponse['token'];

      // 4. Ouvrir dans le navigateur
      if (await canLaunchUrl(Uri.parse(paymentUrl))) {
        await launchUrl(
          Uri.parse(paymentUrl),
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );

        // 5. Passer à l'étape de vérification
        setState(() {
          _isProcessing = false;
          _paymentInitiated = true;
        });

        _showSuccessMessage('Page de paiement ouverte dans un nouvel onglet');
      } else {
        throw Exception('Impossible d\'ouvrir la page de paiement');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorMessage('Erreur: ${e.toString()}');
    }
  }

  // 🔹 VÉRIFIER LE PAIEMENT
  Future<void> _verifyPayment() async {
    setState(() => _isProcessing = true);

    try {
      // Demander confirmation
      final isConfirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmer le paiement'),
          content: const Text('Avez-vous effectué le paiement avec succès ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non, échec'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Oui, réussi'),
            ),
          ],
        ),
      );

      if (isConfirmed == true && _purchaseId != null && _paymentToken != null) {
        // Mettre à jour le statut
        await _purchaseController.updateStatus(
          _purchaseId!,
          'paid',
          transactionId: _paymentToken!,
        );

        _showSuccessMessage('✅ Paiement réussi !');
        await Future.delayed(const Duration(seconds: 2));

        // Retourner avec succès
        Navigator.pop(context, true);
      } else {
        await _cancelPayment();
      }
    } catch (e) {
      _showErrorMessage('Erreur de vérification: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // 🔹 ANNULER LE PAIEMENT
  Future<void> _cancelPayment() async {
    if (_purchaseId != null) {
      await _purchaseController.updateStatus(_purchaseId!, 'failed');
    }

    _showErrorMessage('❌ Paiement annulé');
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context, false);
  }

  // 🔹 MESSAGES
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'TD':
        return Colors.purple;
      case 'TP':
        return Colors.orange;
      case 'COUR':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}