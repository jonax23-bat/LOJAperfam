import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';

class CheckoutPage extends StatefulWidget {
  final String planId;
  final String planName;
  final String planPrice;

  const CheckoutPage({
    super.key,
    required this.planId,
    required this.planName,
    required this.planPrice,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isProcessing = false;
  String _processingMethod = '';

  Future<void> _processPayment(String method) async {
    setState(() {
      _isProcessing = true;
      _processingMethod = method;
    });

    // Simulando o tempo de processamento de uma API real de pagamentos (Mercado Pago / RevenueCat)
    await Future.delayed(const Duration(seconds: 3));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Na vida real, o Webhook do Mercado Pago atualizaria o Firestore. 
        // Aqui simulamos a atualização do plano como se o pagamento tivesse sido aprovado instantaneamente.
        await FirebaseFirestore.instance.collection('resellers').doc(user.uid).update({
          'plan': widget.planId,
        });

        if (mounted) {
          _showSuccessDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no pagamento: $e')));
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text('Pagamento Aprovado!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.vinho)),
            const SizedBox(height: 8),
            Text('Sua assinatura do plano ${widget.planName} foi ativada com sucesso.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Fecha diálogo
                Navigator.pop(context, true); // Volta para a tela anterior com sucesso (true)
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dourado),
              child: const Text('Ir para o Painel', style: TextStyle(color: AppTheme.vinho, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Finalizar Assinatura', style: TextStyle(color: AppTheme.dourado, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.vinho,
        iconTheme: const IconThemeData(color: AppTheme.dourado),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppTheme.vinho),
                  const SizedBox(height: 24),
                  Text(
                    _processingMethod == 'pix' ? 'Gerando PIX seguro...' : 'Conectando ao Google Play...',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.vinho),
                  ),
                  const SizedBox(height: 8),
                  const Text('Por favor, não feche o aplicativo.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_rounded, size: 60, color: AppTheme.dourado),
                  const SizedBox(height: 16),
                  const Text('Resumo do Pedido', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.vinho)),
                  const SizedBox(height: 24),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.vinho.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppTheme.vinho.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(widget.planName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.vinho)),
                        const SizedBox(height: 8),
                        Text(widget.planPrice, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.dourado)),
                        const SizedBox(height: 12),
                        const Text('Assinatura recorrente com cancelamento a qualquer momento.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  const Text('ESCOLHA COMO QUER PAGAR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 16),

                  // Botão Mercado Pago
                  ElevatedButton(
                    onPressed: () => _processPayment('pix'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009EE3), // Azul Mercado Pago
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pix_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Pagar via Mercado Pago (PIX)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Botão Google Play
                  ElevatedButton(
                    onPressed: () => _processPayment('google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Assinar via Google Play', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text('Pagamento 100% criptografado e seguro', style: TextStyle(fontSize: 12, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
