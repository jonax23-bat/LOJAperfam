import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Zetta Vitrine - Gestão', style: TextStyle(color: AppTheme.dourado, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.vinho,
        iconTheme: const IconThemeData(color: AppTheme.dourado),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded, color: AppTheme.dourado),
            onPressed: () => Navigator.pop(context), // Volta para o login
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('resellers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar revendedoras.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.vinho));
          }

          final allResellers = snapshot.data!.docs;
          
          final activeResellers = allResellers.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['plan'] != 'inativo';
          }).toList();

          final inactiveResellers = allResellers.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['plan'] == 'inativo';
          }).toList();

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  color: AppTheme.vinho,
                  child: const TabBar(
                    indicatorColor: AppTheme.dourado,
                    labelColor: AppTheme.dourado,
                    unselectedLabelColor: Colors.white70,
                    tabs: [
                      Tab(text: 'Contas Ativas'),
                      Tab(text: 'Contas Inativas'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(child: _buildStatCard(context, title: 'Ativas', value: activeResellers.length.toString(), icon: Icons.verified_user_rounded, color: Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard(context, title: 'Inativas', value: inactiveResellers.length.toString(), icon: Icons.block_rounded, color: Colors.redAccent)),
                    ],
                  ),
                ),
                _buildPlanBreakdown(activeResellers),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildResellerList(activeResellers),
                      _buildResellerList(inactiveResellers),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResellerList(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const Center(child: Text('Nenhuma revendedora nesta lista.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>;
        final uid = doc.id;
        final name = data['name'] ?? 'Sem Nome';
        final storeName = data['storeName'] ?? 'Loja Desconhecida';
        final email = data['email'] ?? '';
        final phone = data['phone'] ?? '';
        final plan = data['plan'] ?? 'teste_7dias';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(storeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.vinho)),
                    ),
                    _buildPlanDropdown(uid, plan),
                  ],
                ),
                const Divider(),
                Text('👤 Nome: $name', style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('✉️ E-mail: $email'),
                const SizedBox(height: 12),
                if (phone.toString().isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _contactReseller(phone),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.green),
                      label: Text('WhatsApp: $phone', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanDropdown(String uid, String currentPlan) {
    final validPlans = ['teste_7dias', 'embaixador', 'mensal', 'semestral', 'anual', 'inativo'];
    final safePlan = validPlans.contains(currentPlan) ? currentPlan : 'teste_7dias';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: safePlan == 'inativo' ? Colors.red.withOpacity(0.1) : AppTheme.dourado.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safePlan,
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.vinho),
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.vinho),
          onChanged: (String? newValue) {
            if (newValue != null) {
              FirebaseFirestore.instance.collection('resellers').doc(uid).update({'plan': newValue});
            }
          },
          items: const [
            DropdownMenuItem(value: 'teste_7dias', child: Text('Teste Grátis')),
            DropdownMenuItem(value: 'embaixador', child: Text('Embaixador', style: TextStyle(color: Colors.blue))),
            DropdownMenuItem(value: 'mensal', child: Text('Mensal')),
            DropdownMenuItem(value: 'semestral', child: Text('Semestral')),
            DropdownMenuItem(value: 'anual', child: Text('Anual')),
            DropdownMenuItem(value: 'inativo', child: Text('Inativo (Bloqueio)', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  void _contactReseller(String phone) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length == 10 || cleanPhone.length == 11) {
      cleanPhone = '55$cleanPhone';
    }
    final url = 'https://wa.me/$cleanPhone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPlanBreakdown(List<QueryDocumentSnapshot> activeResellers) {
    int teste = 0, embaixador = 0, mensal = 0, semestral = 0, anual = 0;

    for (var doc in activeResellers) {
      final data = doc.data() as Map<String, dynamic>;
      final plan = data['plan'] ?? 'teste_7dias';
      if (plan == 'teste_7dias') teste++;
      else if (plan == 'embaixador') embaixador++;
      else if (plan == 'mensal') mensal++;
      else if (plan == 'semestral') semestral++;
      else if (plan == 'anual') anual++;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.dourado.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppTheme.dourado.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Análise de Assinaturas (Ativas)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.vinho)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPlanChip('Teste 7D', teste, Colors.grey.shade700),
                  const SizedBox(width: 8),
                  _buildPlanChip('Embaixador', embaixador, Colors.blue),
                  const SizedBox(width: 8),
                  _buildPlanChip('Mensal', mensal, Colors.green),
                  const SizedBox(width: 8),
                  _buildPlanChip('Semestral', semestral, Colors.orange),
                  const SizedBox(width: 8),
                  _buildPlanChip('Anual', anual, Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          Text(count.toString(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
