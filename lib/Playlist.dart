import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app2/hive_helper.dart';
import 'package:flutter_app2/music_playing.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Playlist extends StatefulWidget {
  Function changeTrack;
  SongInfo songInfo;

  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> songs = [];
  int currentIndex = 0;
  String playlistBox;
  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Playlist"),
          leading: Icon(Icons.playlist_play),
          backgroundColor: Colors.black),
      body: Column(
        children: <Widget>[
          Expanded(child: _buildListView()),
        ],
      ),
    );
  }
}

Widget _buildListView() {
  return WatchBoxBuilder(
    box: Hive.box("Musicbox"),
    builder: (context, musicBox) {
      return ListView.builder(
        itemCount: musicBox.length,
        itemBuilder: (context, index) {
          final musicInfo = musicBox.getAt(index) as Hive_helper;
          return ListTile(
            leading: CircleAvatar(
                backgroundImage: AssetImage(
                    'android/assets/images/Apple-Music-artist-promo.jpg')),
            title: Text(musicInfo.title),
            subtitle: Text(musicInfo.detail),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {},
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MusicPlayer(),
                ),
              );
            },
          );
        },
      );
    },
  );
}
