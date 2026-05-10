import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../catalog/presentation/pages/catalog_page.dart';
import '../../../reseller/presentation/pages/dashboard_page.dart';

class RoleSelectorPage extends StatelessWidget {
  const RoleSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppTheme.vinho,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Perfumes da Mayara',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppTheme.dourado,
                fontSize: 48,
              ),
            ),
            const SizedBox(height: 60),
            _buildOptionCard(
              context,
              title: 'VISÃO DO CLIENTE',
              subtitle: 'Catálogo e Reservas',
              icon: Icons.shopping_bag_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CatalogPage()),
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionCard(
              context,
              title: 'ÁREA DO REVENDEDOR',
              subtitle: 'Gestão e Cadastro IA',
              icon: Icons.admin_panel_settings_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppTheme.dourado.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.dourado, size: 40),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.dourado.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
