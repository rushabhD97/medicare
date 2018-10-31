import 'package:flutter/material.dart';

import 'package:medicare/doctors.dart';
import 'package:medicare/medicines.dart';
import 'package:medicare/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeDashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Center(
          child: Text(
        "Welcome To Medicare!!\nYour search for Medicines and Doctors ends here!",
        softWrap: true,
        style: TextStyle(
          color: Color.fromRGBO(119, 136, 153, 1.0),
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic
        ),
      )),
    );
  }
}

class DashboardPage extends StatefulWidget {
  final FirebaseUser currUser;
  DashboardPage(this.currUser);
  @override
  _DashboardPageState createState() => _DashboardPageState(this.currUser);
}

class _DashboardPageState extends State<DashboardPage> {
  FirebaseUser currUser;
  List<Widget> _children;
  _DashboardPageState(FirebaseUser currUser) {
    this.currUser = currUser;
    _children = [
      HomeDashPage(),
      DoctorsPage(),
      MedicinesPage(),
      ProfilePage(currUser),
    ];
  }
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: new Text("MediCare"),
        backgroundColor: Colors.blueGrey,
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        // fixedColor: Colors.blueGrey,
        currentIndex:
            _currentIndex, // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.local_hospital),
            title: new Text('Doctor'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.healing),
            title: new Text('Medicines'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile'),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
