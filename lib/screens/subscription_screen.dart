import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Liste des plans avec icône
    final plans = [
      {
        "name": "BASE",
        "price": "Gratuit",
        "color": Colors.orange,
        "icon": Icons.star_border, // icône pour le plan
        "features": [
          "Inscription de 1 business",
          "Accès aux bons plans",
          "Support par email"
        ]
      },
      {
        "name": "PRO",
        "price": "10 000 FCFA / mois",
        "color": Colors.deepOrange,
        "icon": Icons.star_half,
        "features": [
          "Inscription de 5 business",
          "Accès aux bons plans avancés",
          "Statistiques détaillées",
          "Support prioritaire"
        ]
      },
      {
        "name": "PREMIUM",
        "price": "25 000 FCFA / mois",
        "color": Colors.redAccent,
        "icon": Icons.star,
        "features": [
          "Inscription illimitée",
          "Accès complet à tous les bons plans",
          "Statistiques avancées",
          "Support VIP",
          "Mises en avant premium"
        ]
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choisir un plan"),
        backgroundColor: const Color(0xFFFF9800),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Sélectionnez le plan qui vous convient",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Liste de cards
            Expanded(
              child: ListView.builder(
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, plan['name'] as String);
                    },
                    child: Card(
                      color: plan['color'] as Color?,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nom du plan avec icône
                            Row(
                              children: [
                                Icon(
                                  plan['icon'] as IconData,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  plan['name'] as String,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Prix
                            Text(
                              plan['price'] as String,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 16),

                            // Liste des fonctionnalités avec puces
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (plan['features'] as List<String>)
                                  .map((feature) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "• ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                                  .toList(),
                            ),
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
      ),
    );
  }
}
