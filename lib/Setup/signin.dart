import 'package:flutter/material.dart';
import 'package:home_ideator_app/dashboard.dart';
import 'package:home_ideator_app/services/api_service.dart';

class LoginPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  String _email, _password;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text('Sign in'),
     ),
     body: Form(
       key: _formKey,
       child: Column(
         children: <Widget>[
           Padding(padding:EdgeInsets.all(10.5)),
           Image.asset(
             'images/icon.png',
             width: 90.0,
             height:90.0,),
           TextFormField(
             validator: (input){
               if(input == null || input.isEmpty) return 'Please enter your email.';
               if(!RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$').hasMatch(input))
                 return 'Enter a valid email address.';
               return null;
             },
             onSaved: (input) => _email = input,
             decoration: InputDecoration(
               labelText: 'Email-ID'
             ),
           ),
           TextFormField(
             validator: (input){
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
           onPressed: _isLoading ? null : signin,
           child: _isLoading
               ? const SizedBox(
                   width: 20,
                   height: 20,
                   child: CircularProgressIndicator(strokeWidth: 2))
               : const Text('Sign in'),
         ),
         ],
       ),
     ),
   );
  }

  Future<void> signin() async {
    final formState = _formKey.currentState;
    if(formState.validate()){
      formState.save();
      setState(() => _isLoading = true);
      try{
        await ApiService.login(_email, _password);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => Dashboard()));
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
