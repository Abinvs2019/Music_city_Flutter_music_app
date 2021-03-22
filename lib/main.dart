import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app2/Playlist.dart';
import 'package:flutter_app2/hive_helper.dart';
import 'package:flutter_app2/songsagain.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

////////initilizingHIveinAPPinMAIN,8:14AM,16/3/2021
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);
  Hive.registerAdapter(
    HivehelperAdapter(),
  );
  Hive.openBox('Musicbox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void homePageChange() async {
      await Future.delayed(const Duration(seconds: 2), () {});
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SongsAgain()));
    }

    homePageChange();
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 450, 0, 0),
            child: Column(children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white),
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: NetworkImage(
                      "https://ak.picdn.net/shutterstock/videos/14229665/thumb/1.jpg"),
                ),
              ),
              Divider(
                height: 30,
              ),
              Text(
                "Listen to your",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 65,
                    color: Colors.green),
              ),
              Text(
                "Favourites.",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 65,
                    color: Colors.green),
              ),
              Divider(
                height: 30,
              ),
            ]),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
