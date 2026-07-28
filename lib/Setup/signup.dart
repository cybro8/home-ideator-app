import 'package:flutter/material.dart';
import 'package:home_ideator_app/Setup/signin.dart';
import 'package:home_ideator_app/services/api_service.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String _email, _password;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(10.5)),
            Image.asset(
              'images/icon.png',
              width: 90.0,
              height:90.0,),
            TextFormField(
              validator: (String input) {
                if (input == null || input.isEmpty) return 'Please enter your email.';
                if (!RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$').hasMatch(input))
                  return 'Enter a valid email address.';
                return null;
              },
              onSaved: (input) => _email = input,
              decoration: InputDecoration(
                  labelText: 'Email-ID'
              ),
            ),
            TextFormField(
              validator: ( input){
                if(input.length<6){
                  return 'Your password must be 6 character';
                }
                return null;
              },
              onSaved: (input) => _password = input,
              decoration: InputDecoration(
                  labelText: 'Password'
              ),
              obscureText: true,
            ),
            RaisedButton(
              onPressed: _isLoading ? null : signUp,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signUp() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      setState(() => _isLoading = true);
      try {
        final username = _email.split('@')[0];
        await ApiService.register(username, _email, _password);
        
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
