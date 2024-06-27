import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import "package:simple_icons/simple_icons.dart";
import 'package:url_launcher/url_launcher.dart';

import 'LoadingIndicatorDialog.dart';

class FeedoSignup extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedo / Sign Up',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // Default mode
      home: SignupPage(),
    );
  }

  static final lightTheme = ThemeData(
    primarySwatch: Colors.deepPurple,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.light,
  );


  static final darkTheme = ThemeData(
    primarySwatch: Colors.deepPurple,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.dark,
  );
}

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  void _signup() {
    String email = _emailController.text;
    String name = _nameController.text;
    String surname = _surnameController.text;

    if(email == '' || name == '' || surname == ''){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Empty fields'),
            content: const Text('Please fill in all fields.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Oooops'),
              ),
            ],
          );
        },
      );
    }
    else{
      if(!EmailValidator.validate(email)){
        _showEmailInvalidAlertDialog(context);
      }
      else{
        LoadingIndicatorDialog().show(context);
        doSignup(email, name, surname).then((value) {
          //print("I'm here");
          LoadingIndicatorDialog().dismiss();
          print(value);
          if(value == 'conn_err' || value == 'soft_conn_err'){
            const snackBar = SnackBar(
              content: Text('Connection error... retry in a few minutes.'),
              backgroundColor: Colors.deepPurple,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          else{
            if(value == 'duplicate'){
              print("signup error duplicate mail");
              _showEmaiDuplicateAlertDialog(context);
            }
            else
              if(value == 'ok'){
                print('account created');
                _showAccountCreatedAlertDialog(context, email);
              }
              else{
                print('signup error');
                _showSignupErrorAlertDialog(context);
              }

          }
        });
      }


    }


  }

  Future<String> doSignup(String email, String name, String surname) async {
    try{
      final response = await http.post(
          Uri.parse(
              "https://#.azurewebsites.net/api/users/do-signup"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'name': name,
            'surname': surname,
          })
      );
      print(response.statusCode);
      if (response.statusCode == 200) {

        //print(response.body);
        return response.body;
      } else {

        return 'soft_conn_err';
        //throw Exception('Failed to reach server.');
      }
    } catch (e) {
      // Handle connection errors
      print('Error during signup: $e');
      // Return a message or null based on your requirements
      return 'conn_err';
    }
  }

  void _showEmailInvalidAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid e-mail'),
          content: Text('Please provide a geniune, correctly-formatted email.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showEmaiDuplicateAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('This e-mail is already registered'),
          content: Text('Please either try a different e-mail address or do a password recovery.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAccountCreatedAlertDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Your account has been created!'),
          content: Text('Please check your inbox at $email to log-in'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSignupErrorAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('An error occurred'),
          content: Text('Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordInfoAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No password required'),
          content: Text('Your password will be sent to you via e-mail so that I don\'t have to write front end + back end checks for it.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchGitHubUrl() async {
    final Uri _url = Uri.parse('https://github.com/YuriBrandi');
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedo / Sign Up'),
        actions: <Widget>[
          IconButton.outlined(
              onPressed: _launchGitHubUrl,
              icon: const Icon(SimpleIcons.github)),
          const SizedBox(width: 10.0),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              //'assets/images/feedo_logo_light.png',
              Theme.of(context).brightness == Brightness.light
                  ? 'assets/images/feedo_logo.png'
                  : 'assets/images/feedo_logo_light.png',
              height: 200,
            ),
            const SizedBox(height: 60.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'E-mail',
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _surnameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Surname',
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                   _showPasswordInfoAlertDialog(context);
                },
                child: const Text('Where\'s the password field?'),
              ),
            ),
            const SizedBox(height: 20.0),

            IconButton.filledTonal(
              onPressed: _signup,
              icon: const Icon(Icons.person_add_alt),

            ),

            const SizedBox(height: 15),

            const Text(
              '- Already Signed Up? -',
              style: TextStyle(
                fontSize: 20.0, // insert your font size here
              ),
            ),

            const SizedBox(height: 15),

            FilledButton.tonalIcon(
              onPressed: (){
                Navigator.pop(context);
              },
              label: const Text('Log In'),
              icon: const Icon(Icons.login),
            ),
          ],
        ),
      ),
    );
  }
}
