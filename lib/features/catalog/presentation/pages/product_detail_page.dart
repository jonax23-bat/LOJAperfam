import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

class ProductDetailPage extends StatelessWidget {
  final String title, brand, family, image;

  const ProductDetailPage({
    super.key,
    required this.title,
    required this.brand,
    required this.family,
    required this.image,
  });

  Future<void> _launchWhatsApp() async {
    final message = 'Olá! Gostaria de reservar o perfume $title ($brand) da família $family.';
    final url = 'https://wa.me/5511999999999?text=${Uri.encodeComponent(message)}'; // Substituir pelo número real
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 400,
              width: double.infinity,
              color: Colors.white,
              child: Image.asset(image, fit: BoxFit.contain),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(brand.toUpperCase(), style: const TextStyle(color: AppTheme.dourado, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text(title, style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.vinho.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppTheme.vinho),
                        const SizedBox(width: 12),
                        Text('Família Olfativa: $family', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('DESCRIÇÃO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  const Text(
                    'Uma fragrância sofisticada que combina notas clássicas com um toque moderno. Perfeito para momentos especiais e uso diário, garantindo uma fixação duradoura e uma projeção marcante.',
                    style: TextStyle(height: 1.6, color: AppTheme.pretoSuave),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _launchWhatsApp,
                    icon: const FaIcon(FontAwesomeIcons.whatsapp),
                    label: const Text('RESERVAR AGORA VIA WHATSAPP'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      backgroundColor: AppTheme.verdeEscuro,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
