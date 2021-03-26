import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app2/Playlist.dart';
import 'package:flutter_app2/Playlist/playlist.dart';
import 'package:flutter_app2/hive_helper.dart';
import 'package:flutter_app2/search.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';

class SongsAgain extends StatefulWidget {
  SongInfo songInfo;
  final GlobalKey<SongsStateagain> key;

  SongsAgain({
    this.songInfo,
    this.key,
  }) : super(key: key);

  @override
  SongsStateagain createState() => SongsStateagain();
}

class SongsStateagain extends State<SongsAgain>
    with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchText = new TextEditingController();
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  final GlobalKey<SongsStateagain> key = GlobalKey<SongsStateagain>();
  final AudioPlayer player = AudioPlayer();
  List<SongInfo> songs = [];
  final pi = 3.14;
  bool isPlaying = false;
  double minmumvalue = 0.0, maximumvalue = 0.0, currentvalue = 0.0;
  String currentTime = '', endTime = '';
  int currentIndex = 0;
  String status = 'hidden';
  AnimationController _animControl;

  void initState() {
    _animControl =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    isPlaying != null ? _animControl.repeat() : _animControl.repeat();
    super.initState();
    print("Init CurrentINdex $currentIndex");
    getTracks();
    print("got track");
    changeState();
  }

  void getTracks() async {
    songs = await audioQuery.getSongs();
    setState(() {
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
    });
  }

  //////////////////
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
    } else {
      player.pause();
    }
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
    print("SetSongCurrentIndex $currentIndex");
  }

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

  Future initiateHive() async {
    ///Creating a HiveBox to Store data
    savedList = await Hive.openBox('Musicbox');
  }

  searhSong() async {
    songs = await audioQuery.searchSongs(query: _searchText.text);
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
          actions: <Widget>[
            IconButton(icon: Icon(Icons.search), onPressed: () {})
          ],
          backgroundColor: Colors.black,
          leading: Icon(Icons.music_note, color: Colors.green),
          title: Text(
            'Music City',
            style: TextStyle(
              color: Colors.green,
              fontSize: 40,
            ),
          ),
          centerTitle: true),
      body: Stack(
        children: <Widget>[
          _buildListViewSongs(),
          SlidingUpPanel(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(24.0),
              bottomLeft: Radius.circular(24.0),
              bottomRight: Radius.circular(24.0),
            ),
            minHeight: 100,
            // color: Colors.black,
            maxHeight: 1000,
            margin: const EdgeInsets.all(22.0),
            panel: Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                                height: 60,
                                width: 350,
                                padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
                                margin: EdgeInsets.fromLTRB(30, 10, 0, 0),
                                child: Center(
                                  child: Text(
                                    songs[currentIndex].title,
                                    style: TextStyle(
                                        color: Colors.green,
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
                                    songs[currentIndex].artist,
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // color: Colors.amber,
                        ),
                        SizedBox(
                          height: 30,
                          width: 500,
                        ),
                        Container(
                          child: Column(
                            children: [
                              IconButton(
                                padding: EdgeInsets.fromLTRB(350, 0, 0, 0),
                                icon: Icon(Icons.favorite_border_outlined),
                                color: Colors.green,
                                onPressed: () {
                                  // final newMusic = SongPlayList()
                                  //   ..songInfo = songs[currentIndex].id;
                                  // print("object");
                                  // print(newMusic);
                                  // addMusic(newMusic, songs[currentIndex].id);
                                  // savedList.keys
                                  //     .contains(songs[currentIndex].id);

                                  var songFav = SongPlayList()
                                    ..songInfo = songs[currentIndex].id;

                                  // print(songs[currentIndex].id);
                                  // print(songFav);
                                  print(songs[currentIndex].id);

                                  savedList.put(
                                      songs[currentIndex].id, songFav);

                                  print("saved lisysavedList");
                                },
                              ),
                              AnimatedBuilder(
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
                                      : FileImage(File(
                                          songs[currentIndex].albumArtwork)),
                                  radius: 150,
                                ),
                              ),
                              // ),
                              SizedBox(
                                height: 100,
                                width: 100,
                              ),
                              Slider(
                                inactiveColor: Colors.green,
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
                                          color: Colors.green,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 342,
                                    ),
                                    Text(
                                      endTime,
                                      style: TextStyle(
                                          color: Colors.green,
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
                                          color: Colors.green, size: 55),
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
                                          color: Colors.green, size: 55),
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
                          width: 5,
                          height: 5,
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
                                songs[currentIndex].title.trimRight(),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                songs[currentIndex].artist,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_upward),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
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
            icon: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Favourites()));
              },
              child: Icon(
                Icons.favorite,
                color: Colors.green,
              ),
            ),
            title: Text(
              'favorite',
              style: TextStyle(color: Colors.green),
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
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PlaylistO()));
              },
              child: Icon(
                Icons.playlist_play,
                color: Colors.green,
              ),
            ),
            title: Text(
              'favorite',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
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

              var songFav = SongPlayList()..songInfo = songs[currentIndex].id;

              // print(songs[currentIndex].id);
              // print(songFav);
              print(songs[currentIndex].id);

              savedList.put(songs[currentIndex].id, songFav);

              print("saved lisysavedList");

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
            SongsAgain(
              key: key,
              songInfo: songs[currentIndex],
            );
            print(key);
            setSong(
              songs[currentIndex],
            );
          },
        ),
      ),
    );
  }
}
