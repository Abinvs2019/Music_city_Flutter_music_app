import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';

class MusicPlayer extends StatefulWidget {
  SongInfo songInfo;
  Function changeTrack;

  final GlobalKey<MusicPlayerState> key;

  MusicPlayer({
    this.songInfo,
    this.changeTrack,
    this.key,
  }) : super(key: key);

  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  var status = 'hidden';
  double minmumvalue = 0.0, maximumvalue = 0.0, currentvalue = 0.0;
  String currentTime = '', endTime = '';
  int currentIndex = 0;
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  List<SongInfo> songs = [];

  void initState() {
    super.initState();
    setSong(widget.songInfo);
  }

  void getTracks() async {
    songs = await audioQuery.getSongs();
    setState(() {
      songs = songs;
    });
  }

  void setSong(SongInfo songInfo) async {
    widget.songInfo = songInfo;
    await player.setUrl(widget.songInfo.uri);
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
          return widget.changeTrack(true);
        }
        ///////////////////////////////
      });
    });
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
    MediaNotification.showNotification(
      title: widget.songInfo.title,
      author: widget.songInfo.artist,
    );
  }

  void dispose() {
    super.dispose();
    player?.dispose();
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());
    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  @override
  Widget build(context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFF2E7D32),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "NOW PLAYING",
          style: TextStyle(color: Colors.green),
        ),
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down),
          onPressed: () {
            MediaNotification.hideNotification();
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: widget.songInfo.albumArtwork == null
                        ? AssetImage(
                            'android/assets/images/Apple-Music-artist-promo.jpg')
                        : FileImage(File(widget.songInfo.albumArtwork)),
                    radius: 150,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(30, 10, 30, 5),
                    margin: EdgeInsets.fromLTRB(30, 10, 0, 30),
                    child: Text(
                      widget.songInfo.title,
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      widget.songInfo.artist,
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
                        widget.changeTrack(true);
                      }
                    },
                  ),
                  Container(
                    transform: Matrix4.translationValues(0, -5, 0),
                    margin: EdgeInsets.fromLTRB(5, 0, 5, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          child: Icon(Icons.skip_previous_outlined,
                              color: Colors.green, size: 55),
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            widget.changeTrack(false);
                          },
                        ),
                        GestureDetector(
                          child: Icon(
                              isPlaying
                                  ? Icons.pause_circle_filled_rounded
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
                            widget.changeTrack(true);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Container(),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.headset,
                color: Colors.green,
              ),
              label: 'Home',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite_outline,
                color: Colors.green,
              ),
              label: 'Favourits',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.playlist_play_outlined,
                color: Colors.green,
              ),
              label: 'Playlist',
              backgroundColor: Colors.black),
        ],
      ),
    );
  }
}
