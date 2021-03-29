import 'package:hive/hive.dart';
part 'hive_helper.g.dart';

@HiveType(typeId: 1)
class SongPlayList extends HiveObject {
  @HiveField(0)
  String songInfo;

  @HiveField(1)
  int songId;
}
