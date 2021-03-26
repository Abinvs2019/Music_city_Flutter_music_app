import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';

class PlaylistSong extends StatefulWidget {
  @override
  _PlaylistSongState createState() => _PlaylistSongState();
}

class _PlaylistSongState extends State<PlaylistSong> {
  List<PlaylistInfo> playlist = [];
  final ScrollController _scroll = ScrollController();
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> songs = [];

  getSongs() async {
    songs = await audioQuery.getSongs();
  }

  getPlaylist() async {
    playlist = await audioQuery.getPlaylists();
  }

  getPlaySongs() async {
    songs = await audioQuery.getSongsFromPlaylist(playlist: playlist[0]);
  }

  @override
  void initState() {
    super.initState();
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
                  'android/assets/images/Apple-Music-artist-promo.jpg')),
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
          onTap: () {},
        ),
      ),
    );
  }
}
