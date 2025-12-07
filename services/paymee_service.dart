import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymeeService {
  static const String _apiUrl = "https://sandbox.paymee.tn/api/v2/payments/create";
  static const String _apiKey = "8df909a1a295c3db79f3fe9ec760a29333491e03"; // ⚠️ Mets ta clé ici

  /// ************************************************************
  /// Create payment — Sandbox Mode (retourne token + payment URL)
  /// ************************************************************
  Future<Map<String, dynamic>> createDirectTestPayment({
    required double amount,
    required String orderId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_apiKey",
        },
        body: jsonEncode({
          "amount": amount,
          "note": "Achat cours StudyHub",
          "order_id": orderId,
          "return_url": "https://paymee.tn/return",
          "cancel_url": "https://paymee.tn/cancel",
        }),
      );

      final data = jsonDecode(response.body);

      // Vérifier statut renvoyé par Paymee
      if (data["status"] != 201 || data["data"] == null) {
        return {
          "success": false,
          "error": data["message"] ?? "Erreur API Paymee",
        };
      }

      final String token = data["data"]["token"];

      // 🔥 URL officielle de redirection (Sandbox)
      final String paymentUrl = "https://sandbox.paymee.tn/gateway/$token";

      return {
        "success": true,
        "token": token,
        "payment_url": paymentUrl,
      };
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  /// ************************************************************
  /// Vérifier paiement (facultatif si tu fais validation manuelle)
  /// ************************************************************
  Future<Map<String, dynamic>> verifyPayment(String token) async {
    final String verifyUrl = "https://sandbox.paymee.tn/api/v2/payments/$token";

    try {
      final response = await http.get(
        Uri.parse(verifyUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_apiKey",
        },
      );

      final data = jsonDecode(response.body);

      if (data["status"] != 200) {
        return {"success": false, "error": data["message"]};
      }

      return {"success": true, "data": data["data"]};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
