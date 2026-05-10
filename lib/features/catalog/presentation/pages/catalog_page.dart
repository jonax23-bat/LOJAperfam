import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';
import 'product_detail_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _aiResult;
  Uint8List? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 160, bottom: 40, left: 20, right: 20),
              child: Column(
                children: [
                  if (_selectedImage != null || _aiResult != null) _buildAIPreview(),
                  _buildProductGrid(context),
                  const SizedBox(height: 60),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildHeader(context),
          ),
          const Positioned(
            left: 24, bottom: 24,
            child: AdminSpeedDial(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF25D366),
        child: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.vinho,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 48),
              Text(
                'Perfumes da Mayara',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppTheme.dourado,
                      fontSize: 42,
                    ),
              ),
              IconButton(
                onPressed: _isLoading ? null : _pickAndAnalyzeImage,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.dourado),
                        ),
                      )
                    : const Icon(Icons.camera_alt, color: AppTheme.dourado),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _HeaderMenu(),
        ],
      ),
    );
  }

  Widget _buildAIPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.creme,
        border: Border.all(color: AppTheme.dourado, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          if (_selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(_selectedImage!, width: 80, height: 80, fit: BoxFit.cover),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: _isLoading 
              ? const Text('Analisando perfume...', style: TextStyle(fontStyle: FontStyle.italic))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('IA IDENTIFICOU:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.vinho, fontSize: 12)),
                    Text(_aiResult?['nome'] ?? 'Nome não identificado', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Marca: ${_aiResult?['marca'] ?? '-'} | Família: ${_aiResult?['familia_olfativa'] ?? '-'}'),
                  ],
                ),
          ),
          IconButton(
            onPressed: () => setState(() { _aiResult = null; _selectedImage = null; }),
            icon: const Icon(Icons.close),
          )
        ],
      ),
    );
  }

  Future<void> _pickAndAnalyzeImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    setState(() {
      _isLoading = true;
      _selectedImage = bytes;
      _aiResult = null;
    });

    try {
      const apiKey = 'AIzaSyCuo6qvKZ-FHcG4wfRZcVXMYZfXTbVM21w';
      const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$apiKey';

      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "Analise este perfume e retorne APENAS um JSON: {\"nome\": \"string\", \"marca\": \"string\", \"familia_olfativa\": \"string\"}."},
              {"inline_data": {"mime_type": "image/jpeg", "data": base64Encode(bytes)}}
            ]
          }
        ]
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String textResponse = data['candidates'][0]['content']['parts'][0]['text'];
        if (textResponse.contains('```')) {
          textResponse = textResponse.substring(textResponse.indexOf('{'), textResponse.lastIndexOf('}') + 1);
        }
        setState(() => _aiResult = jsonDecode(textResponse));
      }
    } catch (e) {
      debugPrint('Erro IA Catálogo: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProductGrid(BuildContext context) {
    final products = [
      {'title': 'MISTÉRIO DO ORIENTE', 'marca': 'Boticário', 'family': 'Amadeirado Especiado', 'image': 'assets/images/perfume1.png'},
      {'title': 'LUZ DO SOL', 'marca': 'Natura', 'family': 'Floral Vibrante', 'image': 'assets/images/perfume2.png'},
      {'title': 'MAINTIEE', 'marca': 'Mayara', 'family': 'Cítrico Refrescante', 'image': 'assets/images/perfume1.png'},
      {'title': 'ESSÊNCIA REAL', 'marca': 'Mayara', 'family': 'Oriental Gourmet', 'image': 'assets/images/perfume2.png'},
      {'title': 'BRISA DO MAR', 'marca': 'Natura', 'family': 'Aromático Aquático', 'image': 'assets/images/perfume1.png'},
      {'title': 'PÉROLA NEGRA', 'marca': 'Boticário', 'family': 'Chypre Floral', 'image': 'assets/images/perfume2.png'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(
              title: products[index]['title']!,
              brand: products[index]['marca']!,
              family: products[index]['family']!,
              image: products[index]['image']!,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(
                    title: products[index]['title']!,
                    brand: products[index]['marca']!,
                    family: products[index]['family']!,
                    image: products[index]['image']!,
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Text('© 2024 Perfumes da Mayara.', style: TextStyle(color: AppTheme.pretoSuave.withOpacity(0.5), fontSize: 12));
  }
}

class _HeaderMenu extends StatefulWidget {
  const _HeaderMenu();
  @override
  State<_HeaderMenu> createState() => _HeaderMenuState();
}

class _HeaderMenuState extends State<_HeaderMenu> {
  bool _showCategories = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _navItem('SOBRE NÓS'),
        const SizedBox(width: 32),
        _buildProductsItem(),
        const SizedBox(width: 32),
        _navItem('CONTATO'),
      ],
    );
  }

  Widget _buildProductsItem() {
    return MouseRegion(
      onEnter: (_) => setState(() => _showCategories = true),
      onExit: (_) => setState(() => _showCategories = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(children: [
            _navItem('PRODUTOS'),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: AppTheme.dourado, size: 16),
          ]),
          if (_showCategories)
            Positioned(
              top: 20, left: 0,
              child: Container(
                width: 160, margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.vinho, border: Border.all(color: AppTheme.dourado.withOpacity(0.5))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _categoryItem('Femininos'), _categoryItem('Masculinos'),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _categoryItem(String title) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)));
  }

  Widget _navItem(String title) {
    return Text(title, style: const TextStyle(color: AppTheme.dourado, fontWeight: FontWeight.w500, fontSize: 14));
  }
}

class ProductCard extends StatelessWidget {
  final String title, brand, family, image;
  final VoidCallback onTap;

  const ProductCard({
    super.key, 
    required this.title, 
    required this.brand, 
    required this.family, 
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.creme, 
          border: Border.all(color: AppTheme.dourado.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Expanded(child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(image, fit: BoxFit.contain),
            )),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(brand.toUpperCase(), style: const TextStyle(color: AppTheme.dourado, fontWeight: FontWeight.bold, fontSize: 10)),
                  const SizedBox(height: 4),
                  Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(family, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onTap, 
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 36)),
                    child: const Text('Ver Detalhes'),
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

class AdminSpeedDial extends StatelessWidget {
  const AdminSpeedDial({super.key});
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(onPressed: () {}, backgroundColor: AppTheme.vinho, child: const Icon(Icons.add, color: AppTheme.dourado));
  }
}
