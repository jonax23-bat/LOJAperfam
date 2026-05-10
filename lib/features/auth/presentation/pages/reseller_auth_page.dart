import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../reseller/presentation/pages/dashboard_page.dart';
import '../../../reseller/presentation/pages/admin_dashboard_page.dart';
import 'complete_registration_page.dart';

class ResellerAuthPage extends StatefulWidget {
  const ResellerAuthPage({super.key});

  @override
  State<ResellerAuthPage> createState() => _ResellerAuthPageState();
}

class _ResellerAuthPageState extends State<ResellerAuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    // LOGIN MESTRE (ZETTA-HUB) -> Direto para o Admin Dashboard
    if (email == 'admin@zettahub.com.br' && password == 'ZettaAdmin@2024') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardPage()));
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Preencha todos os campos.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        await _handleLoginSuccess(userCredential.user!);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Acesso não autorizado ou erro de conexão.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: '62052744777-t1rj5m5u8d0sar2foeov0g0qupkl9ct1.apps.googleusercontent.com',
      ).signIn();
      
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // Usuário cancelou
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _handleLoginSuccess(userCredential.user!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro Google: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLoginSuccess(User user) async {
    if (user.email == 'admin@zettahub.com.br') {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardPage()));
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('resellers').doc(user.uid).get();
      if (doc.exists && doc.data()!.containsKey('phone') && doc.data()!['phone'].toString().isNotEmpty) {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CompleteRegistrationPage()));
        }
      }
    } catch (e) {
      if (mounted) {
        // Fallback for offline/errors
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.vinho,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Image.asset('assets/logo.png', height: 120),
                const SizedBox(height: 16),
                const Text('Zetta Vitrine - Acesso', style: TextStyle(fontSize: 20, color: AppTheme.vinho, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline, color: AppTheme.vinho),
                    labelText: 'Usuário / E-mail',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_open_rounded, color: AppTheme.vinho),
                    labelText: 'Senha de Acesso',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.vinho),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
                
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.vinho,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ENTRAR COM E-MAIL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OU', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: const FaIcon(FontAwesomeIcons.google, color: Colors.redAccent, size: 20),
                  label: const Text('ENTRAR COM GOOGLE', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    side: BorderSide(color: Colors.grey.shade300, width: 2),
                  ),
                ),
                
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage())),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    side: const BorderSide(color: AppTheme.dourado),
                  ),
                  child: const Text('ENTRAR COMO CONVIDADO', style: TextStyle(color: AppTheme.dourado, fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Sair do Modo Gestão', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
