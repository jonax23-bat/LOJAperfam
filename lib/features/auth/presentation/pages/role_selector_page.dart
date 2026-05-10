import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../catalog/presentation/pages/catalog_page.dart';
import '../../../reseller/presentation/pages/dashboard_page.dart';
import 'reseller_auth_page.dart';

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Perfumes da Mayara',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.dourado,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
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
                MaterialPageRoute(builder: (context) => const ResellerAuthPage()),
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
        width: 320, // Aumentei levemente a largura base
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.dourado.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.dourado, size: 36),
            const SizedBox(width: 16),
            Expanded( // ESSA É A CHAVE: Deixa o texto ocupar o espaço disponível sem estourar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1,
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
            ),
            const Icon(Icons.chevron_right, color: AppTheme.dourado, size: 20),
          ],
        ),
      ),
    );
  }
}
