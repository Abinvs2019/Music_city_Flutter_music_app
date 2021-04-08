import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app2/Playlist/playList.dart';
import 'package:flutter_app2/Screens/songsagain.dart';
import 'package:flutter_app2/mainScreen.dart';
import 'package:flutter_app2/model/hive_helper.dart';
import 'package:flutter_app2/player/player.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final GlobalKey<SongsStateagain> key = GlobalKey<SongsStateagain>();
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  final TextEditingController _searchText = new TextEditingController();
  List<SongInfo> songs = [];
  int currentIndex = 0;

  void initState() {
    super.initState();
    searhSong();
    songs = songs;
  }

  void getTracks() async {
    songs = await audioQuery.getSongs();
    setState(() {
      songs = songs;
    });
  }

  searhSong() async {
    songs = await audioQuery.searchSongs(query: _searchText.text);
  }

  final color = const Color(0xff284756);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        backgroundColor: color,
        title: TextField(
          controller: _searchText,
          onChanged: (value) {
            setState(
              () {
                searhSong();
              },
            );
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter a search',
          ),
        ),
      ),
      body:
          //  Column(
          //   children: [
          // TextField(
          //   // controller: _searchText,
          //   onChanged: (value) {
          //     setState(() {
          //       searhSong();
          //     });
          //   },
          //   decoration: InputDecoration(
          //       prefixIcon: Icon(
          //         Icons.search,
          //         color: Colors.teal[200],
          //       ),
          //       border: InputBorder.none,
          //       hintText: 'Enter a search term'),
          // ),
          _buildListViewSongs(),
      // "],"
      // bottomNavigationBar: BottomNavigationBar(
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: GestureDetector(onTap: () {
      //         Navigator.pop(context,
      //             MaterialPageRoute(builder: (context) => SongsAgain()));
      //         Icon(
      //           Icons.playlist_play,
      //           color: Colors.green,
      //         );
      //       }),
      //       title: Text(
      //         'Home',
      //         style: TextStyle(color: Colors.red),
      //       ),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: GestureDetector(onTap: () {
      //         Navigator.pop(
      //             context, MaterialPageRoute(builder: (context) => Playlist()));
      //         child:
      //         Icon(
      //           Icons.playlist_play,
      //           color: Colors.red,
      //         );
      //       }),
      //       title: Text(
      //         'Playlist',
      //         style: TextStyle(color: Colors.red),
      //       ),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: GestureDetector(
      //         onTap: () {},
      //         child: Icon(
      //           Icons.search,
      //           color: Colors.teal,
      //         ),
      //       ),
      //       title: Text(
      //         'Search',
      //         style: TextStyle(color: Colors.green),
      //       ),
      //     ),
      //   ],
    ) // ),
        // ),
        );
  }

  var savedList;
  Widget _buildListViewSongs() {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: songs.length,
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(
          backgroundImage: songs[index].albumArtwork == null
              ? AssetImage('android/assets/images/Apple-Music-artist-promo.jpg')
              : FileImage(
                  File(songs[index].albumArtwork),
                ),
        ),
        title: Text(
          songs[index].title,
          style: TextStyle(color: Colors.teal[200]),
        ),
        subtitle:
            Text(songs[index].artist, style: TextStyle(color: Colors.black)),
        trailing: IconButton(
          icon: Icon(
            Icons.favorite_outline,
            color: Colors.green,
          ),
          onPressed: () async {
            savedList = await Hive.openBox('Musicbox');
            var songFav = SongPlayList()..songInfo = songs[currentIndex].id;

            // print(songs[currentIndex].id);
            // print(songFav);
            print(songs[currentIndex].id);

            savedList.put(songs[currentIndex].id, songFav);
          },
        ),
        onTap: () {
          print("object");
          int currentIndex = index;
          MusicPlayer(
            songInfo: songs[currentIndex],
          );
        },
      ),
    );
  }
}
