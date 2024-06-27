import 'dart:convert';

import 'package:feedo_flutter/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'LoadingIndicatorDialog.dart';

class FeedoAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedo / Actions',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      // Default mode
      home: ActionPage(),
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

class ActionPage extends StatefulWidget {
  @override
  _ActionPageState createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  late final String name, surname, email, password;
  String barTitle = "";
  String greeting = "";
  String desiredTimer = "";
  String timeToTrigger = "";
  String latestFed = "";
  DateTime newTimer = DateTime.now();
  bool isNewTimePicked = false;
  int deletionCounter = 0;

  @override
  void initState() {
    super.initState();
    _retrieveData();
    _updateGreeting();
  }

  void _retrieveData() async{
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? "";
    password = prefs.getString('password') ?? "";
    name = prefs.getString('name') ?? "";
    surname = prefs.getString('surname') ?? "";

    setState(() {
      barTitle = name;
    });

    _reloadTimers();
  }

  void _retrieveTimer(){
    LoadingIndicatorDialog().show(context);
    getDeviceTimer(email, password).then((value) {
      LoadingIndicatorDialog().dismiss();
      //print(value);
      if(value == 'conn_err' || value == 'soft_conn_err'){
       _showConnectionErrorBar(context);
      }
      else{
        final numericRegex =
        RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
        if(numericRegex.hasMatch(value)){
          //Dart's integers equals to Java's long.
          _getTimeToTrigger(int.parse(value));
          var dt = DateTime.fromMillisecondsSinceEpoch(int.parse(value));
          var date = DateFormat('dd/MM/yyyy - HH:mm').format(dt);

          setState(() {
            desiredTimer = date;
          });
        }
        else{
          _showGenericErrorDialog(context);
        }
      }
    });
  }

  void _getTimeToTrigger(var millisTimer){
    var diff = millisTimer - DateTime.now().millisecondsSinceEpoch;
    if(diff <= 0){
      setState(() {
        timeToTrigger = "Expired";
      });
    }
    else{
      // Calculate hours and minutes
      // ~/ performs an integer division.
      int hours = diff ~/ 3600000;
      int minutes = (diff % 3600000) ~/ 60;
      print("$hours:$minutes");

      if(hours > 99){
        setState(() {
          timeToTrigger = "4+ days";
        });
      }
      else{
        setState(() {
          timeToTrigger = "${hours.toString().padLeft(2, '0')}:${(minutes~/1000).toString().padLeft(2, '0')}";
        });
      }
    }
    
    print("$timeToTrigger -> $diff");
  }

  void _retrieveLastFed(){
    //LoadingIndicatorDialog().show(context);
    getDeviceLastTrigger(email, password).then((value) {
      //LoadingIndicatorDialog().dismiss();
      //print(value);
      if(value == 'conn_err' || value == 'soft_conn_err'){
        _showConnectionErrorBar(context);
      }
      else{
        final numericRegex =
        RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
        if(numericRegex.hasMatch(value)){
          //Dart's integers equals to Java's long.
          var dt = DateTime.fromMillisecondsSinceEpoch(int.parse(value));
          var date = DateFormat('dd/MM/yyyy - HH:mm').format(dt);

          setState(() {
            latestFed = date;
          });
        }
        else{
          _showGenericErrorDialog(context);
        }
      }
    });
  }

  void _updateNextFeeding(){
    LoadingIndicatorDialog().show(context);
    setNextTimer(email, password, newTimer.millisecondsSinceEpoch.toString()).then((value) {
      LoadingIndicatorDialog().dismiss();
      //print(value);
      if(value == 'conn_err' || value == 'soft_conn_err'){
        _showConnectionErrorBar(context);
      }
      else{
        if(value == "success"){
          //Dart's integers equals to Java's long.
          const snackBar = SnackBar(
            content: Text('Timer succesfully updated!'),
            backgroundColor: Colors.deepPurple,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          _reloadTimers();
        }
        else{
          _showGenericErrorDialog(context);
        }
      }
    });
  }

  void _logoutData() async{
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('email', "");
    await prefs.setString('password', "");
    await prefs.setString('name', "");
    await prefs.setString('surname', "");

    _switchToMain();
  }

  void _requestAccountDeletion(){
    _showAccountDeletionDialog(context);
    if(deletionCounter < 3) {
      return;
    }

    LoadingIndicatorDialog().show(context);
    doDeleteAccount(email, password).then((value) {
      LoadingIndicatorDialog().dismiss();
      //print(value);
      if(value == 'conn_err' || value == 'soft_conn_err'){
        _showConnectionErrorBar(context);
      }
      else{
        if(value == "done"){
          //Dart's integers equals to Java's long.
          _logoutData();
        }
        else{
          _showGenericErrorDialog(context);
        }
      }
    });
  }

  void _switchToMain() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => FeedoApp()));
  }

  void _reloadTimers() {
    _retrieveTimer();
    _retrieveLastFed();
  }

  void _showGenericErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('An error occured'),
          content: const Text('This shouldn\'t happen, please log out'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void _showConnectionErrorBar(BuildContext context){
    const snackBar = SnackBar(
      content: Text('Connection error... retry in a few minutes.'),
      backgroundColor: Colors.deepPurple,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showAccountDeletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
                'This action is irreversible',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
          ),
          content: const Text('Are you sure? Press 3 times \'YES\' to proceed.'),
          actions: [
            TextButton(
              onPressed: () {
                deletionCounter++;
                Navigator.of(context).pop();
                _showAccountDeletionDialog(context);
              },
              child: Text('YES (${deletionCounter + 1})'),
            ),
            TextButton(
              onPressed: () {
                deletionCounter = 0;
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _updateGreeting(){
    switch(TimeOfDay.now().hour){
      case >= 5 && < 14: greeting = "Good morning";break;
      case >= 14 && < 18: greeting = "Good evening";break;
      default: greeting = "Good night";
    }
  }

  Future<void> _launchGitHubUrl() async {
    final Uri _url = Uri.parse('https://github.com/YuriBrandi');
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _launchAPIDocs() async {
    final Uri _url = Uri.parse('https://#.azurestaticapps.net/');
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<String> getDeviceTimer(String email, String password) async {
    try{
      final response = await http.post(
          Uri.parse(
              "https://#.azurewebsites.net/api/devices/getTimer"),
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

        print("Device timer: ${response.body}");
        return response.body;
      } else {

        return 'soft_conn_err';
        //throw Exception('Failed to reach server.');
      }
    } catch (e) {
      // Handle connection errors
      print('Error in device timer retrieval: $e');
      // Return a message or null based on your requirements
      return 'conn_err';
    }
  }

  Future<String> getDeviceLastTrigger(String email, String password) async {
    try{
      final response = await http.post(
          Uri.parse(
              "https://#.azurewebsites.net/api/devices/getLastFed"),
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

        print("Device latest trigger: ${response.body}");
        return response.body;
      } else {

        return 'soft_conn_err';
        //throw Exception('Failed to reach server.');
      }
    } catch (e) {
      // Handle connection errors
      print('Error in device timer retrieval: $e');
      // Return a message or null based on your requirements
      return 'conn_err';
    }
  }

  Future<String> setNextTimer(String email, String password, String timer) async {
    print("updating to $timer");
    try{
      final response = await http.post(
          Uri.parse(
              "https://#.azurewebsites.net/api/devices/do-updateTimer"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'password': password,
            'timerValue': timer,
          })
      );
      print(response.statusCode);
      if (response.statusCode == 200) {

        print(response.body);
        return response.body;
      } else {

        return 'soft_conn_err';
        //throw Exception('Failed to reach server.');
      }
    } catch (e) {
      // Handle connection errors
      print('Error in device timer retrieval: $e');
      // Return a message or null based on your requirements
      return 'conn_err';
    }
  }

  Future<String> doDeleteAccount(String email, String password) async {
    try{
      final response = await http.post(
          Uri.parse(
              "https://#.azurewebsites.net/api/users/do-delete"),
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

        print(response.body);
        return response.body;
      } else {

        return 'soft_conn_err';
        //throw Exception('Failed to reach server.');
      }
    } catch (e) {
      // Handle connection errors
      print('Error in device timer retrieval: $e');
      // Return a message or null based on your requirements
      return 'conn_err';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$greeting, $barTitle."),
        actions: <Widget>[
          IconButton.outlined(
              onPressed: _launchGitHubUrl,
              icon: const Icon(SimpleIcons.github)),
          const SizedBox(width: 10.0),
          IconButton.outlined(
              onPressed: _logoutData,
              icon: const Icon(Icons.logout)),
          const SizedBox(width: 10.0),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Align(
          alignment: Alignment.center,
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
              const SizedBox(height: 40.0),

              const Icon(
                Icons.restaurant,
                color: Colors.deepPurple,
                size: 36.0,
              ),

              const SizedBox(height: 20.0),

              Table(
                //border: TableBorder.all(color: Colors.black),
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: [
                  TableRow(children: [
                    const Text(
                      "Next timer:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    Center(
                      child: Text(
                        desiredTimer,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    Text(
                      "($timeToTrigger)",
                      style: TextStyle(
                        fontSize: 20,
                        color: (() {
                          if (timeToTrigger == "Expired") {
                            return Colors.red;
                          } else {
                            return Colors.white;
                          }
                        })(),
                      ),
                    ),
                  ]),
                   TableRow(children: [
                    const SizedBox(height: 15.0),
                    Container(),
                    Container(),
                    Container(),
                    Container(),
                  ]),
                  TableRow(children: [
                    const Text(
                      "Last fed:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    Center(
                      child: Text(
                        latestFed,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    Container(),
                  ])
                ],
              ),
              const SizedBox(height: 20.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [

                  FilledButton.tonalIcon(
                    onPressed: () {
                      showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) => SizedBox(
                            height: 250,
                            child: CupertinoDatePicker(
                              initialDateTime: newTimer,
                              onDateTimeChanged: (DateTime pickedTime) {
                                setState(() => newTimer = pickedTime);
                                isNewTimePicked = true;
                              },
                              use24hFormat: true,
                            ),
                          ),
                      );
                    },
                    label: (() {
                      if (isNewTimePicked) {
                        return Text("${newTimer.day}/${newTimer.month} - ${newTimer.hour}:${newTimer.minute}");
                      } else {
                        return const Text('Pick date/time');
                      }
                    })(),
                    //label: const Text('Pick date/time'),
                    icon: const Icon(Icons.event),
                  ),
                  const SizedBox(width: 20.0),
                  FilledButton.tonalIcon(
                    onPressed: _updateNextFeeding,
                    label: const Text('Schedule timer'),
                    icon: const Icon(Icons.timer),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

              const Divider(),

              const SizedBox(height: 20.0),

              FilledButton.tonalIcon(
                onPressed: _reloadTimers,
                label: const Text('Refresh all values'),
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(height: 30.0),
              FilledButton.tonalIcon(
                onPressed: _logoutData,
                label: const Text('Logout'),
                icon: const Icon(Icons.logout),
              ),
              const SizedBox(height: 30.0),
              FilledButton.tonalIcon(
                onPressed: _requestAccountDeletion,
                label: const Text('Delete account'),
                icon: const Icon(Icons.delete_forever),
              ),
              const SizedBox(height: 30.0),
              FilledButton.tonalIcon(
                onPressed: _launchAPIDocs,
                label: const Text('Retrieve API docs'),
                icon: const Icon(CupertinoIcons.doc_append),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
