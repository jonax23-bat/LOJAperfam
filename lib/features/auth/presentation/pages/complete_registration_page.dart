import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../reseller/presentation/pages/dashboard_page.dart';
import '../../../reseller/presentation/pages/checkout_page.dart';

class CompleteRegistrationPage extends StatefulWidget {
  const CompleteRegistrationPage({super.key});

  @override
  State<CompleteRegistrationPage> createState() => _CompleteRegistrationPageState();
}

class _CompleteRegistrationPageState extends State<CompleteRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController();
  
  String _selectedPlan = 'teste_7dias'; // 'teste_7dias', 'mensal', etc.
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      _nameController.text = user.displayName!;
    }
  }

  Future<void> _completeRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Se a pessoa escolheu um plano pago, ela entra provisoriamente com o plano de teste
        // até que o pagamento seja processado pelo Checkout.
        final initialPlan = ['mensal', 'semestral', 'anual'].contains(_selectedPlan) ? 'teste_7dias' : _selectedPlan;
        
        await FirebaseFirestore.instance.collection('resellers').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'cpf': _cpfController.text.trim(),
          'plan': initialPlan,
          'email': user.email,
          'storeName': 'Loja de ${_nameController.text.trim().split(' ').first}',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (mounted) {
          if (initialPlan != _selectedPlan) {
            final planNames = {'mensal': 'Plano Mensal', 'semestral': 'Plano Semestral', 'anual': 'Plano Anual'};
            final planPrices = {'mensal': 'R\$ 24,90', 'semestral': 'R\$ 129,90', 'anual': 'R\$ 229,90'};
            
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckoutPage(
                  planId: _selectedPlan,
                  planName: planNames[_selectedPlan]!,
                  planPrice: planPrices[_selectedPlan]!,
                ),
              ),
            );
          }
          
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Completar Cadastro', style: TextStyle(color: AppTheme.dourado, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.vinho,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Falta pouco!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.vinho)),
              const SizedBox(height: 8),
              const Text('Precisamos de mais alguns dados para enviar os pedidos dos clientes diretamente para o seu WhatsApp.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'WhatsApp (com DDD)',
                  hintText: 'Ex: 11999999999',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val == null || val.length < 10 ? 'Telefone inválido' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _cpfController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'CPF',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val == null || val.length < 11 ? 'CPF inválido' : null,
              ),
              const SizedBox(height: 32),
              
              const Text('Escolha seu Plano', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.vinho)),
              const SizedBox(height: 16),
              
              _buildPlanCard(
                id: 'teste_7dias',
                title: 'Teste Grátis (7 Dias)',
                price: 'R\$ 0,00',
                description: 'Experimente todas as funcionalidades da plataforma gratuitamente por 7 dias.',
                icon: Icons.rocket_launch_rounded,
              ),
              const SizedBox(height: 12),
              _buildPlanCard(
                id: 'mensal',
                title: 'Plano Mensal',
                price: 'R\$ 24,90 / mês',
                description: 'Tenha controle total e limites expandidos.',
                icon: Icons.calendar_today_rounded,
              ),
              const SizedBox(height: 12),
              _buildPlanCard(
                id: 'semestral',
                title: 'Plano Semestral',
                price: 'R\$ 129,90 / 6 meses',
                description: 'Economize pagando a cada 6 meses.',
                icon: Icons.event_available_rounded,
              ),
              const SizedBox(height: 12),
              _buildPlanCard(
                id: 'anual',
                title: 'Plano Anual',
                price: 'R\$ 229,90 / ano',
                description: 'Maior desconto para uso ilimitado o ano todo.',
                icon: Icons.diamond_rounded,
              ),
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _completeRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.vinho,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('FINALIZAR E ACESSAR PAINEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({required String id, required String title, required String price, required String description, required IconData icon}) {
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
            Icon(icon, color: isSelected ? AppTheme.dourado : Colors.grey, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? AppTheme.vinho : Colors.black87)),
                      Text(price, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.vinho : Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
