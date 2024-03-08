import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:spot_the_bird/bloc/bird_post_cubit.dart';
import 'package:spot_the_bird/bloc/location_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'dart:io';

import 'package:spot_the_bird/screens/add_bird_screen.dart';
import 'package:spot_the_bird/screens/bird_info_screen.dart';

class MapScreen extends StatelessWidget {
  MapScreen({Key? key}) : super(key: key);

  final MapController _mapController = MapController();

  Future<void> _getImageAndCreatePost({
    required BuildContext context,
    required LatLng latLng,
  }) async {
    File? image;
    // Pick Image
    final ImagePicker imagePicker = ImagePicker();

    final XFile? pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 40);

    if (pickedImage != null) {
      // Push to add bird screen
      image = File(pickedImage.path);

      Navigator.of(context).pushNamed(AddBirdScreen.routeName, arguments: {
        "latLng": latLng,
        "image": image,
      });

      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //       builder: (context) => AddBirdScreen(latLng: latLng, image: image!)),
      // );

    } else {
      log("No image selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LocationCubit, LocationState>(
        listener: (previousState, currentState) {
          if (currentState is LocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error fetching location")));
          }
          if (currentState is LocationLoaded) {
            _mapController.onReady.then(
              (value) => _mapController.move(
                  LatLng(currentState.latitude, currentState.longitude), 15),
            );
          }
        },
        child: BlocConsumer<BirdPostCubit, BirdPostState>(
          listener: (prevState, currState) {
            if (currState.status == BirdPostsStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).errorColor,
                  duration: const Duration(seconds: 2),
                  content: const Text(
                      "Error has occurred while doing operations with bird posts"),
                ),
              );
            }
          },
          buildWhen: (prevState, currState) =>
              (prevState.status != currState.status),
          builder: (context, birdPostState) => FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              onLongPress: (position, latLng) {
                // Picks image and goes to add_bird_screen where we create bird post.
                _getImageAndCreatePost(context: context, latLng: latLng);
              },
              center: LatLng(0, 0),
              zoom: 15,
              maxZoom: 100,
              minZoom: 0,
            ),
            layers: [
              TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                retinaMode: true,
              ),
              MarkerLayerOptions(
                markers: birdPostState.birdPosts
                    .map(
                      (post) => Marker(
                        width: 55,
                        height: 55,
                        point: LatLng(post.latitude, post.longitude),
                        builder: (context) => GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed(BirdInfoScreen.routeName, arguments: post),
                          child: Image.asset("assets/bird_icon.png"),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.navigation_rounded),
        onPressed: () {
          context.read<LocationCubit>().getLocation();
        },
      ),
    );
  }
}
