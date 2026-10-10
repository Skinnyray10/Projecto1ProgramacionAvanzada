import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../widgets/brand_header.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.state});

  final AppState state;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final notice = widget.state.notice;
    if (notice != null) {
      widget.state.clearNotice();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showMessage(notice);
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await widget.state.login(_email.text, _password.text);
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const BrandHeader(
              title: 'Iniciar sesión',
              subtitle: 'Consulta piezas y existencias, con o sin internet.',
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                            labelText: 'Correo', prefixIcon: Icon(Icons.mail_outline)),
                        validator: (v) =>
                            (v == null || !v.contains('@')) ? 'Correo inválido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Escribe tu contraseña' : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _busy ? null : _submit,
                        child: _busy
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white))
                            : const Text('INGRESAR'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => RegisterScreen(state: widget.state))),
                        child: const Text('¿No tienes cuenta? Crear cuenta'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
