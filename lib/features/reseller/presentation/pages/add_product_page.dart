import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  Uint8List? _webImage;
  final _picker = ImagePicker();
  
  final _nomeController = TextEditingController();
  final _marcaController = TextEditingController();
  final _familiaController = TextEditingController();
  final _precoController = TextEditingController();
  final _estoqueController = TextEditingController();

  bool _isAnalyzing = false;

  Future<void> _analyzeWithGemini(Uint8List imageBytes) async {
    const apiKey = 'AIzaSyCuo6qvKZ-FHcG4wfRZcVXMYZfXTbVM21w';
    const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$apiKey';

    final base64Image = base64Encode(imageBytes);

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "Analise este perfume e retorne APENAS um JSON: {\"nome\": \"string\", \"marca\": \"string\", \"familia_olfativa\": \"string\"}. Não escreva nada fora do JSON."},
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image
              }
            }
          ]
        }
      ]
    });

    try {
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

        final result = jsonDecode(textResponse);
        setState(() {
          _nomeController.text = result['nome'] ?? '';
          _marcaController.text = result['marca'] ?? '';
          _familiaController.text = result['familia_olfativa'] ?? '';
        });
      } else {
        throw 'Erro na API: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('ERRO MANUAL IA: $e');
      setState(() {
        _nomeController.text = "Erro: $e";
      });
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _webImage = bytes;
        _isAnalyzing = true;
        _nomeController.text = "Analisando...";
      });
      _analyzeWithGemini(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Perfume')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _takePhoto,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppTheme.vinho.withOpacity(0.2)),
                ),
                child: _webImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: AppTheme.vinho),
                          SizedBox(height: 10),
                          Text('Tirar Foto do Perfume'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(_webImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            if (_isAnalyzing)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: LinearProgressIndicator(color: AppTheme.vinho),
              ),
            const SizedBox(height: 24),
            _buildTextField(label: 'Nome do Perfume', controller: _nomeController),
            const SizedBox(height: 16),
            _buildTextField(label: 'Marca', controller: _marcaController),
            const SizedBox(height: 16),
            _buildTextField(label: 'Família Olfativa', controller: _familiaController, maxLines: 2),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Preço (R\$)', controller: _precoController, keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(label: 'Estoque', controller: _estoqueController, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.vinho, foregroundColor: Colors.white),
              child: const Text('Salvar no Estoque'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
