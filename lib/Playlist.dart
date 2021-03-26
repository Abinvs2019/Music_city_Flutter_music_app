import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app2/hive_helper.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_app2/songsagain.dart';

class Favourites extends StatefulWidget {
  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Favourites> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  int currentIndex = 0;
  final GlobalKey<SongsStateagain> key = GlobalKey<SongsStateagain>();

  var _songList;

  List<SongInfo> songs;

  ///List of  SongsId
  List<String> songIds = [];
  getData() async {
    _songList = await Hive.openBox('Musicbox');
    print("Started");
    print(_songList);
    _songList.values.forEach((songId) {
      print(songId.songInfo);
      print("dsndni");
      songIds.add(songId.songInfo);
    });
    songs = await audioQuery.getSongsById(ids: songIds);
    print(songs);
    return songs;
  }

  /////////////////////////
  @override
  void initState() {
    super.initState();
    getData();
  }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: Text("Playlist"),
//           leading: Icon(Icons.playlist_play),
//           backgroundColor: Colors.black),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: _buildListView(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildListView() {
//     return WatchBoxBuilder(
//       box: Hive.box("Musicbox"),
//       builder: (context, musicBox) {
//         return ListView.builder(
//           itemCount: musicBox.length,
//           itemBuilder: (context, index) {
//             final musicInfo = musicBox.getAt(index) as SongPlayList;
//             print(musicInfo);
//             return ListTile(
//                 leading: CircleAvatar(
//                   backgroundImage: AssetImage(
//                       'android/assets/images/Apple-Music-artist-promo.jpg'),
//                 ),
//                 title: Text("songs[index].title"),
//                 subtitle: Text("Favourites"),
//                 trailing: IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed: () {
//                     musicBox.deleteAt(index);
//                   },
//                 ),
//                 onTap: () {});
//           },
//         );
//       },
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 45, left: 16),
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Playlist',
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          FutureBuilder(
            future: getData(),
            builder: (_, songSnapShot) => songSnapShot.hasData
                ? ListView.builder(
                    itemCount: songSnapShot.data.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (_, index) => ListTile(
                      tileColor: Colors.black38,
                      leading: CircleAvatar(
                        backgroundImage: songs[index].albumArtwork == null
                            ? NetworkImage(
                                'https://images.macrumors.com/t/sqodWOqvWOvq6cU8t2ahMlU4AJM=/1600x0/article-new/2018/05/apple-music-note.jpg')
                            : FileImage(File(songs[index].albumArtwork)),
                      ),
                      title: Text(
                        songs[index].title,
                      ),
                      subtitle: Text(
                        songs[index].artist,
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      trailing: IconButton(
                        splashColor: Colors.red,
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          var _songLists = await Hive.openBox('myBox');
                          setState(() {
                            _songLists.deleteAt(index);
                          });
                        },
                      ),
                      onTap: () {
                        currentIndex = index;
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                SongsAgain(songInfo: songs[index], key: key)));
                      },
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Text(
                      "Empty",
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
