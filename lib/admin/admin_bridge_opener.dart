import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Utilisation des chemins relatifs directs
import '../core/constants.dart';
import '../core/notification_helper.dart';
import '../auth/user_session_storage.dart';

class AdminBridgeOpener extends StatefulWidget {
  const AdminBridgeOpener({super.key});

  @override
  State<AdminBridgeOpener> createState() => _AdminBridgeOpenerState();
}

class _AdminBridgeOpenerState extends State<AdminBridgeOpener> {
  List<dynamic> _ponts = [];
  String? _selectedPontId;
  bool _loading = false;
  bool _fetching = false;

  @override
  void initState() {
    super.initState();
    _fetchPonts();
  }

  Future<void> _fetchPonts() async {
    final token = UserSession.userToken;
    if (token == null) {
      NotificationHelper.showError(
          context, "Token non trouvé. Veuillez vous reconnecter.");
      return;
    }

    setState(() => _fetching = true);
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}admin/ponts"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loadedPonts = data['ponts'] as List<dynamic>? ?? [];
        setState(() {
          _ponts = loadedPonts;
          _selectedPontId = _ponts.isNotEmpty ? (_getPontId(_ponts[0])) : null;
        });
      } else {
        final data = jsonDecode(response.body);
        NotificationHelper.showError(
          context,
          data['message']?.toString() ?? 'Erreur ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint("Erreur : $e");
      NotificationHelper.showError(context, 'Impossible de charger les ponts.');
    } finally {
      setState(() => _fetching = false);
    }
  }

  String _getPontId(dynamic pont) {
    return pont['pont_id']?.toString() ?? pont['id']?.toString() ?? '';
  }

  String _getPontLabel(dynamic pont) {
    return pont['libelle_pont']?.toString() ??
        pont['nom']?.toString() ??
        'Pont inconnu';
  }

  void _requestBridgeAction(String action) {
    if (_selectedPontId == null || _selectedPontId!.isEmpty) {
      NotificationHelper.showError(context, 'Veuillez sélectionner un pont.');
      return;
    }
    NotificationHelper.showSuccess(context, '$action demandé');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title:
            const Text("CONTRÔLE PONT", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _fetching
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.directions_boat,
                      size: 80, color: Color(0xFF001A49)),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedPontId,
                    items: _ponts.map((p) {
                      final pontId = _getPontId(p);
                      return DropdownMenuItem<String>(
                        value: pontId,
                        child: Text(_getPontLabel(p)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedPontId = val),
                    decoration: const InputDecoration(
                        labelText: "Sélectionner un pont"),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _requestBridgeAction("Ouverture"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                        child: const Text("OUVRIR"),
                      ),
                      ElevatedButton(
                        onPressed: () => _requestBridgeAction("Fermeture"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white),
                        child: const Text("FERMER"),
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
