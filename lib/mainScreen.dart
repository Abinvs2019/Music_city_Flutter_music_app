import 'package:flutter/material.dart';
import 'package:flutter_app2/Screens/Favourites.dart';
import 'package:flutter_app2/Screens/search.dart';
import 'package:flutter_app2/Screens/songsagain.dart';
import 'package:flutter_icons/flutter_icons.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = <Widget>[
    SongsAgain(),
    Favourites(),
    SearchScreen(),
  ];

  final color = const Color(0xff284756);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: color,
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Feather.home,
            ),
            title: Text('HOME'),
            activeIcon: Icon(
              Feather.home,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.playlist_play,
            ),
            title: Text('CALENDAR'),
            activeIcon: Icon(
              Icons.playlist_play,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              EvilIcons.search,
              size: 36,
            ),
            title: Text('PROFILE'),
            activeIcon: Icon(
              EvilIcons.search,
              size: 36,
            ),
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
