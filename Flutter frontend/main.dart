import 'package:feedo_flutter/action.dart';
import 'package:feedo_flutter/signup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:simple_icons/simple_icons.dart";
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoadingIndicatorDialog.dart';

void main() => runApp(FeedoApp());

class FeedoApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedo / Login',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // Default mode
      home: LoginPage(),
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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordObscured = true;

  @override
  void initState() {
    super.initState();
    _retrieveData();
  }

  void _login() {
    //Navigator.of(context).push(MaterialPageRoute(builder: (context) => FeedoAction()));
    //return;
    String email = _emailController.text;
    String password = _passwordController.text;

    if(email == '' || password == ''){
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
      LoadingIndicatorDialog().show(context);
      doLogin(email, password).then((value) {
        //print("I'm here");
        LoadingIndicatorDialog().dismiss();
        print(value);
        if(value == 'conn_err' || value == 'soft_conn_err'){
          const snackBar = SnackBar(
            content: Text('Connection error... retry in a few minutes.'),
            backgroundColor: Colors.deepPurple,
          );

          // Find the ScaffoldMessenger in the widget tree
          // and use it to show a SnackBar.
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        else{
          final body_response = json.decode(value);
          if(body_response.length == 0){
            print("failed login");
            _showLoginAlertDialog(context);
          }
          else if(body_response.length == 4){
            _saveData(email, password, body_response['name'], body_response['surname']);
            //Goto actino screen
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => FeedoAction()));
          }

        }
      });

      //print(resp);
    }


  }

  Future<String> doLogin(String email, String password) async {
    try{
      final response = await http.post(
          Uri.parse(
              "https://#.azurewebsites.net/api/users/do-login"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'password': password,
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
      print('Error during login: $e');
      // Return a message or null based on your requirements
      return 'conn_err';
    }
  }

  void _retrieveData() async{
      final prefs = await SharedPreferences.getInstance();
      String email_d = prefs.getString('email') ?? "";
      String password_d = prefs.getString('password') ?? "";

      _emailController.text = email_d;
      _passwordController.text = password_d;
  }

  void _saveData(String email, String password, String name, String surname) async{
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setString('name', name);
    await prefs.setString('surname', surname);

    print("login data saved");

  }

  void _resetPassw(){
    String email = _emailController.text;

    if(email == ''){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Empty email field'),
            content: const Text('Please fill in the email field.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    }
    else{

      LoadingIndicatorDialog().show(context);
      doReset(email).then((value) {
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
          if(value == 'error_mail') {
            print("email not registered");
            _showResetWrongEmailAlertDialog(context);
          }
          else
            if(value == 'done'){
              print("email reset");
              _showResetAlertDialog(context);
            }
            else{
              print("reset error");
              _showResetFailedAlertDialog(context);
            }

        }
      });
    }
  }

  Future<String> doReset(String email) async {
    try{
      final response = await http.post(
          Uri.parse(
              "https://#.azurewebsites.net/api/users/do-recover"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
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
      print('Error during reset: $e');
      // Return a message or null based on your requirements
      return 'conn_err';
    }
  }

  void _showLoginAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login failed'),
          content: Text('Please check you credentials or reset your password.'),
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

  void _showResetAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Password reset'),
          content: Text('Please check your email inbox.'),
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

  void _showResetWrongEmailAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unable to recover'),
          content: Text('Your email address has not been registered yet.'),
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

  void _showResetFailedAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset failed'),
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
        title: const Text('Feedo / Login'),
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
              controller: _passwordController,
              obscureText: _passwordObscured,
              decoration:  InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    _passwordObscured
                        ? Icons.visibility
                        : Icons.visibility_off,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColorLight,
                  ),
                  onPressed: () {
                    // Update the state i.e. toogle the state of passwordVisible variable
                    setState(() {
                      _passwordObscured = !_passwordObscured;
                    });
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _resetPassw,
                child: const Text('Forgot it? Reset it.'),
              ),
            ),
            const SizedBox(height: 20.0),

            IconButton.filledTonal(
                onPressed: _login,
                icon: const Icon(Icons.login),

            ),

            const SizedBox(height: 15),

            const Text(
              '- No Account Yet? -',
              style: TextStyle(
                fontSize: 20.0, // insert your font size here
              ),
            ),

            const SizedBox(height: 15),

            FilledButton.tonalIcon(
              onPressed: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignupPage()),);
              },
              label: const Text('Sign Up Instead'),
              icon: const Icon(Icons.account_circle_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
