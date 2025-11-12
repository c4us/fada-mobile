import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart'; // ✅ Pour le GPS
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AddStructureScreen extends StatefulWidget {
  final String plan;

  const AddStructureScreen({super.key, required this.plan});

  @override
  State<AddStructureScreen> createState() => _AddStructureScreenState();
}

class _AddStructureScreenState extends State<AddStructureScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Contrôleurs de texte
  final nomCtrl = TextEditingController();
  final typeCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final disponibiliteCtrl = TextEditingController();
  final villeCtrl = TextEditingController();
  final rueCtrl = TextEditingController();
  final codePosteCtrl = TextEditingController();
  final geoLocCtrl = TextEditingController(); // ✅ Nouveau champ GPS

  File? _selectedImage;

  // 🔹 Sélection d’image depuis appareil photo ou galerie
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery, // 🔸 ou ImageSource.camera
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  // 🔹 Récupère l'ID utilisateur
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // 🔹 Récupère la position GPS actuelle
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Activez le GPS")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Permission GPS refusée")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Permission GPS bloquée")),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        geoLocCtrl.text =
        "${position.latitude}, ${position.longitude}"; // ✅ Coordonnées affichées
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur GPS : $e")));
    }
  }

  // 🔹 Crée une structure (POST)
  Future<String?> createStructure(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/structure');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return decoded['idStructure']?.toString();
    } else {
      throw Exception("Erreur backend : ${response.body}");
    }
  }

  // 🔹 Upload de la photo (PUT)
  Future<void> uploadStructurePhoto(String idStructure, File photoFile) async {
    final url = Uri.parse("$baseUrl/structure/photo");

    final request = http.MultipartRequest("PUT", url)
      ..fields['id'] = idStructure
      ..files.add(
        await http.MultipartFile.fromPath('file', photoFile.path),
      );

    final response = await request.send();
    if (response.statusCode != 200) {
      final error = await response.stream.bytesToString();
      throw Exception("Erreur upload photo : $error");
    }
  }

  // 🔹 Soumission du formulaire
  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      final userId = await getUserId();

      final structure = {
        "nomStructure": nomCtrl.text,
        "typeStructure": typeCtrl.text,
        "descriptionStructure": descriptionCtrl.text,
        "disponibiliteStructure": disponibiliteCtrl.text,
        "paysStructure": "Burkina Faso",
        "villeStructure": villeCtrl.text,
        "rueStructure": rueCtrl.text,
        "codePoste": codePosteCtrl.text,
        "geoLocStructure": geoLocCtrl.text, // ✅ Position GPS
        "createdUserId": userId,
        "planStructure": widget.plan,
      };

      final structureId = await createStructure(structure);

      if (structureId != null && _selectedImage != null) {
        await uploadStructurePhoto(structureId, _selectedImage!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Structure créée avec succès")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Erreur : $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 🔹 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une structure"),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Colors.orange[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🧩 Photo picker
              GestureDetector(
                onTap: _pickImage,
                child: _selectedImage == null
                    ? Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_a_photo,
                      size: 60, color: Colors.white),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField("Nom de la structure", nomCtrl),
              _buildTextField("Type de structure", typeCtrl),
              _buildTextField("Description", descriptionCtrl, maxLines: 3),
              _buildTextField("Disponibilité", disponibiliteCtrl),
              _buildTextField("Ville", villeCtrl),
              _buildTextField("Rue", rueCtrl),
              _buildTextField("Code postal", codePosteCtrl),

              // ✅ Nouveau champ GPS (optionnel)
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      "Position GPS (optionnel)",
                      geoLocCtrl,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location, color: Colors.orange),
                    onPressed: _getCurrentLocation,
                  ),
                ],
              ),

              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator(color: Colors.orange)
                  : ElevatedButton.icon(
                onPressed: handleSubmit,
                icon: const Icon(Icons.save),
                label: const Text("Enregistrer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) =>
        value == null || value.isEmpty ? "Champ obligatoire" : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
