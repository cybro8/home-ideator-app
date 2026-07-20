import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_ideator_app/Setup/signin.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String _email, _password;
  bool _isLoading = false;
  final DBRef = FirebaseDatabase.instance.reference();
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
                // BUG FIX: Only checking isEmpty misses invalid email formats.
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
              },
              onSaved: (input) => _password = input,
              decoration: InputDecoration(
                  labelText: 'Password'
              ),
              obscureText: true,
            ),
            // BUG FIX: Button label said 'Sign in' instead of 'Sign Up'.
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
        final FirebaseUser user = (await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: _email, password: _password))
            .user;
        await user.sendEmailVerification();
        final String uid = user.uid;
        // BUG FIX: Initial Voltage and Current values were 'O' (the letter)
        // instead of '0' (zero). This caused display and parsing errors.
        await DBRef.child('user').child(uid).child('Device1').set({
          'Voltage': '0',
          'Current': '0',
          'Power': '0',
          'Name': 'Device1',
          'Website': '',
        });
        debugPrint('Created user: $uid');
        // BUG FIX: The original code called Navigator.pop() then push(), which
        // would crash if the Sign Up page was the only route on the stack.
        // Using pushReplacement navigates to LoginPage cleanly.
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
