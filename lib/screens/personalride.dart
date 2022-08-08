import 'dart:async';
import 'dart:io';

import 'package:democab/bloc/deliverybloc.dart';
import 'package:democab/brand_colors.dart';
import 'package:democab/dataprovider/appdata.dart';
import 'package:democab/globalvariable.dart';
import 'package:democab/model/directiondetails.dart';
import 'package:democab/model/nearbydriver.dart';
import 'package:democab/requests/firehelper.dart';
import 'package:democab/requests/requestmethods.dart';
import 'package:democab/requests/widgetmethods.dart';
import 'package:democab/rideVariables.dart';
import 'package:democab/screens/searchpage.dart';
import 'package:democab/widget/BrandDivider.dart';
import 'package:democab/widget/NoDriverDialog.dart';
import 'package:democab/widget/TaxiButton.dart';
import 'package:democab/widget/collectPaymentDialog.dart';
import 'package:democab/widget/dropdown.dart';
import 'package:democab/widget/menu.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryPage extends StatefulWidget {
  static const String id = 'Delivery';
  @override
  _DeliveryPage createState() => _DeliveryPage();
}

class _DeliveryPage extends State<DeliveryPage> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;
  double rideDetailsSheetHeight = 0; //(Platform.isIOS) ? 300 : 275
  double requestingSheetHeight = 0; //(Platform.isAndroid) ? 195 : 220
  double tripSheetHeight = 0;

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottomPadding = 0;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  BitmapDescriptor nearbyIcon;

  var geoLocator = Geolocator();
  Position currentPosition;

  DirectionDetails tripDirectionDetails;

  String appState = 'NORMAL';

  var carBloc = DeliveryBloc();
  var p;
  String payType = 'wallet';

  bool drawerCanOpen = true;

  DatabaseReference rideRef;

  StreamSubscription<Event> rideSubscription;

  List<NearbyDriver> availableDrivers;

  bool driverKeyLoaded = false;

  bool isRequestingLocationDetails = false;

  void setupPositionLocator() async {
    Position position = await geoLocator.getLastKnownPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    //get position
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    //confirm location
    await RequestMethods.findCordinatAddress(position, context);
    // print(address);
    startGeofireListner();
  }

  void showDetailSheet() async {
    await getDirection();

    setState(() {
      searchSheetHeight = 0;
      rideDetailsSheetHeight = (Platform.isAndroid) ? 248 : 260;
      mapBottomPadding = (Platform.isAndroid) ? 240 : 230;
      drawerCanOpen = false;
    });
  }

  void showRequestingSheet(int amt) {
    setState(() {
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = (Platform.isAndroid) ? 195 : 220;
      mapBottomPadding = (Platform.isAndroid) ? 200 : 190;

      drawerCanOpen = true;
    });
    createRideRequest(amt);
  }

  showTripSheet() {
    setState(() {
      requestingSheetHeight = 0;
      tripSheetHeight = (Platform.isAndroid) ? 275 : 300;
      mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
    });
  }

  void createMarker() {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration,
              (Platform.isIOS)
                  ? 'assets/car_ios.png'
                  : 'assets/car_android.png')
          .then((icon) {
        nearbyIcon = icon;
      });
    }
  }

  @override
  void initState() {
    //Todo: implement initState
    super.initState();
    RequestMethods.getCurrentUserInfo(context);
    RequestMethods.getFare(context);
  }

  @override
  Widget build(BuildContext context) {
    if (tripDirectionDetails != null) {
      p = RequestMethods.estimateFare(tripDirectionDetails,
          Provider.of<AppData>(context, listen: false).fare);
      Provider.of<AppData>(context, listen: false).p = p;
    }

    createMarker();

    return Scaffold(
      key: scaffoldKey,
      drawer: MenuPage(),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapBottomPadding),
            initialCameraPosition: googlePlex,
            myLocationButtonEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: _polylines,
            markers: _markers,
            circles: _circles,
            mapType: MapType.normal,
            myLocationEnabled: true,
            onMapCreated: (controller) {
              _controller.complete(controller);
              mapController = controller;

              setState(() {
                mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
              });

              setupPositionLocator();
            },
          ),
          //menu button
          (!drawerCanOpen)
              ? Positioned(
                  top: 44,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      if (drawerCanOpen) {
                        scaffoldKey.currentState.openDrawer();
                      } else {
                        resetApp();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7),
                            ),
                          ]),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: Icon(
                          (drawerCanOpen == true)
                              ? Icons.menu
                              : Icons.arrow_back,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),

          //SearchPlace
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: searchSheetHeight,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 90,
                      ),
                      GestureDetector(
                        onTap: () async {
                          Provider.of<AppData>(context, listen: false)
                              .resetInput();

                          var response = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookForSomeone(
                                  type: 'deliver',
                                ),
                              ));

                          if (response == 'getDirection') {
                            showDetailSheet();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Request Pickup'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // RideDetails Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 07),
                      ),
                    ]),
                height: rideDetailsSheetHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 1),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.separated(
                          padding: EdgeInsets.all(0),
                          itemBuilder: (context, index) {
                            p = carBloc.bikeList.elementAt(index).price *
                                RequestMethods.estimateFare(
                                    tripDirectionDetails,
                                    Provider.of<AppData>(context, listen: false)
                                        .fare);
                            p = (p / 10).ceil() * 10;
                            return FlatButton(
                              onPressed: () {
                                setState(() {
                                  carBloc.selectItem(index);
                                  p = carBloc.bikeList.elementAt(index).price *
                                      RequestMethods.estimateFare(
                                          tripDirectionDetails,
                                          Provider.of<AppData>(context,
                                                  listen: false)
                                              .fare);
                                  p = (p / 10).ceil() * 10;
                                  Provider.of<AppData>(context, listen: false)
                                      .updatePrice(p);
                                });
                                //print(p);
                              },
                              child: Container(
                                width: double.infinity,
                                color: (carBloc.isSelected(index))
                                    ? BrandColors.colorAccent1
                                    : Colors.transparent,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        (carBloc.bikeList
                                                    .elementAt(index)
                                                    .image !=
                                                null)
                                            ? carBloc.bikeList
                                                .elementAt(index)
                                                .image
                                            : "",
                                        height: 70,
                                        width: 70,
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (carBloc.bikeList
                                                        .elementAt(index)
                                                        .name !=
                                                    null)
                                                ? carBloc.bikeList
                                                    .elementAt(index)
                                                    .name
                                                : "",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'Brand-Bold'),
                                          ),
                                          Text(
                                            (tripDirectionDetails != null)
                                                ? tripDirectionDetails
                                                    .distanceText
                                                : '',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color:
                                                    BrandColors.colorTextLight),
                                          ),
                                        ],
                                      ),
                                      Expanded(child: Container()),
                                      Text(
                                        (tripDirectionDetails != null)
                                            ? '\NGN$p'
                                            : '',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'Brand-Bold'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              BrandDivider(),
                          itemCount: carBloc.bikeList.length,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 1, horizontal: 18),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.moneyBillAlt,
                                size: 18,
                                color: BrandColors.colorTextLight,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              //Text('Cash'),
                              DropDowner(
                                onChanged: (PayType value) {
                                  payType = value.payType;
                                },
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: BrandColors.colorTextLight,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 1,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: TaxiButton(
                            title: 'BOOK PICKUP',
                            color: BrandColors.colorGold,
                            onPressed: () {
                              if (currentUserInfo.wallet < p.round() &&
                                  Provider.of<AppData>(context, listen: false)
                                          .payType !=
                                      'cash') {
                                showSnackBar(
                                    'Please Fund your wallet', scaffoldKey);
                                return;
                              }
                              setState(() {
                                appState = 'REQUESTING';
                              });
                              showRequestingSheet(p.round());

                              availableDrivers = FireHelper.nearbyDriverList;

                              findDriver();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          //requesting
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                height: requestingSheetHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextLiquidFill(
                          text: 'Requesting a Ride...',
                          waveColor: BrandColors.colorTextSemiLight,
                          boxBackgroundColor: Colors.white,
                          textStyle: TextStyle(
                            fontSize: 22.0,
                            fontFamily: 'Brand-Bold',
                          ),
                          boxHeight: 40.0,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          cancelRequest();
                          resetApp();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                                width: 1.0,
                                color: BrandColors.colorLightGrayFair),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 25,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          'Cancel ride',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Trip Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0, // soften the shadow
                      spreadRadius: 0.5, //extend the shadow
                      offset: Offset(
                        0.7, // Move to right 10  horizontally
                        0.7, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                ),
                height: tripSheetHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tripStatusDisplay,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontFamily: 'Brand-Bold'),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      BrandDivider(),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        '$driverCarDetails | $driverPlateNumber',
                        style: TextStyle(color: BrandColors.colorTextLight),
                      ),
                      Text(
                        driverFullName,
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      BrandDivider(),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              launch("tel://$driverPhoneNumber");
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular((25))),
                                    border: Border.all(
                                        width: 1.0,
                                        color: BrandColors.colorTextLight),
                                  ),
                                  child: Icon(Icons.call),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Call'),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular((25))),
                                  border: Border.all(
                                      width: 1.0,
                                      color: BrandColors.colorTextLight),
                                ),
                                child: CircleAvatar(
                                  radius: 30.0,
                                  backgroundImage: NetworkImage(driverImage),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              // Text(driverPlateNumber),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              cancelRequest();
                              resetApp();
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular((25))),
                                    border: Border.all(
                                        width: 1.0,
                                        color: BrandColors.colorTextLight),
                                  ),
                                  child: Icon(OMIcons.clear),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Cancel'),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).deliPickAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickupLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destionationLatLng =
        LatLng(destination.latitude, destination.longitude);

    MyMethods.showLoading('Please wait...', context);

    var thisDetails = await RequestMethods.getDirectionDetails(
        pickupLatLng, destionationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
    });
    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);
    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      /* loop through all PointLatLng points and convert them to a list of LatLng, required by polyline */
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Colors.black,
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      _polylines.add(polyline);
    });

    //make polyline fit

    LatLngBounds bounds;
    if (pickupLatLng.latitude > destionationLatLng.latitude &&
        pickupLatLng.longitude > destionationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destionationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destionationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest:
              LatLng(pickupLatLng.latitude, destionationLatLng.longitude),
          northeast:
              LatLng(destionationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destionationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest:
              LatLng(destionationLatLng.latitude, pickupLatLng.longitude),
          northeast:
              LatLng(pickupLatLng.latitude, destionationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destionationLatLng);
    }
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My Location'),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destionationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow:
          InfoWindow(title: destination.placeName, snippet: 'Destination'),
    );

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickupLatLng,
      fillColor: BrandColors.colorGreen,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destionationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

  void startGeofireListner() {
    Geofire.initialize('pickupsAvailable');

    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 20)
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];
            FireHelper.nearbyDriverList.add(nearbyDriver);
            if (driverKeyLoaded) {
              updateDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromList(map['key']);
            updateDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            // Update your key's location
            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];
            FireHelper.updateNearbyLocation(nearbyDriver);
            updateDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            driverKeyLoaded = true;
            updateDriversOnMap();

            break;
        }
      }
    });
  }

  void updateDriversOnMap() {
    setState(() {
      _markers.clear();
    });
    Set<Marker> tempMarkers = Set<Marker>();
    for (NearbyDriver driver in FireHelper.nearbyDriverList) {
      LatLng driverPosition = LatLng(driver.latitude, driver.longitude);
      Marker thisMarker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverPosition,
        icon: nearbyIcon,
        rotation: RequestMethods.generateRandomNumber(360),
      );
      tempMarkers.add(thisMarker);
    }
    setState(() {
      _markers = tempMarkers;
    });
  }

  //create the request
  void createRideRequest(amt) {
    rideRef = FirebaseDatabase.instance.reference().child('rideRequest').push();
    var mobile = Provider.of<AppData>(context, listen: false).userPhonenumber;
    var pickup = Provider.of<AppData>(context, listen: false).deliPickAddress;
    var item = Provider.of<AppData>(context, listen: false).getItem;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;
    Map pickupMap = {
      'latitude': pickup.latitude.toString(),
      'longitude': pickup.longitude.toString(),
    };
    Map destinationMap = {
      'latitude': destination.latitude.toString(),
      'longitude': destination.longitude.toString(),
    };
    Map rideMap = {
      'created_at': DateTime.now().toString(),
      'rider_name': currentUserInfo.fullname,
      'rider_phone': mobile,
      'pickup_address': pickup.placeName,
      'destination_address': destination.placeName,
      'location': pickupMap,
      'destination': destinationMap,
      'payment_method': Provider.of<AppData>(context, listen: false).payType,
      'driver_id': 'waiting',
      'info': 'New Delivery Request for this: $item',
      'type': 'delivery',
      'amount': '$amt',
    };
    rideRef.set(rideMap);

    rideSubscription = rideRef.onValue.listen((event) async {
      //check for null snapshot
      if (event.snapshot.value == null) {
        return;
      }

      //get car details
      if (event.snapshot.value['car_details'] != null) {
        setState(() {
          driverCarDetails = event.snapshot.value['car_details'].toString();
        });
      }

      // get driver name
      if (event.snapshot.value['driver_name'] != null) {
        setState(() {
          driverFullName = event.snapshot.value['driver_name'].toString();
        });
      }

      // get driver phone number
      if (event.snapshot.value['driver_phone'] != null) {
        setState(() {
          driverPhoneNumber = event.snapshot.value['driver_phone'].toString();
        });
      }

      // get driver plate number
      if (event.snapshot.value['driver_plateNumber'] != null) {
        setState(() {
          driverPlateNumber =
              event.snapshot.value['driver_plateNumber'].toString();
        });
      }

      // get driver image
      if (event.snapshot.value['driver_image'] != null) {
        setState(() {
          String driverImg = event.snapshot.value['driver_image'].toString();
          driverImage = 'https://democabglobal.com/$driverImg';
        });
      }

      // get driver id
      if (event.snapshot.value['driver_id'] != null) {
        setState(() {
          driverId = event.snapshot.value['driver_id'].toString();
        });
      }

      //get and use driver location updates
      if (event.snapshot.value['driver_location'] != null) {
        double driverLat = double.parse(
            event.snapshot.value['driver_location']['latitude'].toString());
        double driverLng = double.parse(
            event.snapshot.value['driver_location']['longitude'].toString());
        LatLng driverLocation = LatLng(driverLat, driverLng);

        if (status == 'accepted') {
          updateToPickup(driverLocation);
        } else if (status == 'ontrip') {
          updateToDestination(driverLocation);
        } else if (status == 'arrived') {
          setState(() {
            tripStatusDisplay = 'Driver has arrived';
          });
        }
      }

      if (event.snapshot.value['status'] != null) {
        status = event.snapshot.value['status'].toString();
      }

      if (status == 'accepted') {
        showTripSheet();
        Geofire.stopListener();
        removeGeofireMarkers();
      }

      if (status == 'ended') {
        if (event.snapshot.value['fares'] != null) {
          int fares = int.parse(event.snapshot.value['fares'].toString());
          String paym = event.snapshot.value['payment_method'].toString();
          var fare = (fares / 10).ceil() * 10;

          var response = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => CollectPayment(
              paymentMethod: paym,
              fares: fare,
              driverID: driverId,
            ),
          );

          if (response == 'close') {
            RequestMethods.setHistory(rideRef);
            showSnackBar('Successfully', scaffoldKey);
            saveMessage('Your delivery has been completed');
            rideRef.onDisconnect();
            rideRef = null;
            rideSubscription.cancel();
            rideSubscription = null;
            resetApp();
          }
          if (response == 'low') {
            showSnackBar('Wallet is low', scaffoldKey);
          }
        }
      }
    });
  }

  void removeGeofireMarkers() {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value.contains('driver'));
    });
  }

  void updateToPickup(LatLng driverLocation) async {
    if (!isRequestingLocationDetails) {
      isRequestingLocationDetails = true;

      var positionLatLng =
          LatLng(currentPosition.latitude, currentPosition.longitude);

      var thisDetails = await RequestMethods.getDirectionDetails(
          driverLocation, positionLatLng);

      if (thisDetails == null) {
        return;
      }

      setState(() {
        tripStatusDisplay = 'Driver is Arriving - ${thisDetails.durationText}';
      });

      isRequestingLocationDetails = false;
    }
  }

  void updateToDestination(LatLng driverLocation) async {
    if (!isRequestingLocationDetails) {
      isRequestingLocationDetails = true;

      var destination =
          Provider.of<AppData>(context, listen: false).destinationAddress;

      var destinationLatLng =
          LatLng(destination.latitude, destination.longitude);

      var thisDetails = await RequestMethods.getDirectionDetails(
          driverLocation, destinationLatLng);

      if (thisDetails == null) {
        return;
      }

      setState(() {
        tripStatusDisplay =
            'Driving to Destination - ${thisDetails.durationText}';
      });

      isRequestingLocationDetails = false;
    }
  }

  void cancelRequest() {
    rideRef.remove();

    setState(() {
      appState = 'NORMAL';
    });
  }

  resetApp() {
    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
      _markers.clear();
      _circles.clear();
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = 0;
      tripSheetHeight = 0;
      searchSheetHeight = (Platform.isAndroid) ? 275 : 300;
      mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
      drawerCanOpen = true;

      status = '';
      driverFullName = '';
      driverPhoneNumber = '';
      driverCarDetails = '';
      tripStatusDisplay = 'Driver is Arriving';
    });
    setupPositionLocator();
  }

  void noDriverFound() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoDriverDialog());
  }

  void findDriver() {
    if (availableDrivers.length == 0) {
      cancelRequest();
      resetApp();
      noDriverFound();
      return;
    }

    var driver = availableDrivers[0];

    notifyDriver(driver);

    availableDrivers.removeAt(0);

    //print(driver.key);
  }

  void notifyDriver(NearbyDriver driver) {
    DatabaseReference driverTripRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${driver.key}/newtrip');
    driverTripRef.set(rideRef.key);

    // Get and notify driver using token
    DatabaseReference tokenRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${driver.key}/token');

    tokenRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        String token = snapshot.value.toString();

        // send notification to selected driver
        RequestMethods.sendNotification(token, context, rideRef.key);
      } else {
        return;
      }

      const oneSecTick = Duration(seconds: 1);

      var timer = Timer.periodic(oneSecTick, (timer) {
        try {
          // stop timer when ride request is cancelled;
          if (appState != 'REQUESTING') {
            driverTripRef.set('cancelled');
            driverTripRef.onDisconnect();
            timer.cancel();
            driverRequestTimeout = 15;
          }

          driverRequestTimeout--;

          // a value event listener for driver accepting trip request
          driverTripRef.onValue.listen((event) {
            // confirms that driver has clicked accepted for the new trip request
            if (event.snapshot.value.toString() == 'accepted') {
              driverTripRef.onDisconnect();
              timer.cancel();
              driverRequestTimeout = 15;
            }
          });

          if (driverRequestTimeout == 0) {
            //informs driver that ride has timed out
            driverTripRef.set('timeout');
            driverTripRef.onDisconnect();
            driverRequestTimeout = 15;
            timer.cancel();

            //select the next closest driver
            findDriver();
          }
        } catch (e) {
          noDriverFound();
        }
      });
      /*
      var set_timer = Timer(Duration(seconds: 30), () {
        timer.cancel();
        noDriverFound();
      });
      set_timer.cancel();
      */
    });
  }
}
