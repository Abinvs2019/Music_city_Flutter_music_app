import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app2/Playlist/playlistSongs.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';

class PlaylistO extends StatefulWidget {
  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<PlaylistO> {
  final ScrollController _scroll = ScrollController();
  List<SongInfo> songs = [];
  List<PlaylistInfo> playlist = [];
  int currentIndex;
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();

  getPlaylist() async {
    playlist = await audioQuery.getPlaylists();
    print("Got playlist");
    print(playlist);
  }

  @override
  void initState() {
    super.initState();
    getPlaylist();
    print("Init state");
    playlist = playlist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildListViewSongs(),
    );
  }

  Widget _buildListViewSongs() {
    return VsScrollbar(
      color: Colors.green,
      scrollDirection: Axis.horizontal,
      isAlwaysShown: true,
      thickness: 10,
      controller: _scroll,
      scrollbarFadeDuration: Duration(milliseconds: 500),
      scrollbarTimeToFade:
          Duration(milliseconds: 800), // default : Duration(milliseconds: 600)

      child: ListView.separated(
        controller: _scroll,
        separatorBuilder: (context, index) => Divider(),
        itemCount: playlist.length,
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(
                'android/assets/images/Apple-Music-artist-promo.jpg'),
          ),
          title: Text(
            playlist[index].name,
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(playlist[index].creationDate,
              style: TextStyle(color: Colors.white)),
          trailing: IconButton(
            icon: Icon(
              Icons.favorite_outline,
              color: Colors.green,
            ),
            onPressed: () {},
          ),
          onTap: () {
            Navigator.push(context,
                (MaterialPageRoute(builder: (context) => PlaylistSong())));
          },
        ),
      ),
    );
  }
}
