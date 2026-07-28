import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_ideator_app/Setup/signin.dart';
import 'package:home_ideator_app/Setup/signup.dart';

import 'package:home_ideator_app/dashboard.dart';
import 'package:home_ideator_app/services/auth_state.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final loggedIn = await AuthState.isLoggedIn();
    if (loggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Dashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Ideator'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Image.asset(
            'images/icon.png',
            width: 90.0,
            height:90.0,),
          //new Padding(padding: new EdgeInsets.all(10.5)),
           Container(
            alignment: Alignment.center,
            height: 180.0,
            width: 100,
            child:Column(
              children:<Widget>[
           CupertinoButton(
            color: Colors.blue,
            onPressed: NavigatetoSignIn,
            child: Text('Sign In'),
          ),
          Padding(padding: EdgeInsets.all(10.5)),
                CupertinoButton(
            color: Colors.blue,
            onPressed: NavigatetoSignUp,
            child: Text('SignUp',
            ),
          ),
  ]
            ),
          )
        ],
      ),
    );
  }


  void NavigatetoSignIn() {
    Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginPage()));
  }

  void NavigatetoSignUp() {
    Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUp()));
  }
}
