import 'package:fada/screens/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/structure_service.dart';
import '../utils/constants.dart';

class MonEspaceScreen extends StatefulWidget {
  const MonEspaceScreen({super.key});

  @override
  State<MonEspaceScreen> createState() => _MonEspaceScreenState();
}

class _MonEspaceScreenState extends State<MonEspaceScreen> {
  String? userId;
  bool isLoading = true;

  final StructureService _structureService = StructureService();
  List<dynamic> userStructures = [];
  bool structuresLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      isLoading = false;
    });
    if (userId != null) {
      _fetchUserStructures(userId!);
    }
  }

  Future<void> _fetchUserStructures(String userId) async {
    setState(() => structuresLoading = true);
    try {
      final allStructures = await _structureService.getAllStructures();
      setState(() {
        // Filtrer les structures créées par l'utilisateur connecté
        userStructures = allStructures
            .where((s) => s['createdUserId']?.toString() == userId)
            .toList();
        structuresLoading = false;
      });
    } catch (e) {
      setState(() => structuresLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 onglets
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mon espace perso"),
          backgroundColor: const Color(0xFFFF9800),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Mes bons plans", icon: Icon(Icons.card_giftcard)),
              Tab(text: "Mes structures", icon: Icon(Icons.business)),
            ],
          ),
        ),
        body: isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9800)),
        )
            : TabBarView(
          children: [
            // 🔹 Onglet Mes bons plans
            _bonsPlansTab(),

            // 🔹 Onglet Mes structures
            _mesStructuresTab(),
          ],
        ),

        // ✅ Bouton flottant ajouté ici
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SubscriptionScreen(),
              ),
            );
          },
          backgroundColor: const Color(0xFFFF9800),
          icon: const Icon(Icons.add_business),
          label: const Text("Créer mon business"),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // ===============================
  // 🟠 Onglet Mes bons plans
  // ===============================
  Widget _bonsPlansTab() {
    final List<String> bonsPlans = [
      "Promotion 1 : 10% sur le plan PRO",
      "Promotion 2 : 15% sur la formule PREMIUM",
      "Offre spéciale : Création gratuite de la 3e structure",
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bonsPlans.length,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.local_offer, color: Color(0xFFFF9800)),
            title: Text(bonsPlans[index]),
          ),
        );
      },
    );
  }

  // ===============================
  // 🟠 Onglet Mes structures
  // ===============================
  Widget _mesStructuresTab() {
    if (structuresLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9800)));
    }

    if (userStructures.isEmpty) {
      return const Center(
        child: Text("Vous n'avez créé aucune structure."),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: userStructures.length,
      itemBuilder: (context, index) {
        final s = userStructures[index];
        final photoUrl = (s['structPhotoUrl'] ?? '').replaceAll(
            'http://localhost:8080', baseUrl);

        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: photoUrl.isNotEmpty
                ? Image.network(photoUrl, width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.business, color: Color(0xFFFF9800)),
            title: Text(s['nomStructure'] ?? 'Structure sans nom'),
            subtitle: Text(s['villeStructure'] ?? 'Ville inconnue'),
          ),
        );
      },
    );
  }
}
