import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app2/Playlist.dart';
import 'package:flutter_app2/hive_helper.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SongsAgain extends StatefulWidget {
  SongInfo songInfo;
  final GlobalKey<_SongsStateagain> key;
  SongsAgain({
    this.songInfo,
    this.key,
  }) : super(key: key);

  @override
  _SongsStateagain createState() => _SongsStateagain();
}

class _SongsStateagain extends State<SongsAgain> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  final GlobalKey<_SongsStateagain> key = GlobalKey<_SongsStateagain>();
  final AudioPlayer player = AudioPlayer();
  List<SongInfo> songs = [];
  bool isPlaying = false;
  double minmumvalue = 0.0, maximumvalue = 0.0, currentvalue = 0.0;
  String currentTime = '', endTime = '';
  int currentIndex = 0;
  String status = 'hidden';

  void initState() {
    super.initState();
    print("Init CurrentINdex $currentIndex");
    getTracks();
    print("got track");
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
    player.positionStream.listen((duration) {
      currentvalue = duration.inMilliseconds.toDouble();
      setState(() {
        currentTime = getDuration(currentvalue);
        if (currentvalue >= maximumvalue) {
          return changeTrack(true);
        }
      });
    });
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
    // MediaNotification.showNotification(
    //   title: widget.songInfo.title,
    //   author: widget.songInfo.artist,
    // );
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
  }

  void addMusic(Hive_helper musicName) {
    final musicBox = Hive.box('Musicbox');
    musicBox.add(musicName);
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
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
            margin: const EdgeInsets.all(24.0),
            panel: Container(
              padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: songs[
                                                currentIndex]
                                            .albumArtwork ==
                                        null
                                    ? AssetImage(
                                        'android/assets/images/Apple-Music-artist-promo.jpg')
                                    : FileImage(
                                        File(songs[currentIndex].albumArtwork)),
                                radius: 150,
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(30, 10, 30, 5),
                                margin: EdgeInsets.fromLTRB(30, 10, 0, 30),
                                child: Text(
                                  songs[currentIndex].title,
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                                child: Text(
                                  songs[currentIndex].artist,
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold),
                                ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      currentTime,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      endTime,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold),
                                    )
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
                padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
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
                    SizedBox(width: 250, height: 20),
                    Text(
                      "",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.arrow_upward),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
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
                    MaterialPageRoute(builder: (context) => Playlist()));
              },
              child: Icon(
                Icons.favorite,
                color: Colors.green,
              ),
            ),
            title: new Text(
              'favorite',
              style: TextStyle(color: Colors.green),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.playlist_play,
              color: Colors.green,
            ),
            title: Text(
              'playlist',
              style: TextStyle(color: Colors.green),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: Colors.green,
            ),
            title: Text('Settings', style: TextStyle(color: Colors.green)),
          )
        ],
      ),
    );
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
          style: TextStyle(color: Colors.black),
        ),
        subtitle:
            Text(songs[index].artist, style: TextStyle(color: Colors.black)),
        trailing: IconButton(
          icon: Icon(
            Icons.favorite_outline,
            color: Colors.green,
          ),
          onPressed: () async {
            final newMusic = Hive_helper(
                title: songs[index].title, detail: songs[index].artist);
            addMusic(newMusic);

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

          setSong(songs[currentIndex]);
        },
      ),
    );
  }
}
