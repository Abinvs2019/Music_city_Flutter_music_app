import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app2/music_playing.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class Songs extends StatefulWidget {
  @override
  _SongsState createState() => _SongsState();
}

class _SongsState extends State<Songs> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> songs = [];
  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();
  int currentIndex = 0;
  void initState() {
    super.initState();
    getTracks();
  }

  void getTracks() async {
    songs = await audioQuery.getSongs();
    setState(() {
      songs = songs;
    });
  }

  void changeTrack(bool isNext) {
    if (isNext) {
      if (currentIndex != songs.length - 1) {
        currentIndex++;
      }
    } else {
      if (currentIndex != 0) {
        currentIndex--;
      }
    }
    key.currentState.setSong(songs[currentIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "MUSIC CITY",
          style: TextStyle(
              color: Colors.green, fontSize: 35, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: songs.length,
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(
            backgroundImage: songs[index].albumArtwork == null
                ? AssetImage(
                    'android/assets/images/Apple-Music-artist-promo.jpg')
                : FileImage(File(songs[index].albumArtwork)),
          ),
          title: Text(
            songs[index].title,
            style: TextStyle(color: Colors.white),
          ),
          subtitle:
              Text(songs[index].artist, style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MusicPlayer(
                    changeTrack: changeTrack,
                    songInfo: songs[currentIndex],
                    key: key)));
            currentIndex = index;
          },
        ),
      ),
      backgroundColor: Colors.black,
      bottomNavigationBar:
          BottomNavigationBar(items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(
              Icons.headset,
              color: Colors.green,
            ),
            label: 'Home',
            backgroundColor: Colors.black),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_outline,
              color: Colors.green,
            ),
            label: 'Favourits',
            backgroundColor: Colors.black),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.playlist_play_outlined,
              color: Colors.green,
            ),
            label: 'Playlist',
            backgroundColor: Colors.black),
      ], backgroundColor: Colors.black),
    );
  }
}
