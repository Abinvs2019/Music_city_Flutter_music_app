import 'package:hive/hive.dart';

part 'hive_helper.g.dart';

@HiveType(typeId: 0)
class Hive_helper {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String detail;

  Hive_helper({this.title, this.detail});
}
//
//
//
//haveChangedNothingTOSONGINFO////////
//
//stringsonginfo
//stringSoNGID
