import 'package:flutter/material.dart';
import '../services/category_service.dart';
import 'products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final String structureId;
  final String structureName;

  const CategoriesScreen({
    super.key,
    required this.structureId,
    required this.structureName,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> categories = [];
  List<dynamic> filteredCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCategories = categories.where((c) {
        final nom = (c['nameCat'] ?? '').toString().toLowerCase();
        final desc = (c['description'] ?? '').toString().toLowerCase();
        return nom.contains(query) || desc.contains(query);
      }).toList();
    });
  }

  Future<void> fetchCategories() async {
    try {
      final data =
      await _categoryService.getCategoriesByStructure(widget.structureId);
      setState(() {
        categories = data;
        filteredCategories = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: Text(widget.structureName,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFF9800),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Barre de recherche
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher une catégorie...",
                prefixIcon:
                const Icon(Icons.search, color: Color(0xFFFF9800), size: 22),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🧱 Grille des catégories
          Expanded(
            child: isLoading
                ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF9800)))
                : filteredCategories.isEmpty
                ? const Center(
              child: Text(
                "Aucune catégorie trouvée 😕",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 🟠 4 colonnes
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final c = filteredCategories[index] ?? {};
                final nom =
                (c['nameCat'] ?? 'Catégorie inconnue')
                    .toString();
                final desc = (c['description'] ?? '').toString();

                return GestureDetector(
                  onTap: () {
                    if (c['id'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductsScreen(
                            categoryId: c['id'],
                            categoryName: nom,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Catégorie invalide")),
                      );
                    }
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.category,
                              size: 36, color: Color(0xFFFF9800)),
                          const SizedBox(height: 8),
                          Text(
                            nom,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                        /*  Text(
                            desc,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 10),
                          ),*/
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
