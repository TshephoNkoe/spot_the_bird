import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_the_bird/bloc/bird_post_cubit.dart';
import 'package:spot_the_bird/bloc/location_cubit.dart';
import 'package:spot_the_bird/screens/add_bird_screen.dart';
import 'package:spot_the_bird/screens/bird_info_screen.dart';
import 'package:spot_the_bird/screens/map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationCubit>(
          create: (context) => LocationCubit()..getLocation(),
        ),
        BlocProvider<BirdPostCubit>(create: (context) => BirdPostCubit()..getPosts()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF334756),
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.orange,
          ),
        ),
       //  home: MapScreen(),
        initialRoute: "/",
        routes: {
          "/" : (context) =>  MapScreen(),
          BirdInfoScreen.routeName : (context) => BirdInfoScreen(),
          AddBirdScreen.routeName : (context) => AddBirdScreen(),
        },
      ),
    );
  }
}
