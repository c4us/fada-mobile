import 'package:flutter/material.dart';
import 'subscription_screen.dart';
import 'add_structure_screen.dart';
import 'structures_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text("Tableau de bord"),
        backgroundColor: const Color(0xFFFF9800),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard, size: 80, color: Color(0xFFFF9800)),
            const SizedBox(height: 20),
            const Text(
              "Bienvenue 👋",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Choisissez une action ci-dessous",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 30,
              runSpacing: 30,
              children: [
                FloatingActionButton.extended(
                  heroTag: "bonsPlans",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StructuresScreen(),
                      ),
                    );
                  },
                  label: const Text("Les bons plans"),
                  icon: const Icon(Icons.local_offer_outlined),
                  backgroundColor: const Color(0xFFFF9800),
                ),

                FloatingActionButton.extended(
                  heroTag: "ajoutBusiness",
                  onPressed: () async {
                    final selectedPlan = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SubscriptionScreen(),
                      ),
                    );

                    if (selectedPlan != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddStructureScreen(plan: selectedPlan),
                        ),
                      );
                    }
                  },
                  label: const Text("Ajouter mon business"),
                  icon: const Icon(Icons.add_business_outlined),
                  backgroundColor: Colors.deepOrangeAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
