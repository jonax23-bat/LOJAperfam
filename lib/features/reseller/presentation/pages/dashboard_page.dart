import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

import 'add_product_page.dart';
import 'settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _storeName = 'Minha Loja';

  @override
  void initState() {
    super.initState();
    _loadStoreName();
  }

  Future<void> _loadStoreName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('resellers').doc(user.uid).get();
      if (doc.exists && doc.data()!.containsKey('storeName')) {
        setState(() {
          _storeName = doc.data()!['storeName'];
        });
      }
    }
  }

  Future<void> _openSettings() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    if (updated == true) {
      _loadStoreName();
    }
  }

  void _shareViaWhatsApp(String uid) async {
    final baseUrl = Uri.base.origin; // Pega o domínio atual onde o app está rodando
    final link = '$baseUrl/?reseller=$uid';
    final text = Uri.encodeComponent('Olá! Venha conhecer os produtos da minha loja exclusiva! Acesse o link direto para o meu catálogo:\n$link');
    final url = 'https://wa.me/?text=$text';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Não foi possível abrir o WhatsApp.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.vinho,
        iconTheme: const IconThemeData(color: AppTheme.dourado),
        title: Text('$_storeName', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.dourado)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_rounded, color: AppTheme.dourado, size: 30),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShareCard(),
            const SizedBox(height: 24),
            const _ResumoCard(),
            const SizedBox(height: 24),
            Text(
              'Meus Produtos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Placeholder para a lista de produtos
            const _EmptyProductsState(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );
        },
        backgroundColor: AppTheme.vinho,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Novo Produto'),
      ),
    );
  }

  Widget _buildShareCard() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Desconhecido';
    final uid = user?.uid ?? 'Desconhecido';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.dourado.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dourado),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.share_rounded, color: AppTheme.dourado),
              SizedBox(width: 8),
              Text('COMPARTILHE SUA LOJA', style: TextStyle(color: AppTheme.dourado, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Peça para seus clientes se conectarem usando um destes dados:', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 12),
          Text('Seu ID: $uid', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.vinho)),
          const SizedBox(height: 8),
          Text('Seu E-mail: $email', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.vinho)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _shareViaWhatsApp(uid),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // Cor oficial do WhatsApp
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.share),
              label: const Text('COMPARTILHAR NO WHATSAPP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  const _ResumoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.vinho.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dourado.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Produtos', value: '0'),
          _StatItem(label: 'Reservas', value: '0'),
          _StatItem(label: 'Estoque', value: '0'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.vinho,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.pretoSuave.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppTheme.vinho.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum perfume cadastrado.\nToque no botão abaixo para começar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
