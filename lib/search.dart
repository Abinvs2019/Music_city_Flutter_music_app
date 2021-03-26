import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app2/songsagain.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final GlobalKey<SongsStateagain> key = GlobalKey<SongsStateagain>();
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  final TextEditingController _searchText = new TextEditingController();
  List<SongInfo> songs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchText,
          decoration: InputDecoration(
              border: InputBorder.none, hintText: 'Enter a search term'),
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () {})
        ],
      ),
      body: _buildListViewSongs(),
    );
  }

  searhSong() async {
    songs = await audioQuery.searchSongs(query: _searchText.text);
  }

  void initState() {
    super.initState();
    searhSong();
    songs = songs;
  }

  Widget _buildListViewSongs() {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: songs.length,
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(
          backgroundImage: songs[index].albumArtwork == null
              ? AssetImage('android/assets/images/Apple-Music-artist-promo.jpg')
              : FileImage(File(songs[index].albumArtwork)),
        ),
        title: Text(
          songs[index].title,
          style: TextStyle(color: Colors.white),
        ),
        subtitle:
            Text(songs[index].artist, style: TextStyle(color: Colors.white)),
        trailing: IconButton(
          icon: Icon(
            Icons.favorite_outline,
            color: Colors.green,
          ),
          onPressed: () {
            // print("object");
            // final newMusic = Hive_helper(songinfo: songs[currentIndex].id);
            // addMusic(newMusic);
            // print(newMusic);

            // savedList.keys.contains(widget.songInfo.id);
          },
        ),
        onTap: () {
          int currentIndex = index;
          SongsAgain(
            songInfo: songs[currentIndex],
            key: key,
          );
        },
      ),
    );
  }
}
