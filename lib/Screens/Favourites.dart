import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app2/Screens/search.dart';
import 'package:flutter_app2/Screens/songsagain.dart';
import 'package:flutter_app2/player/player.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Favourites extends StatefulWidget {
  SongInfo songInfo;
  Function pausePlayer;
  final GlobalKey<MusicPlayerState> key;
  Favourites({this.key, this.songInfo, this.pausePlayer}) : super(key: key);
  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Favourites> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();
  double minmumvalue = 0.0, maximumvalue = 0.0, currentvalue = 0.0;
  String currentTime = '', endTime = '';
  var _songList;
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  List<SongInfo> songs;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  ///List of  SongsId
  ///
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

  double pi = 3.14;
  /////////////////////////

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());
    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  /////////madeChangeAttheFunctionNmaesetSongTOwidgetsetSong

  changeTrack(bool isNext) {
    print("ChangeTrackCalled");
    if (isNext) {
      print("ChangeTrack CurrentIndex $currentIndex");
      if (currentIndex != songs.length - 1) {
        currentIndex++;

        print("IndexValueDecrimented");
      }
    } else {
      if (currentIndex != 0) {
        currentIndex--;
        print("IndexValueIncrimented");
      }
    }
    setSong(songs[currentIndex]);
    setNameOntap(songs[currentIndex].title);
    setArtistOntap(songs[currentIndex].artist);
    print("SetSongCurrentIndex $currentIndex");
  }

  void setSong(SongInfo songInfo) async {
    songInfo = songInfo;
    await player.setUrl(songInfo.uri);
    currentvalue = minmumvalue;
    maximumvalue = player.duration.inMilliseconds.toDouble();
    setState(() {
      currentTime = getDuration(currentvalue);
      endTime = getDuration(maximumvalue);
    });
    isPlaying = false;
    changeState();
    player.positionStream.listen((duration) {
      currentvalue = duration.inMilliseconds.toDouble();
      setState(() {
        currentTime = getDuration(currentvalue);
///////////////////////////////////////////////////////iwrote toTestOn9;07AM,March:12
        if (currentvalue >= maximumvalue) {
          return changeTrack(true);
        }
        ///////////////////////////////
      });
    });
  }

  pausePlayer() {
    player.pause();
  }

  changeState() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      player.play();
    } else {
      player.pause();
    }
  }

  String titleS = "";

  setNameOntap(String title) {
    titleS = title;
  }

  String artistName = "";

  setArtistOntap(String artistname) {
    artistName = artistname;
  }

  final color1 = const Color(284756);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 45, left: 16),
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Playlist',
                  style: TextStyle(
                      color: Colors.black,
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
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            songs[index].artist,
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            splashColor: Colors.red,
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              var _songLists = await Hive.openBox('Musicbox');
                              setState(
                                () {
                                  _songLists.deleteAt(index);
                                },
                              );
                            },
                          ),
                          onTap: () {
                            widget.pausePlayer();

                            SongsAgain(
                              pausePlayer: pausePlayer,
                            );

                            currentIndex = index;

                            setNameOntap(songs[currentIndex].title);
                            setArtistOntap(songs[currentIndex].artist);

                            print(currentIndex);

                            Favourites(
                              songInfo: songs[currentIndex],
                              key: key,
                            );

                            setSong(
                              songs[currentIndex],
                            );

                            print(currentIndex);
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Text(
                          "No favourites for you...?",
                        ),
                      ),
              ),
            ],
          ),
          SlidingUpPanel(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(24.0),
              bottomLeft: Radius.circular(24.0),
              bottomRight: Radius.circular(24.0),
            ),
            backdropColor: color1,
            boxShadow: [],
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            minHeight: 100,
            // color: Colors.black,
            maxHeight: 1000,
            margin: const EdgeInsets.all(22.0),
            panel: Container(
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(40.0),
                  topRight: const Radius.circular(40.0),
                  bottomLeft: const Radius.circular(40.0),
                  bottomRight: const Radius.circular(40.0),
                ),
              ),
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
                                margin: EdgeInsets.fromLTRB(30, 10, 0, 0),
                                height: 60,
                                width: 350,
                                child: Center(
                                  child: Text(
                                    titleS,
                                    style: TextStyle(
                                        color: Colors.cyan[700],
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Container(
                                height: 50,
                                width: 200,
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                                child: Center(
                                  child: Text(
                                    artistName,
                                    style: TextStyle(
                                        color: Colors.cyan[700],
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
                                margin: EdgeInsets.fromLTRB(30, 10, 0, 0),
                                decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyan[700],
                                      blurRadius: 10,
                                      offset: Offset(4, 8), // Shadow position
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(
                                      'android/assets/images/gramaphoneIm.jpeg'),
                                  radius: 150,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 2,
                          width: 500,
                        ),
                        Container(
                          child: Column(
                            children: [
                              IconButton(
                                padding: EdgeInsets.fromLTRB(350, 0, 0, 20),
                                icon: Icon(Icons.shuffle),
                                color: Colors.green,
                                onPressed: () {},
                              ),
                              IconButton(
                                padding: EdgeInsets.fromLTRB(350, 0, 0, 0),
                                icon: Icon(Icons.favorite_outline_rounded),
                                color: Colors.green,
                                onPressed: () {},
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 10,
                                      offset: Offset(4, 8), // Shadow position
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 100,
                                width: 100,
                              ),
                              Slider(
                                inactiveColor: Colors.teal,
                                activeColor: Colors.redAccent,
                                min: minmumvalue,
                                max: maximumvalue,
                                value: currentvalue,
                                onChanged: (value) {
                                  currentvalue = value;

                                  player.seek(
                                    Duration(
                                      milliseconds: currentvalue.round(),
                                    ),
                                  );
                                  if (currentvalue >= maximumvalue) {
                                    changeTrack(true);
                                  }
                                },
                              ),
                              Container(
                                transform: Matrix4.translationValues(0, -5, 0),
                                margin: EdgeInsets.fromLTRB(5, 0, 5, 15),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      currentTime,
                                      style: TextStyle(
                                          color: Colors.teal[800],
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 342,
                                    ),
                                    Text(
                                      endTime,
                                      style: TextStyle(
                                          color: Colors.teal[800],
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(60, 0, 60, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      child: Icon(Icons.skip_previous_outlined,
                                          color: Colors.cyan[700], size: 55),
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        changeTrack(false);
                                      },
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                          isPlaying
                                              ? Icons
                                                  .pause_circle_filled_rounded
                                              : Icons.play_circle_fill_rounded,
                                          color: Colors.red,
                                          size: 85),
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        changeState();
                                      },
                                    ),
                                    GestureDetector(
                                      child: Icon(Icons.skip_next_outlined,
                                          color: Colors.cyan[700], size: 55),
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        changeTrack(true);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // color: Colors.pink[900],
            ),
            collapsed: Container(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.skip_previous_outlined,
                                  size: 50,
                                ),
                                onPressed: () {
                                  changeTrack(true);
                                  print("ChangeTrackTrueCalled");
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                    isPlaying
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.play_circle_fill_rounded,
                                    color: Colors.red,
                                    size: 50),
                                onPressed: () {
                                  changeState();
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.skip_next_outlined,
                                  size: 50,
                                ),
                                onPressed: () {
                                  changeTrack(false);
                                  print("ChangeTrackFalseCalled");
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 4,
                          height: 4,
                        ),
                        Container(
                          width: 250,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 6.5,
                                height: 6.5,
                              ),
                              Text(
                                titleS,
                                style: TextStyle(
                                  fontFamily: 'DancingScript',
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                artistName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.rotate(
                          angle: 270 * pi / 180,
                          child: IconButton(
                            icon: Icon(
                              Icons.double_arrow_sharp,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text("Slide Up"),
                              ));
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: new Icon(
              Icons.home,
              color: Colors.green,
            ),
            title: Text(
              'Home',
              style: TextStyle(color: Colors.green),
            ),
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(onTap: () {
              Navigator.pop(context);
              child:
              Icon(
                Icons.playlist_play,
                color: Colors.green,
              );
            }),
            title: Text(
              'Playlist',
              style: TextStyle(color: Colors.red),
            ),
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    (MaterialPageRoute(builder: (context) => SearchScreen())));
              },
              child: Icon(
                Icons.search,
                color: Colors.green,
              ),
            ),
            title: Text(
              'Search',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
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
