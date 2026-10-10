import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../widgets/brand_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.state});

  final AppState state;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await widget.state.register(
        fullName: _name.text,
        email: _email.text,
        password: _password.text,
      );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                const BrandHeader(
                  title: 'Crear cuenta',
                  subtitle: 'Si no hay internet, la cuenta se guarda y se crea al reconectar.',
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top,
                  right: 4,
                  child: const CloseButton(color: Colors.white),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          labelText: 'Nombre completo', prefixIcon: Icon(Icons.person_outline)),
                      validator: (v) =>
                          (v == null || v.trim().length < 3) ? 'Escribe tu nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          labelText: 'Correo', prefixIcon: Icon(Icons.mail_outline)),
                      validator: (v) => (v == null ||
                              !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim()))
                          ? 'Correo inválido'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline)),
                      validator: (v) =>
                          (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirm,
                      obscureText: true,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                          labelText: 'Confirmar contraseña',
                          prefixIcon: Icon(Icons.lock_outline)),
                      validator: (v) =>
                          v != _password.text ? 'Las contraseñas no coinciden' : null,
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
                          : const Text('CREAR CUENTA'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
