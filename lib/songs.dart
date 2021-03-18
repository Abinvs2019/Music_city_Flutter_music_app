import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app2/Playlist.dart';
import 'package:flutter_app2/hive_helper.dart';
import 'package:flutter_app2/music_playing.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Songs extends StatefulWidget {
  Function changeState;

  Songs({
    this.changeState,
  });

  @override
  _SongsState createState() => _SongsState();
}

class _SongsState extends State<Songs> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();
  List<SongInfo> songs = [];
  final AudioPlayer player = AudioPlayer();

  double minmumvalue = 0.0, maximumvalue = 0.0, currentvalue = 0.0;
  String currentTime = '', endTime = '';
  int currentIndex = 0;
  String status = 'hidden';
  bool isPlaying = false;

  void initState() {
    super.initState();
    getTracks();
    setSong(songs[currentIndex]);

    MediaNotification.setListener('play', () {
      setState(
        () => status = widget.changeState(),
      );
    });

    MediaNotification.setListener('pause', () {
      setState(
        () => status = widget.changeState(),
      );
    });

    MediaNotification.setListener('next', () {
      setState(() => status = changeTrack(true));
    });

    MediaNotification.setListener('prev', () {
      setState(() => status = changeTrack(false));
    });

    MediaNotification.setListener('select', () {});

///////////////////////
  }

  void getTracks() async {
    songs = await audioQuery.getSongs();
    setState(() {
      songs = songs;
    });
  }

  changeTrack(bool isNext) {
    if (isNext) {
      if (currentIndex != songs.length - 1) {
        currentIndex++;
      }
    } else {
      if (currentIndex != 0) {
        currentIndex--;
      }
    }
    key.currentState.setSong(songs[currentIndex]);
  }

  //////////////////

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());
    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(':');
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
      title: songs[currentIndex].title,
      author: songs[currentIndex].artist,
    );
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
          title: Text('Music City',
              style: TextStyle(color: Colors.green, fontSize: 40)),
          centerTitle: true),
      body: Stack(
        children: <Widget>[
          ListView.separated(
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
              subtitle: Text(
                songs[index].artist,
                style: TextStyle(color: Colors.white),
              ),
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
                changeState();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MusicPlayer(
                      changeTrack: changeTrack,
                      songInfo: songs[currentIndex],
                      key: key,
                    ),
                  ),
                );
              },
            ),
          ),
          SlidingUpPanel(
            margin: const EdgeInsets.all(24.0),
            panel: Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: songs[currentIndex].albumArtwork ==
                                  null
                              ? AssetImage(
                                  'android/assets/images/Apple-Music-artist-promo.jpg')
                              : FileImage(
                                  File(songs[currentIndex].albumArtwork)),
                          radius: 90,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(30, 1, 30, 5),
                          margin: EdgeInsets.fromLTRB(30, 1, 0, 30),
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
                                  changeTrack(false);
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
                                  widget.changeState();
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
            collapsed: Container(
              color: Colors.green,
              child: Center(
                  child: Row(
                children: [
                  IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed: () {
                        changeTrack(true);
                      }),
                  IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        widget.changeState();
                      }),
                  IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: () {
                        changeTrack(false);
                      }),
                ],
              )),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Playlist(),
            ),
          );
        },
      ),
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // this will be set when a new tab is tapped
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
            icon: new Icon(
              Icons.favorite,
              color: Colors.green,
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
}
