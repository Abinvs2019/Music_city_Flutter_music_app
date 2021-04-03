import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Playlist extends StatefulWidget {
  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  TextEditingController _textFieldController = TextEditingController();
  void addPlayListName() {
    final playListName = Hive.box("$_textFieldController.text");
    playListName.add("");
  }

  List playlistNmaes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Create Playlist'),
                    content: TextField(
                      controller: _textFieldController,
                      // Only numbers can be entered

                      decoration: InputDecoration(
                          hintText: "Enter The Name of Playlist"),
                    ),
                  ));
        },
      ),
    );
  }
}
