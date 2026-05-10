import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _olfactoryFamilyController = TextEditingController();
  final _imageLinkController = TextEditingController();
  String _selectedCategory = 'Perfume'; 
  
  final List<String> _categories = ['Perfume', 'Batom / Maquiagem', 'Creme / Hidratante', 'Sabonete', 'Cabelo', 'Outros'];

  Uint8List? _imageBytes;
  bool _isAnalyzing = false;
  bool _isSaving = false;
  String _errorMessage = '';

  final String _apiKey = 'AIzaSyDLDkZmd8wfr5SnypOSYKgoE-glpKf4NXE';

  Future<void> _pickAndAnalyzeImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _isAnalyzing = true;
        _errorMessage = '';
      });
      await _analyzeWithGemini(bytes);
    }
  }

  Future<void> _analyzeWithGemini(Uint8List bytes) async {
    final base64Image = base64Encode(bytes);
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{
            "parts": [
              {"text": "Identifique o cosmético. Se for um perfume, descubra sua família olfativa. Responda ESTRITAMENTE em formato JSON com as chaves \"nome\", \"marca\" e \"familiaOlfativa\"."},
              {"inline_data": {"mime_type": "image/jpeg", "data": base64Image}}
            ]
          }]
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['candidates'][0]['content']['parts'][0]['text'];
        
        try {
          // Tentar encontrar o bloco JSON
          final regex = RegExp(r'\{[\s\S]*\}');
          final match = regex.stringMatch(text);
          
          if (match != null) {
            final productData = jsonDecode(match);
            setState(() {
              _nameController.text = (productData['nome'] ?? productData['name'] ?? productData['product'] ?? '').toString();
              _brandController.text = (productData['marca'] ?? productData['brand'] ?? '').toString();
              _olfactoryFamilyController.text = (productData['familiaOlfativa'] ?? productData['olfactoryFamily'] ?? '').toString();
              
              if (_nameController.text.isEmpty && _brandController.text.isEmpty) {
                 _errorMessage = 'Falha: JSON encontrado, mas sem nome/marca. Retorno: $match';
              } else {
                 _errorMessage = 'IA: Produto Identificado! ✅';
              }
            });
          } else {
            setState(() => _errorMessage = 'IA não retornou JSON válido. Retorno bruto: $text');
          }
        } catch (jsonError) {
           setState(() => _errorMessage = 'Erro ao decodificar JSON: $jsonError. Texto original: $text');
        }
      } else {
        setState(() => _errorMessage = 'Erro na API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('IA Error: $e');
      setState(() => _errorMessage = 'Erro de requisição: $e');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _saveToFirestore() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      setState(() => _errorMessage = 'Preencha o Nome e o Preço!');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _errorMessage = 'Erro: Você não está logada.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'resellerId': user.uid,
        'resellerEmail': user.email,
        'nome': _nameController.text,
        'marca': _brandController.text,
        'preco': double.tryParse(_priceController.text) ?? 0.0,
        'quantidade': int.tryParse(_quantityController.text) ?? 1,
        'categoria': _selectedCategory,
        'familiaOlfativa': _olfactoryFamilyController.text,
        'foto': _imageLinkController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto adicionado ao seu estoque! ✅'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erro ao salvar: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('NOVO PRODUTO', style: TextStyle(color: AppTheme.dourado, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.vinho,
        iconTheme: const IconThemeData(color: AppTheme.dourado),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAndAnalyzeImage,
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.vinho.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppTheme.vinho.withOpacity(0.2), width: 2),
                    ),
                    child: _imageBytes != null 
                        ? ClipRRect(borderRadius: BorderRadius.circular(23), child: Image.memory(_imageBytes!, fit: BoxFit.cover))
                        : const Icon(Icons.add_a_photo_rounded, size: 60, color: AppTheme.vinho),
                  ),
                ),
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SelectableText(_errorMessage, textAlign: TextAlign.center, style: TextStyle(color: _errorMessage.contains('✅') ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
                const SizedBox(height: 32),
                _buildDropdown(),
                const SizedBox(height: 16),
                _buildTextField('Nome do Produto', _nameController, Icons.shopping_bag_outlined),
                const SizedBox(height: 16),
                _buildTextField('Marca', _brandController, Icons.branding_watermark_outlined),
                const SizedBox(height: 16),
                _buildTextField('Família Olfativa (Apenas Perfumes)', _olfactoryFamilyController, Icons.spa_outlined),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Preço (R\$)', _priceController, Icons.attach_money, keyboard: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Estoque', _quantityController, Icons.inventory_2_outlined, keyboard: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Link da Foto Profissional', _imageLinkController, Icons.link)),
                    IconButton(
                      onPressed: () {
                        final query = Uri.encodeComponent('${_brandController.text} ${_nameController.text} oficial');
                        launchUrl(Uri.parse('https://www.google.com/search?q=$query&tbm=isch'), mode: LaunchMode.externalApplication);
                      }, 
                      icon: const Icon(Icons.search_rounded, color: AppTheme.vinho, size: 30)
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveToFirestore,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.vinho, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SALVAR NO MEU CATÁLOGO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.dourado),
                    SizedBox(height: 20),
                    Text('IDENTIFICANDO PRODUTO...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          onChanged: (val) => setState(() => _selectedCategory = val!),
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppTheme.vinho, size: 20),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
