import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_the_bird/bloc/bird_post_cubit.dart';
import 'package:spot_the_bird/models/bird_model.dart';

class AddBirdScreen extends StatefulWidget {

  static const String routeName = "/add_bird_screen";

  // final File image;
  // final LatLng latLng;
  //
  // AddBirdScreen({
  //   required this.latLng,
  //   required this.image,
  // });

  @override
  _AddBirdScreenState createState() => _AddBirdScreenState();
}

class _AddBirdScreenState extends State<AddBirdScreen> {
  final _formKey = GlobalKey<FormState>();

  late final FocusNode _descriptionFocusNode;

  String? name;
  String? description;

  void _submit(BuildContext context, LatLng latLng, File image) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    context.read<BirdPostCubit>().addBirdPost(
          BirdModel(
              image: image,
              latitude: latLng.latitude,
              longitude: latLng.longitude,
              birdName: name!,
              birdDescription: description!),
        );

    Navigator.of(context).pop();
  }

  @override
  void initState() {
    _descriptionFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final LatLng latLng = args["latLng"] as LatLng;
    final File image = args["image"] as File;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Bird"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width / 1.4,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: FileImage(image),
                  fit: BoxFit.cover,
                )),
              ),
              // Bird Name TextField
              TextFormField(
                decoration: InputDecoration(hintText: "Enter bird name..."),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                onSaved: (value) {
                  name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  if (value.length < 2) {
                    return "Enter loner name...";
                  }
                  return null;
                },
              ),
              // Bird Description Text Field
              TextFormField(
                focusNode: _descriptionFocusNode,
                decoration:
                    InputDecoration(hintText: "Add bird description..."),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(context, latLng, image),
                onSaved: (value) {
                  description = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  if (value.length < 2) {
                    return "Enter loner name...";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _submit(context, latLng, image),
      ),
    );
  }
}
