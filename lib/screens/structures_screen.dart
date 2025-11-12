import 'package:flutter/material.dart';
import '../services/structure_service.dart';
import '../utils/constants.dart';
import 'categories_screen.dart';
import 'mon_espace_screen.dart'; // 🔹 Ton écran perso

class StructuresScreen extends StatefulWidget {
  const StructuresScreen({super.key});

  @override
  State<StructuresScreen> createState() => _StructuresScreenState();
}

class _StructuresScreenState extends State<StructuresScreen> {
  final StructureService _structureService = StructureService();
  final TextEditingController searchController = TextEditingController();

  List<dynamic> allStructures = [];
  List<dynamic> filteredStructures = [];
  bool isLoading = true;

  String flashMessage =
      "📢 Bienvenue ! Consultez les dernières structures disponibles.";

  @override
  void initState() {
    super.initState();
    fetchStructures();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredStructures = allStructures.where((structure) {
        final nom = (structure['nomStructure'] ?? '').toString().toLowerCase();
        final ville = (structure['villeStructure'] ?? '').toString().toLowerCase();
        return nom.contains(query) || ville.contains(query);
      }).toList();
    });
  }

  Future<void> fetchStructures() async {
    try {
      final data = await _structureService.getAllStructures();
      setState(() {
        allStructures = data;
        filteredStructures = data;
        isLoading = false;
        flashMessage = "✅ ${data.length} structures disponibles actuellement.";
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        flashMessage = "⚠️ Impossible de charger les structures.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text("Structures", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFF9800),
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 🔔 Zone Flash Info
          Container(
            width: double.infinity,
            color: Colors.orange[200],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.campaign, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    flashMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // 📰 Zone publicité agrandie
          Container(
            width: double.infinity,
            height: 150,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.orange[100],
              image: const DecorationImage(
                image: AssetImage('assets/images/pub_banner.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text(
                "🧾 Publicité : Réservez votre espace ici !",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),

          // 🔍 Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Rechercher une structure...",
                prefixIcon:
                const Icon(Icons.search, color: Colors.orange, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🧱 Grille des structures
          Expanded(
            child: isLoading
                ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF9800)))
                : filteredStructures.isEmpty
                ? const Center(
              child: Text(
                "Aucune structure trouvée 😕",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.62,
              ),
              itemCount: filteredStructures.length,
              itemBuilder: (context, index) {
                final s = filteredStructures[index];
                final photoUrl = (s['structPhotoUrl'] ?? '')
                    .replaceAll('http://localhost:8080', baseUrl);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoriesScreen(
                          structureId: s['idStructure'],
                          structureName: s['nomStructure'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: photoUrl.isNotEmpty
                              ? Image.network(
                            photoUrl,
                            height: 70,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            height: 70,
                            width: double.infinity,
                            color: Colors.orange[100],
                            child: const Icon(
                              Icons.business,
                              size: 26,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                          Text(
                          s['nomStructure'] ??
                            'Structure sans nom',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s['villeStructure'] ?? 'Ville inconnue',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                            Icon(
                            Icons.circle,
                            size: 7,
                            color: (s['disponibiliteStructure']
                                ?.toString()
                                .toLowerCase() ==
                                'disponible')
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              s['disponibiliteStructure'] ??
                                  'Inconnu',
                              style: TextStyle(
                                  color: (s['disponibiliteStructure']
                                      ?.toString()
                                      .toLowerCase() ==
                                      'disponible')
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    ],
                  ),
                ),
                ],
                ),
                ),
                );
              },
            ),
          ),
        ],
      ),
      // 🔹 Bouton flottant "Mon espace perso"
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigation vers ton espace perso
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MonEspaceScreen()),
          );
        },
        icon: const Icon(Icons.person),
        label: const Text("Mon espace perso"),
        backgroundColor: const Color(0xFFFF9800),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
