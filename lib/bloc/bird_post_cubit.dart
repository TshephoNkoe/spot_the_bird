import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spot_the_bird/models/bird_model.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';

import 'package:spot_the_bird/services/database_helper.dart';
import 'dart:developer';

part 'bird_post_state.dart';

class BirdPostCubit extends Cubit<BirdPostState> {
  BirdPostCubit()
      : super(const BirdPostState(
            birdPosts: [], status: BirdPostsStatus.initial));

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> getPosts() async {
    try {
      List<BirdModel> birdPosts = [];

      final List<Map<String, dynamic>> allRows = await _dbHelper.queryAllRows();

      if (allRows.isEmpty) {
        log("Rows are empty");
      } else {
        log("Rows have data");

        for (Map<String, dynamic> row in allRows) {

          final Directory directory = await getApplicationDocumentsDirectory();

          final String path = "${directory.path}/${row["id"]}.png";

          final File imageFile = File(path);

          imageFile.writeAsBytesSync(row[DatabaseHelper.picture]);

          birdPosts.add(BirdModel(
              id: row["id"],
              image: imageFile,
              latitude: row[DatabaseHelper.latitude],
              longitude: row[DatabaseHelper.longitude],
              birdName: row[DatabaseHelper.birdName],
              birdDescription: row[DatabaseHelper.birdDescription]));
        }
      }

      emit(
          state.copyWith(birdPosts: birdPosts, status: BirdPostsStatus.loaded));
    } catch (err) {
      log(err.toString());
      emit(state.copyWith(status: BirdPostsStatus.error));
    }
  }

  Future<void> addBirdPost(BirdModel birdModel) async {
    emit(state.copyWith(status: BirdPostsStatus.loading));

    // TODO:- add to sql table
    // Convert file to Uint8List
    Uint8List bytes = birdModel.image.readAsBytesSync();

    Map<String, dynamic> row = {
      DatabaseHelper.birdName: birdModel.birdName,
      DatabaseHelper.birdDescription: birdModel.birdDescription,
      DatabaseHelper.longitude: birdModel.longitude,
      DatabaseHelper.latitude: birdModel.latitude,
      DatabaseHelper.picture: bytes,
    };

    final id = await _dbHelper.insert(row);

    birdModel.id = id;

    List<BirdModel> posts = [];

    posts.addAll(state.birdPosts);

    posts.add(birdModel);

    emit(state.copyWith(birdPosts: posts, status: BirdPostsStatus.postAdded));
  }

  Future<void> deletePost(BirdModel birdModel) async {
    emit(state.copyWith(status: BirdPostsStatus.loading));

    List<BirdModel> posts = List.from(state.birdPosts, growable: true);

    posts.remove(birdModel);

    _dbHelper.delete(birdModel.id!);

    emit(state.copyWith(birdPosts: posts, status: BirdPostsStatus.postRemoved));
  }
}
