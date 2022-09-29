import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //late Timer timer;
  int currentNavIndex = 1;
  int noOfJobs = 0;
  List<String> location = [];
  List<String> dt = [];
  List<String> confirmation = [];
  List<String> noClient = [];
  List<LatLng> dtLocation = [];
  List<GeoPoint> geoPointList = [];
  List<String> coachName = [];
  List<String> noOfLesson = [];
  List<String> dtName = [];

  List<Completer<GoogleMapController>> _controllerList = [];
  List<LatLng> latlngList = [];

  @override
  void initState() {
    super.initState();
    RetrieveClassesData();
  }

  String formatTimestamp(Timestamp timestamp) {
    var format = DateFormat('d/MM/y HH:mm:ss'); // <- use skeleton here
    return format.format(timestamp.toDate());
  }

  void RetrieveClassesData() {
    noOfJobs = 0;
    FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('transaction')
        .where('transactionCreatedDateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .listen((snapshot) {
      //iterate each client
      snapshot.docs.forEach((transaction) {
        setState(() {
          _controllerList.add(Completer());
          geoPointList.add(transaction.get('location'));

          ++noOfJobs;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    late GoogleMapController mapController;

    final LatLng _center = const LatLng(1.2813713, 103.8523851);

    Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

    void _onMapCreated(GoogleMapController controller) {
      mapController = controller;

      final marker = Marker(
        markerId: MarkerId("The Sail"),
        position: _center,
      );

      setState(() {
        markers[MarkerId("The Sail")] = marker;
      });
    }

    return Scaffold(
      extendBody: true,
      //extendBodyBehindAppBar: false,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppBar(
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.only()),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 33, 126, 50),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                // ignore: prefer_const_constructors
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Image(
                    image: AssetImage("assets/icons/mm_logo.png"),
                    width: 35,
                    height: 35,
                  ),
                ),
                const Text(
                  "Mahjong Movers",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.add_box_rounded),
                onPressed: () {
                  setState(() {
                    Navigator.pushNamed(context, '/newBooking');
                  });
                },
              ),
            ],
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          )),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            for (var i = 0; i < noOfJobs; ++i)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(
                      width: 400,
                      height: 300,
                      child: GoogleMap(
                        myLocationButtonEnabled: false,
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(geoPointList[i].latitude,
                              geoPointList[i].longitude),
                          zoom: 15.0,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _controllerList[i].complete(controller);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            for (var i = 0; i < noOfJobs; ++i)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ListTile(
                      title: Text("Job Name"),
                      subtitle: Text("Job Description\n" + "\$10"),
                      trailing: Text("DateTime: 23/9/2022"),
                    ),
                  ],
                ),
              ),
            // This is to make it scroll nicely
            const SizedBox(
              height: 100.0,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentNavIndex,
        onTap: (index) {
          setState(() {
            currentNavIndex = index;
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(
                  context,
                  '/booking',
                );
                break;
              case 2:
                Navigator.pushReplacementNamed(
                  context,
                  '/clientFeedback',
                );
                break;
              default:
                break;
            }
          });
        },
        backgroundColor: const Color.fromARGB(255, 33, 126, 50),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_sharp),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Profile',
          )
        ],
      ),
    );
  }
}
