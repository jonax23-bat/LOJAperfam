import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import 'checkout_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedPlan = 'teste_7dias';
  String _originalPlan = 'teste_7dias'; // Para sabermos se houve mudança
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('resellers').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _storeNameController.text = data['storeName'] ?? 'Minha Loja';
          _phoneController.text = data['phone'] ?? '';
          _selectedPlan = data['plan'] ?? 'teste_7dias';
          _originalPlan = _selectedPlan;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    // Se a pessoa trocou para um plano pago, ela deve passar pelo Checkout!
    if (_selectedPlan != _originalPlan && ['mensal', 'semestral', 'anual'].contains(_selectedPlan)) {
      final planNames = {'mensal': 'Plano Mensal', 'semestral': 'Plano Semestral', 'anual': 'Plano Anual'};
      final planPrices = {'mensal': 'R\$ 24,90', 'semestral': 'R\$ 129,90', 'anual': 'R\$ 229,90'};
      
      final paymentSuccess = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            planId: _selectedPlan,
            planName: planNames[_selectedPlan]!,
            planPrice: planPrices[_selectedPlan]!,
          ),
        ),
      );

      // Se cancelou o checkout, interrompe o salvamento
      if (paymentSuccess != true) return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('resellers').doc(user.uid).update({
          'storeName': _storeNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          // O Checkout já salvou o plano, mas garantimos aqui de qualquer forma
          'plan': _selectedPlan, 
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configurações salvas com sucesso!')));
          Navigator.pop(context, true); 
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Configurações', style: TextStyle(color: AppTheme.dourado, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.vinho,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.dourado),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.vinho))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dados da Loja', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.vinho)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _storeNameController,
                      decoration: InputDecoration(
                        labelText: 'Nome da sua Loja',
                        hintText: 'Ex: Boutique da Ana',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'O nome não pode ser vazio' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'WhatsApp para Pedidos',
                        hintText: 'Ex: 11999999999',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (val) => val == null || val.length < 10 ? 'Telefone inválido' : null,
                    ),
                    const SizedBox(height: 32),
                    
                    const Text('Seu Plano de Assinatura', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.vinho)),
                    const SizedBox(height: 16),
                    
                    _buildPlanCard(
                      id: 'teste_7dias',
                      title: 'Teste Grátis',
                      price: 'Ativo',
                      icon: Icons.rocket_launch_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildPlanCard(
                      id: 'mensal',
                      title: 'Mensal',
                      price: 'R\$ 24,90 / mês',
                      icon: Icons.calendar_today_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildPlanCard(
                      id: 'semestral',
                      title: 'Semestral',
                      price: 'R\$ 129,90 / 6 meses',
                      icon: Icons.event_available_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildPlanCard(
                      id: 'anual',
                      title: 'Anual',
                      price: 'R\$ 229,90 / ano',
                      icon: Icons.diamond_rounded,
                    ),
                    
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.vinho,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('SALVAR ALTERAÇÕES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPlanCard({required String id, required String title, required String price, required IconData icon}) {
    final isSelected = _selectedPlan == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.dourado.withOpacity(0.1) : Colors.white,
          border: Border.all(color: isSelected ? AppTheme.dourado : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.dourado : Colors.grey, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? AppTheme.vinho : Colors.black87)),
                  Text(price, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.vinho : Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
