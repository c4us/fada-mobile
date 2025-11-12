import 'package:flutter/material.dart';
import '../services/product_service.dart';

class ProductsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
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
      filteredProducts = products.where((p) {
        final nom = (p['productName'] ?? '').toString().toLowerCase();
        final desc = (p['descriptionProduit'] ?? '').toString().toLowerCase();
        return nom.contains(query) || desc.contains(query);
      }).toList();
    });
  }

  Future<void> fetchProducts() async {
    try {
      final data =
      await _productService.getProductsByCategory(widget.categoryId);
      setState(() {
        products = data;
        filteredProducts = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFF9800),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 🔍 Barre de recherche
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher un produit...",
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFFFF9800), size: 22),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🧾 Grille des produits
          Expanded(
            child: isLoading
                ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF9800)))
                : filteredProducts.isEmpty
                ? const Center(
              child: Text(
                "Aucun produit trouvé 😕",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 🟠 2 colonnes
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final p = filteredProducts[index] ?? {};

                final imageUrl = (p['photoProduitUrl'] ?? '')
                    .toString()
                    .replaceAll('http://localhost:8080', 'http://127.0.0.1:8080');

                final nom = (p['productName'] ?? 'Produit inconnu')
                    .toString();
                final desc = (p['descriptionProduit'] ?? '')
                    .toString();
                final prix = (p['productPrice'] ?? 'N/A').toString();

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🖼️ Image produit
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              color: Colors.orange[100],
                              child: const Icon(
                                Icons.broken_image,
                                color: Color(0xFFFF9800),
                                size: 40,
                              ),
                            );
                          },
                        )
                            : Container(
                          height: 100,
                          color: Colors.orange[100],
                          child: const Icon(
                            Icons.image,
                            color: Color(0xFFFF9800),
                            size: 40,
                          ),
                        ),
                      ),

                      // 🧾 Détails produit
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              nom,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              desc,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$prix FCFA",
                              style: const TextStyle(
                                  color: Color(0xFFFF9800),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
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
