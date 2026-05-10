import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String _selectedCategory = 'Todos';
  String _resellerConnectionId = ''; // Pode ser Email ou ID
  bool _isConnectedByEmail = true;
  String _storeName = 'CATÁLOGO OFICIAL';
  String _resellerPhone = '';
  final _resellerController = TextEditingController();
  
  final List<String> _categories = ['Todos', 'Perfume', 'Batom / Maquiagem', 'Creme / Hidratante', 'Sabonete', 'Cabelo'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUrlForReseller();
    });
  }

  void _checkUrlForReseller() {
    final uri = Uri.base;
    if (uri.queryParameters.containsKey('reseller')) {
      final resellerParam = uri.queryParameters['reseller']!;
      if (resellerParam.isNotEmpty) {
        _resellerController.text = resellerParam;
        _connectToReseller();
      }
    }
  }

  void _connectToReseller() async {
    final input = _resellerController.text.trim();
    if (input.isEmpty) return;

    final isEmail = input.contains('@');
    final queryField = isEmail ? 'email' : FieldPath.documentId;

    // Busca o ID e o Nome da Loja da revendedora pelo e-mail ou ID
    String fetchedStoreName = 'CATÁLOGO OFICIAL';
    String fetchedPhone = '';
    try {
      final query = await FirebaseFirestore.instance.collection('resellers').where(queryField, isEqualTo: isEmail ? input.toLowerCase() : input).get();
      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        if (data.containsKey('storeName')) {
          fetchedStoreName = data['storeName'].toString().toUpperCase();
        }
        if (data.containsKey('phone')) {
          fetchedPhone = data['phone'].toString();
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar loja: $e');
    }

    setState(() {
      _resellerConnectionId = isEmail ? input.toLowerCase() : input;
      _isConnectedByEmail = isEmail;
      _storeName = fetchedStoreName;
      _resellerPhone = fetchedPhone;
    });
  }

  void _sendWhatsApp(String productName) async {
    String phone = _resellerPhone.isNotEmpty ? _resellerPhone : '5511999999999'; 
    // Limpar pontuação do telefone
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    // Se tiver 10 ou 11 dígitos, adicionar o 55 do Brasil
    if (phone.length == 10 || phone.length == 11) {
      phone = '55$phone';
    }

    final message = Uri.encodeComponent('Olá! Vi o produto "$productName" no seu catálogo e gostaria de reservar.');
    final url = 'https://wa.me/$phone?text=$message';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_storeName, style: const TextStyle(color: AppTheme.dourado, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.vinho,
        iconTheme: const IconThemeData(color: AppTheme.dourado),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ÁREA DE CONEXÃO COM REVENDEDORA
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.vinho.withOpacity(0.05),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _resellerController,
                    decoration: InputDecoration(
                      hintText: 'Digite o ID ou E-mail da Revendedora',
                      hintStyle: const TextStyle(fontSize: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _connectToReseller,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.vinho, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('CONECTAR', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),

          if (_resellerConnectionId.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_search_rounded, size: 80, color: AppTheme.vinho),
                    SizedBox(height: 20),
                    Text('Conecte-se a uma loja\npara ver os produtos disponíveis.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )
          else ...[
            // FILTROS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: _categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                    selectedColor: AppTheme.vinho,
                    labelStyle: TextStyle(color: _selectedCategory == cat ? Colors.white : AppTheme.vinho),
                    backgroundColor: AppTheme.vinho.withOpacity(0.05),
                  ),
                )).toList(),
              ),
            ),
            
            // GRID DINÂMICA DO FIRESTORE
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // FILTRA POR REVENDEDORA (e-mail ou ID)
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .where(_isConnectedByEmail ? 'resellerEmail' : 'resellerId', isEqualTo: _resellerConnectionId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text('Erro ao carregar catálogo.'));
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppTheme.vinho));

                  final docs = snapshot.data!.docs;
                  
                  // Filtro de Categoria Local
                  final filteredDocs = _selectedCategory == 'Todos' 
                      ? docs 
                      : docs.where((d) => d['categoria'] == _selectedCategory).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(child: Text('Nenhum produto encontrado nesta categoria.'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final p = filteredDocs[index].data() as Map<String, dynamic>;
                      return _buildProductCard(p);
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: p['foto'].toString().startsWith('http') 
                ? Image.network(p['foto'], fit: BoxFit.cover, width: double.infinity,
                    errorBuilder: (context, error, stack) => const Icon(Icons.image_not_supported, color: Colors.grey),
                  )
                : const Center(child: Icon(Icons.image, color: Colors.grey, size: 50)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['marca'].toString().toUpperCase(), style: const TextStyle(color: AppTheme.dourado, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(p['nome'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text('R\$ ${p['preco'].toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.vinho, fontWeight: FontWeight.w900, fontSize: 15)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _sendWhatsApp(p['nome']),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.vinho, minimumSize: const Size(double.infinity, 36), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('RESERVAR', style: TextStyle(fontSize: 12, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
