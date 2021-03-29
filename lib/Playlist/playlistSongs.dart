import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';

class PlaylistSong extends StatefulWidget {
  @override
  _PlaylistSongState createState() => _PlaylistSongState();
}

class _PlaylistSongState extends State<PlaylistSong> {
  String playListName;

  getPlaylistName(String name) {
    playListName = name;
  }

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
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          FutureBuilder(
            builder: (_, songSnapShot) => songSnapShot.hasData
                ? ListView.builder(
                    itemCount: songSnapShot.data.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (_, index) => ListTile(
                      tileColor: Colors.black38,
                      leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              'https://images.macrumors.com/t/sqodWOqvWOvq6cU8t2ahMlU4AJM=/1600x0/article-new/2018/05/apple-music-note.jpg')),
                      title: Text(""),
                      subtitle: Text(
                        "",
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        splashColor: Colors.red,
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          var _songLists = await Hive.openBox('$playListName');
                          setState(() {
                            _songLists.deleteAt(index);
                          });
                        },
                      ),
                      onTap: () {},
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Text(
                      "No favourites for you...?",
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
