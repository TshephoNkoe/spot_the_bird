import 'dart:io';

class BirdModel {

  /// Id of the bird post to be used in SQL Table.
  int? id;

  String birdName;

  String birdDescription;

  double latitude;
  double longitude;

  File image;

  BirdModel({
    this.id,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.birdName,
    required this.birdDescription,
  });
}
