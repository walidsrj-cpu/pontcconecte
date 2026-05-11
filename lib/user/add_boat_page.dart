import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pontconnect/core/constants.dart';
import 'package:pontconnect/auth/user_session_storage.dart';
import 'package:pontconnect/core/notification_helper.dart';

// PAGE D'AJOUT DE BATEAU
class AddBoatPage extends StatefulWidget {
  @override
  _AddBoatPageState createState() => _AddBoatPageState();
}

class _AddBoatPageState extends State<AddBoatPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _immatriculationController = TextEditingController();
  final _hauteurController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _immatriculationController.dispose();
    _hauteurController.dispose();
    super.dispose();
  }

  // AJOUT D'UN BATEAU
  Future<void> _addBoat() async {
    if (!_formKey.currentState!.validate()) return;

    final token = UserSession.userToken;
    if (token == null) {
      NotificationHelper.showError(context, 'TOKEN JWT NON TROUVÉ');
      return;
    }

    final int? userId = UserSession.userId;
    if (userId == null) {
      NotificationHelper.showError(context, 'UTILISATEUR NON CONNECTÉ');
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse("${ApiConstants.baseUrl}user/boats");
    final body = {
      "user_id": userId.toString(),
      "nom": _nomController.text.trim(),
      "immatriculation": _immatriculationController.text.trim(),
      "hauteur_max": _hauteurController.text.trim()
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (data["success"] == true) {
        NotificationHelper.showSuccess(context, "BATEAU AJOUTÉ AVEC SUCCÈS");
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } else if (response.statusCode == 403) {
        NotificationHelper.showWarning(
            context, 'SESSION EXPIRÉE. VEUILLEZ VOUS RECONNECTER.');
        Navigator.pushReplacementNamed(context, '/login_screen');
      } else {
        NotificationHelper.showError(
            context, "ERREUR: ${data["message"] ?? "Une erreur est survenue"}");
      }
    } catch (e) {
      NotificationHelper.showError(context, "ERREUR: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext _context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text(
          'AJOUTER UN BATEAU',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: backgroundLight,
          ),
        ),
      ),
      backgroundColor: backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ICÔNE
              Icon(
                Icons.directions_boat,
                size: 80,
                color: primaryColor,
              ),
              const SizedBox(height: 32),

              // CHAMP NOM DU BATEAU
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom du bateau',
                  labelStyle: const TextStyle(color: textSecondary),
                  prefixIcon: const Icon(Icons.directions_boat, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du bateau';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CHAMP IMMATRICULATION
              TextFormField(
                controller: _immatriculationController,
                decoration: InputDecoration(
                  labelText: 'Immatriculation',
                  labelStyle: const TextStyle(color: textSecondary),
                  prefixIcon: const Icon(Icons.assignment, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'immatriculation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CHAMP HAUTEUR MAX
              TextFormField(
                controller: _hauteurController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Hauteur maximale (m)',
                  labelStyle: const TextStyle(color: textSecondary),
                  prefixIcon: const Icon(Icons.height, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la hauteur maximale';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // BOUTON AJOUTER
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addBoat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: backgroundLight)
                      : const Text(
                    "AJOUTER LE BATEAU",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: backgroundLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
