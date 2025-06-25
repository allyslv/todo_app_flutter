import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'CalendarPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String email = '';
  String senha = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async {
    if (email.isEmpty || senha.isEmpty) {
      _showErrorDialog('Preencha todos os campos.');
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CalendarPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        _showErrorDialog('Formato de e-mail inválido.');
      } else if (e.code == 'invalid-credential') {
        _showErrorDialog('Usuário ou senha incorretos.');
      } else {
        _showErrorDialog('Erro: ${e.code}');
      }
    }
  }

  void _cadastrar() async {
    if (email.isEmpty || senha.isEmpty) {
      _showErrorDialog('Preencha todos os campos.');
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CalendarPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showErrorDialog('Este e-mail já está em uso.');
      } else if (e.code == 'weak-password') {
        _showErrorDialog('A senha precisa ter pelo menos 6 caracteres.');
      } else if (e.code == 'invalid-email') {
        _showErrorDialog('Formato de e-mail inválido.');
      } else {
        _showErrorDialog('Erro: ${e.code}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: Text('Erro'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fechar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCBF49),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_month_rounded, size: 64,
                    color: Color(0xFF003049)),
                SizedBox(height: 16),
                Text(
                  'To-do List',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                TextField(
                  onChanged: (text) => email = text,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (text) => senha = text,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF003049),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Entrar'),
                ),
                SizedBox(height: 12),
                TextButton(
                  onPressed: _cadastrar,
                  style: TextButton.styleFrom(foregroundColor: Color(0xFF003049)),
                  child: Text('Criar nova conta'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}