import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app2/Playlist/playList.dart';
import 'package:flutter_app2/Screens/Favourites.dart';
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
  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  final TextEditingController _searchText = new TextEditingController();
  List<SongInfo> songs = [];
  int currentIndex = 0;
  List<SongInfo> songsOfArtist;
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

    songsOfArtist = await audioQuery.searchSongs(
        query: _searchText.text, sortType: SongSortType.ALPHABETIC_ARTIST);
  }

  // final person = songs
  //     .artist
  //     .firstWhere((element) => element.name == personName, orElse: () {
  //   return null;
  // });
  final color = const Color(0xff284756);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        backgroundColor: color,
        title: TextField(
          style: TextStyle(color: Colors.white),
          controller: _searchText,
          onChanged: (value) {
            setState(
              () {
                searhSong();
              },
            );
          },
          decoration: InputDecoration(
            hintText: 'Enter a search',
            hintStyle: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
        ),
      ),
      body: _buildListViewSongs(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: color,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.home, color: Colors.black),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SongsAgain()));
              },
            ),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.favorite_outline_outlined, color: Colors.black),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Favourites()));
              },
            ),
            title: Text('Playlist'),
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.teal[200],
              ),
              onPressed: () {},
            ),
            title: Text('Search'),
          ),
        ],
      ),
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
          style: TextStyle(color: Colors.teal[200], fontSize: 20),
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

            print(songs[currentIndex].id);

            savedList.put(songs[currentIndex].id, songFav);
          },
        ),
        onTap: () {
          print("object");
          int currentIndex = index;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MusicPlayer(
                songInfo: songs[currentIndex],
                key: key,
              ),
            ),
          );
        },
      ),
    );
  }
}
