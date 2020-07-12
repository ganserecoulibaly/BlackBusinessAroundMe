import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'commerce.dart';
import 'dart:async';
import 'homepage.dart';
import 'wanted.dart';


void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/wanted': (context) => wanted ("Nouveau business"),
        '/homepage': (context) => HomePage(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Black Business Around Me',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'Black Business Around Me'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {


  Location location;
  LocationData locationData;
  Stream<LocationData> stream;
  Future<LocationData> currentLocation;
  double zoomVal = 5.0;

  @override
  void initState() {
    super.initState();
    //location = new Location();
    //currentLocation = location.getLocation();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
      ),
    );
  }
}
