import 'dart:async';
import 'dart:io';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app2/Screens/Favourites.dart';
import 'package:flutter_app2/model/hive_helper.dart';
import 'package:flutter_app2/Screens/search.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SongsAgain extends StatefulWidget {
  SongInfo songInfo;
  Function pauseplayer;

  final GlobalKey<SongsStateagain> key;

  SongsAgain({this.songInfo, this.key, this.pauseplayer}) : super(key: key);

  @override
  SongsStateagain createState() => SongsStateagain();
}

class SongsStateagain extends State<SongsAgain>
    with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  final GlobalKey<SongsStateagain> key = GlobalKey<SongsStateagain>();
  final AudioPlayer player = AudioPlayer();
  List<SongInfo> songs = [];
  List<String> usersList = [];

  final pi = 3.14;
  bool isPlaying = false;
  double minmumvalue = 0.0, maximumvalue = 0.0, currentvalue = 0.0;
  String currentTime = '', endTime = '';
  int currentIndex = 0;
  String status = 'hidden';
  AnimationController _animControl;

  int _currentindex = 0;

  Icon playli = Icon(Icons.favorite, color: Colors.teal[200]);
  Icon shuffle = Icon(Icons.shuffle, color: Colors.teal[200]);

  int shuffleiconnum = 0;

  int playlistIconNum = 0;

  void initState() {
    print(songs);
    _animControl =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    isPlaying != true ? _animControl.repeat() : _animControl.stop();
    super.initState();

    getTracks();

    changeState();

    // getNames();
  }

//   getNames() {
//     for (int i = 0; i < songs.length; i++) {
//       usersList.add(songs.toString());
//       print(usersList);
//     }
// // faker.person.name() ////avoid theuserlistandaddSongsLISTto use//////
//     //sort the list
//     usersList.sort(
//       (a, b) {
//         return a.toLowerCase().compareTo(b.toLowerCase());
//       },
//     );
//   }

  void getTracks() async {
    songs = await audioQuery.getSongs();
    setState(
      () {
        songs = songs;

        changeState();
        // setSong(songs[currentIndex]);

        MediaNotification.setListener('play', () {
          setState(
            () => status = changeState(),
          );
        });

        MediaNotification.setListener('pause', () {
          setState(
            () => status = changeState(),
          );
        });

        MediaNotification.setListener('next', () {
          setState(() => status = changeTrack(true));
        });

        MediaNotification.setListener('prev', () {
          setState(() => status = changeTrack(false));
        });

        MediaNotification.setListener('select', () {});
      },
    );
  }

  //////////////////////
  void setSong(SongInfo songInfo) async {
    print("Got song info");
    songInfo = songInfo;
    print(songInfo);
    await player.setUrl(songInfo.uri);
    currentvalue = minmumvalue;
    maximumvalue = player.duration.inMilliseconds.toDouble();
    setState(() {
      currentTime = getDuration(currentvalue);
      endTime = getDuration(maximumvalue);
    });

    isPlaying = false;
    changeState();
    player.positionStream.listen(
      (duration) {
        currentvalue = duration.inMilliseconds.toDouble();
        setState(
          () {
            currentTime = getDuration(currentvalue);
            if (currentvalue >= maximumvalue) {
              return changeTrack(true);
            }
          },
        );
      },
    );
    MediaNotification.showNotification(
      title: songs[currentIndex].title,
      author: songs[currentIndex].artist,
    );
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());
    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  /////////madeChangeAttheFunctionNmaesetSongTOwidgetsetSong

  changeState() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      player.play();
      _animControl.repeat();
    } else {
      player.pause();
      _animControl.stop();
    }
  }

  pausePlayer() {
    player.pause();
    _animControl.stop();
  }

  playPlayer() {
    player.play();
    _animControl.repeat();
  }

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

  // final tabs = [
  //   SafeArea(
  //     child: SongsAgain(),
  //   ),
  //   SafeArea(
  //     child: Favourites(),
  //   ),
  //   SafeArea(
  //     child: SearchScreen(),
  //   ),
  // ];

  void dispose() {
    super.dispose();
    player?.dispose();
    _animControl.dispose();
  }

  // void addMusic(SongPlayList musicName, ids) {
  //   final musicBox = Hive.box('Musicbox');
  //   musicBox.add(musicName);
  // }

  var savedList;

  // Future initiateHive() async {
  //   ///Creating a HiveBox to Store data
  //   savedList = await Hive.openBox('Musicbox');
  //   print("Box opened");
  // }

  int _selectedIndex = 0;
  Timer _timer;
  int _start;
  void startTimer(int _start) {
    _start = _start;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(
            () {
              timer.cancel();
              pausePlayer();
            },
          );
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  stopTimer() {
    setState(() {
      _timer.cancel();
    });
  }

  timerOnTrackfinish() {
    setState(
      () {
        currentTime = getDuration(currentvalue);
        if (currentvalue >= maximumvalue) {
          return pausePlayer();
        }
      },
    );
  }

  String titleS = "";

  setNameOntap(String title) {
    titleS = title;
  }

  String artistName = "";

  setArtistOntap(String artistname) {
    artistName = artistname;
  }

  final color = const Color(0xff121212);

  List<Widget> _widgetOptions = <Widget>[
    SongsAgain(),
    Favourites(),
    SearchScreen(),
  ];

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.timer,
                color: Colors.red,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.black,
                    insetPadding: EdgeInsets.fromLTRB(0, 450, 0, 0),
                    actions: <Widget>[],
                    title: Center(
                      child: Text(
                        "Set Timer",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400]),
                      ),
                    ),
                    content: Container(
                      height: 185,
                      child: Column(
                        children: [
                          GestureDetector(
                            child: Container(
                              child: Text(
                                "10 Second",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[400]),
                              ),
                            ),
                            onTap: () {
                              startTimer(10);
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Timer Set to 10 Seconds"),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(
                            height: 13,
                          ),
                          GestureDetector(
                            child: Text(
                              "10 Minutes",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400]),
                            ),
                            onTap: () {
                              startTimer(600);
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("TImer Set To 10 minutes"),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(
                            height: 13,
                          ),
                          GestureDetector(
                            child: Text(
                              "30 Minutes",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400]),
                            ),
                            onTap: () {
                              startTimer(1800);
                              // Scaffold.of(context).showSnackBar(
                              //   SnackBar(
                              //     content: Text("TImer Set to 30 Minutes"),
                              //   ),
                              // );
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(
                            height: 13,
                          ),
                          GestureDetector(
                            child: Text(
                              "60 Minutes",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400]),
                            ),
                            onTap: () {
                              startTimer(3600);
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Timer Set to 60 Minutes"),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(
                            height: 13,
                          ),
                          GestureDetector(
                            child: Text(
                              "End Of the Track",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400]),
                            ),
                            onTap: () {
                              timerOnTrackfinish();
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("Timer Set to End Of the track"),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(
                            height: 13,
                          ),
                          GestureDetector(
                            child: Text(
                              "Off Timer",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400]),
                            ),
                            onTap: () {
                              stopTimer();
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Timer OFF"),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          ],
          backgroundColor: color,
          leading: Icon(Icons.music_note, color: Colors.teal[200]),
          title: Text(
            'musizcity.',
            style: TextStyle(
              color: Colors.teal[200],
              fontSize: 40,
            ),
          ),
          centerTitle: true),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _buildListViewSongs(),
            SlidingUpPanel(
              border: Border.all(
                color: Colors.teal[200],
                width: 2,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(24.0),
                bottomLeft: Radius.circular(24.0),
                bottomRight: Radius.circular(24.0),
              ),
              backdropColor: Colors.grey, color: color,
              boxShadow: [],
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              minHeight: 100,
              // color: Colors.black,
              maxHeight: 1000,
              margin: const EdgeInsets.all(18.0),
              panel: Container(
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(40.0),
                    topRight: const Radius.circular(40.0),
                    bottomLeft: const Radius.circular(40.0),
                    bottomRight: const Radius.circular(40.0),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Column(
                              children: [
                                Container(
                                  height: 60,
                                  width: 350,
                                  padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
                                  margin: EdgeInsets.fromLTRB(30, 10, 0, 0),
                                  child: Center(
                                    child: Text(
                                      titleS,
                                      style: TextStyle(
                                          color: Colors.teal[200],
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
                                          color: Colors.teal[200],
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold),
                                    ),
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
                                  icon: shuffle,
                                  color: Colors.teal[200],
                                  onPressed: () {
                                    setState(
                                      () {
                                        if (shuffleiconnum == 0) {
                                          shuffle = Icon(
                                            Icons.done_sharp,
                                            color: Colors.teal[200],
                                          );
                                          shuffleiconnum = 1;
                                        } else {
                                          shuffle = Icon(
                                            Icons.shuffle,
                                            color: Colors.teal[200],
                                          );
                                          shuffleiconnum = 0;
                                        }
                                      },
                                    );
                                    songs.shuffle();
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.white,
                                        content: Text("Shuffled Your Music"),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  padding: EdgeInsets.fromLTRB(350, 0, 0, 0),
                                  icon: playli,
                                  color: Colors.green,
                                  onPressed: () async {
                                    setState(
                                      () {
                                        if (playlistIconNum == 0) {
                                          playli = Icon(
                                            Icons.favorite,
                                            color: Colors.teal[200],
                                          );
                                          playlistIconNum = 1;
                                        } else {
                                          playli = Icon(
                                            Icons.favorite_border,
                                            color: Colors.teal[200],
                                          );
                                          playlistIconNum = 0;
                                        }
                                      },
                                    );

                                    savedList = await Hive.openBox('Musicbox');
                                    var songFav = SongPlayList()
                                      ..songInfo = songs[currentIndex].id;

                                    print(songs[currentIndex].id);

                                    savedList.put(
                                        songs[currentIndex].id, songFav);

                                    print("saved savedList");

                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Added to Favorite"),
                                      ),
                                    );
                                  },
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 10,
                                        offset: Offset(4, 8),
                                      ),
                                    ],
                                  ),
                                  child: AnimatedBuilder(
                                    animation: _animControl.view,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _animControl.value * 3 * pi,
                                        child: child,
                                      );
                                    },
                                    child: CircleAvatar(
                                      backgroundImage: songs[currentIndex]
                                                  .albumArtwork ==
                                              null
                                          ? AssetImage(
                                              'android/assets/images/gramaphoneIm.jpeg')
                                          : FileImage(File(songs[currentIndex]
                                              .albumArtwork)),
                                      radius: 150,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                ),
                                Slider(
                                  inactiveColor: Colors.teal[200],
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
                                  transform:
                                      Matrix4.translationValues(0, -5, 0),
                                  margin: EdgeInsets.fromLTRB(5, 0, 5, 15),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        currentTime,
                                        style: TextStyle(
                                            color: Colors.teal[200],
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 342,
                                      ),
                                      Text(
                                        endTime,
                                        style: TextStyle(
                                            color: Colors.teal[200],
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
                                        child: Icon(
                                            Icons.skip_previous_outlined,
                                            color: Colors.teal[200],
                                            size: 55),
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
                                                : Icons
                                                    .play_circle_fill_rounded,
                                            color: Colors.red,
                                            size: 85),
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          changeState();
                                        },
                                      ),
                                      GestureDetector(
                                        child: Icon(Icons.skip_next_outlined,
                                            color: Colors.teal[200], size: 55),
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
                                    color: Colors.teal[200],
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
                                    color: Colors.teal[200],
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
                                  songs[currentIndex].title,
                                  style: TextStyle(
                                    fontFamily: 'DancingScript',
                                    fontSize: 15,
                                    color: Colors.teal[200],
                                  ),
                                ),
                                Text(
                                  songs[currentIndex].artist,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.teal[200],
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: color,
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(
                Icons.home,
                color: Colors.teal[200],
                size: 30,
              ),
              onPressed: () {},
            ),
            title: Text(
              'Home',
              style: TextStyle(color: Colors.teal[200]),
            ),
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.favorite_outline_outlined,
                  color: Colors.teal[200]),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Favourites(
                      pausePlayer: pausePlayer,
                    ),
                  ),
                );
              },
            ),
            title: Text('Playlist'),
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.search, color: Colors.teal[200]),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SearchScreen()));
              },
            ),
            title: Text('Search'),
          ),
        ],
        onTap: (index) {
          setState(
            () {
              _selectedIndex = index;
            },
          );
        },
      ),
      backgroundColor: color,
    );
  }

  Widget _buildListViewSongs() {
    return Scrollbar(
      radius: Radius.circular(50),
      child: DraggableScrollbar.semicircle(
        labelTextBuilder: (double offset) => Text("${offset ~/ 40}"),
        controller: _scroll,
        child: ListView.separated(
          controller: _scroll,
          separatorBuilder: (context, index) => Divider(),
          itemCount: songs.length,
          itemBuilder: (context, index) => ListTile(
            leading: CircleAvatar(
              backgroundImage: songs[index].albumArtwork == null
                  ? AssetImage(
                      'android/assets/images/Apple-Music-artist-promo.jpg')
                  : FileImage(
                      File(songs[index].albumArtwork),
                    ),
            ),
            title: Text(
              songs[index].title,
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(songs[index].artist,
                style: TextStyle(color: Colors.white)),
            trailing: IconButton(
              icon: Icon(
                Icons.favorite_outline,
                color: Colors.teal[200],
              ),
              onPressed: () async {
                savedList = await Hive.openBox('Musicbox');

                var songFav = SongPlayList()..songInfo = songs[currentIndex].id;

                print(songs[currentIndex].id);

                savedList.put(songs[currentIndex].id, songFav);

                print("saved savedList");

                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Added to Favorite"),
                  ),
                );
              },
            ),
            onTap: () {
              currentIndex = index;
              print("index $index");
              print("current index $currentIndex");
              SongsAgain(songInfo: songs[currentIndex], key: key);
              print(currentIndex);

              setNameOntap(songs[currentIndex].title);
              setArtistOntap(songs[currentIndex].artist);

              setSong(
                songs[currentIndex],
              );
              widget.pauseplayer();
            },
          ),
        ),
      ),
    );
  }
}
