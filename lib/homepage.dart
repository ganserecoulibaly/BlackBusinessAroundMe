import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';
import 'commerce.dart';

class HomePage extends StatefulWidget {

  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Completer<GoogleMapController> _controller = Completer();

  double zoomVal = 5.0;
  Location location;
  LocationData locationData;

  static LatLng _initialPosition;
  //static LatLng _lastMapPosition = _initialPosition;

  //Stream<LocationData> stream;
  //Future<LocationData> currentLocation;

  List<Commerce> commerceList = [
    new Commerce('africaLounge','Africa Lounge','20Bis Rue Jean Giraudoux',75016,'Paris','France','Restaurant traditionnel',48.869516, 2.296839,'https://www.restaurant-africanlounge.com/'),
    new Commerce('oPetitClub','O Petit Club','14 boulvard Richard wallace',92800,'Puteaux','France','Restauration',48.8791494,2.2415844,'https://www.opetitclub.fr/'),
    new Commerce('babaZulu','Baba Zulu','23 Rue Beaurepaire',75010,'Paris','France','Restaurant',48.8711114, 2.3617974,''),
    new Commerce('MamahDoucara','Mamah Doucara','3 rue abbeville',75010,'Paris','France','Concept Store',48.8782176, 2.348705,''),
    new Commerce('artEnDanse','Art en danse','22-40 Rue Garibaldi,',93100,'Montreuil','France','Cours de danse',48.8556777, 2.4266529,'http://art-en-danse.com/'),
    new Commerce('sadiaEsthetiqueMeaux','Sadia Esthetique Meaux','30 Avenue de l Épinette',77100,'Meaux','France','Institut de beauté',48.9592697, 2.9047805,'https://sadiaesthetique.business.site/'),
    new Commerce('keurBoutique','Keur Boutique','39 Rue Jean-Baptiste Pigalle',75009,'Paris','France','Accessoires wax',48.880013, 2.3343074,'https://keurselection.fr/'),
    new Commerce('AIA Beautyhouse','AIA Beautyhouse','Chaussée d\'ixelles, 245',1050,'Bruxelles','Belgique','Institut de beauté',50.8309644,4.3509764,''),
    new Commerce('Le Kalu Ethnic Food','Le Kalu Ethnic Food','83 rue de l\'église Saint-Gilles',1060,'Bruxelles','Belgique','Restauration',50.8300998,4.3435072,''),
    new Commerce('Hype Barbershop','Hype Barbershop','Klapdorp 24, Antwerpen',2000,'Anvers','Belgique','Coiffeur',51.2243635,4.4022938,''),
    new Commerce('Loa','Loa','Hoogstraat 77,Antwerpen',2000,'Anvers','Belgique','Restauration à emporter',51.2183963,4.3971579,'')

  ];


  Set<Marker> markers = Set();

  @override
  void initState() {
    super.initState();
    //location = new Location();
    _getUserLocation();
    _addMarker(commerceList,markers);
  }

  /*
  void goWanted(){
    Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) {
      return new wanted("Demande de nouveaux business");
    }));
  }
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text("Black Business around Me",
            textAlign: TextAlign.center,),
          actions: <Widget>[
            /*
          IconButton(
              icon: Icon(FontAwesomeIcons.search),
              onPressed: () {
                //
              }), */
          ],
        ),
        body: Stack(
          children: <Widget>[
            _buildGoogleMap(context),
            _zoomminusfunction(),
            _zoomplusfunction(),
            _buildContainer(),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                //ajout nouveau commerce
                icon: Icon(Icons.add),
                color: Colors.black,
                onPressed: () {},
              ),
              IconButton(
                //refresh la map
                icon: Icon(Icons.refresh),
                color: Colors.black,
                onPressed: () {_buildGoogleMap(context);}, // _buildGoogleMap(context)
              ),
              IconButton(
                //demander un nouveau commerce
                icon: Icon(Icons.contact_mail),
                color: Colors.black,
                onPressed: (){
                  Navigator.pushNamed(context, '/wanted');
                },
              )
            ],
          ),
        )
    );
  }

  void _addMarker(List<Commerce> commerceList, Set<Marker> markers) {
    for (var i = 0; i < commerceList.length; i++) {
      // Create a new marker
      Marker resultMarker = Marker(
        markerId: MarkerId(commerceList[i].id),
        position: LatLng(commerceList[i].lat, commerceList[i].long),
        infoWindow: InfoWindow(title: commerceList[i].nom,
            snippet: commerceList[i].secteur,
            onTap: () => launch(commerceList[i].url)),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
      );

      // Add it to Set
      markers.add(resultMarker);
    }
  }

  Widget _zoomminusfunction() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
          icon: Icon(FontAwesomeIcons.searchMinus, color: Color(0xff6200ee)),
          onPressed: () {
            zoomVal--;
            _minus(zoomVal);
          }),
    );
  }

  Widget _zoomplusfunction() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
          icon: Icon(FontAwesomeIcons.searchPlus, color: Color(0xff6200ee)),
          onPressed: () {
            zoomVal++;
            _plus(zoomVal);
          }),
    );
  }

  Future<void> _minus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _initialPosition, zoom: zoomVal)));
  }

  Future<void> _plus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _initialPosition, zoom: zoomVal)));
  }

  void _getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition();
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(
        position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      //print('${placemark[0].name}');
      print("Nouvelle position: ${position.latitude} / ${position.longitude}");
    });
  }


/*
  getFirstLocation() async {
    try {
      locationData = await location.getLocation();
      print("Nouvelle position: ${locationData.latitude} / ${locationData
          .longitude}");
    } catch (e) {
      print("Nous avons une erreur: $e");
    }
  }

  listenToStream() {
    stream = location.onLocationChanged;
    stream.listen((newPosition) {
      print("New => ${newPosition.latitude} ------- ${newPosition.longitude}");
    });
  }
*/

  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            SizedBox(width: 10.0),
            /*  Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://lh5.googleusercontent.com/p/AF1QipO3VPL9m-b355xWeg4MXmOQTauFAEkavSluTtJU=w225-h160-k-no",
                  40.738380, -73.988426,"Gramercy Tavern"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://lh5.googleusercontent.com/p/AF1QipMKRN-1zTYMUVPrH-CcKzfTo6Nai7wdL7D8PMkt=w340-h160-k-no",
                  40.761421, -73.981667,"Le Bernardin"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://images.unsplash.com/photo-1504940892017-d23b9053d5d4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
                  40.732128, -73.999619,"Blue Hill"),
            ),
            SizedBox(width: 10.0), */
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
              GestureDetector(
                onTap: () {
                  _gotoLocation(48.8711079, 2.3639914);
                },
                child: Container(
                  child: new FittedBox(
                    child: Material(
                        color: Colors.white,
                        elevation: 14.0,
                        borderRadius: BorderRadius.circular(24.0),
                        shadowColor: Color(0x802196F3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: 180,
                              height: 200,
                              child: ClipRRect(
                                borderRadius: new BorderRadius.circular(24.0),
                                child: Image(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                      "https://images.unsplash.com/photo-1549661704-c192f6238169?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=700&q=80"),
                                ),
                              ),),
                            Container(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceEvenly,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0),
                                        child: Container(
                                            child: Text('Baba Zulu',
                                              style: TextStyle(
                                                  color: Color(0xff6200ee),
                                                  fontSize: 24.0,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      ),
                                      SizedBox(height: 5.0),
                                      Container(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceEvenly,
                                            children: <Widget>[
                                              Container(
                                                  child: Text(
                                                    "4.5",
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 18.0,
                                                    ),
                                                  )),
                                              Container(
                                                child: Icon(
                                                  FontAwesomeIcons.solidStar,
                                                  color: Colors.amber,
                                                  size: 15.0,
                                                ),
                                              ),
                                              Container(
                                                child: Icon(
                                                  FontAwesomeIcons.solidStar,
                                                  color: Colors.amber,
                                                  size: 15.0,
                                                ),
                                              ),
                                              Container(
                                                child: Icon(
                                                  FontAwesomeIcons.solidStar,
                                                  color: Colors.amber,
                                                  size: 15.0,
                                                ),
                                              ),
                                              Container(
                                                child: Icon(
                                                  FontAwesomeIcons.solidStar,
                                                  color: Colors.amber,
                                                  size: 15.0,
                                                ),
                                              ),
                                              Container(
                                                child: Icon(
                                                  FontAwesomeIcons
                                                      .solidStarHalf,
                                                  color: Colors.amber,
                                                  size: 15.0,
                                                ),
                                              ),
                                              Container(
                                                  child: Text(
                                                    "(216)",
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 18.0,
                                                    ),
                                                  )),
                                            ],
                                          )),
                                      SizedBox(height: 5.0),
                                      /*Container(
                                                    child: Text(
                                                    "American \u00B7 \u0024\u0024 \u00B7 1.6 mi",
                                                    style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 18.0,
                                                    ),
                                                    )),*/
                                      SizedBox(height: 5.0),
                                      Container(
                                          child: Text(
                                            "Ouvert de Lun à Sam 12h-14h et 19h-22h30",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ],
                                  )
                              ),
                            ),
                          ],)
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
              GestureDetector(
                onTap: () {
                  _gotoLocation(48.880013, 2.3343074);
                },
                child: Container(
                  child: new FittedBox(
                    child: Material(
                        color: Colors.white,
                        elevation: 14.0,
                        borderRadius: BorderRadius.circular(24.0),
                        shadowColor: Color(0x802196F3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: 180,
                              height: 200,
                              child: ClipRRect(
                                borderRadius: new BorderRadius.circular(24.0),
                                child: Image(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                      "http://keurselection.fr/wp-content/uploads/2014/10/Keur-2014-Photo-Cyrille-Robin-3-LOW-RES-JPG1.jpg"),
                                ),
                              ),),
                            Container(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceEvenly,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0),
                                        child: Container(
                                            child: Text('Keur Boutique',
                                              style: TextStyle(
                                                  color: Color(0xff6200ee),
                                                  fontSize: 24.0,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      ),
                                      SizedBox(height: 5.0),
                                      Container(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceEvenly,
                                            children: <Widget>[
                                              Container(
                                                  child: Text(
                                                    "5.0",
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 18.0,
                                                    ),
                                                  )),
                                              Container(
                                                child: Icon(
                                                  FontAwesomeIcons.solidStar,
                                                  color: Colors.amber,
                                                  size: 15.0,
                                                ),
                                              ),
                                              Container(
                                                child: Icon(
                                                  FontAwesomeIcons.solidStar,
                                                  color: Colors.amber,
                                                  size: 15.0,
                                                ),
                                              ),
                                              Container(
                                                child: Icon(
                                                  FontAwesomeIcons.solidStar,
                                                  color: Colors.amber,
                                                  size: 15.0,
                                                ),
                                              ),
                                              Container(
                                                child: Icon(
                                                  FontAwesomeIcons.solidStar,
                                                  color: Colors.amber,
                                                  size: 15.0,
                                                ),
                                              ),
                                              Container(
                                                child: Icon(
                                                  FontAwesomeIcons.solidStar,
                                                  color: Colors.amber,
                                                  size: 15.0,
                                                ),
                                              ),
                                              Container(
                                                  child: Text(
                                                    "(15)",
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 18.0,
                                                    ),
                                                  )),
                                            ],
                                          )),
                                      SizedBox(height: 5.0),
                                      /*Container(
                                                    child: Text(
                                                    "American \u00B7 \u0024\u0024 \u00B7 1.6 mi",
                                                    style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 18.0,
                                                    ),
                                                    )),*/
                                      SizedBox(height: 5.0),
                                      Container(
                                        child: Text(
                                          "Ouvert de Mar à Ven 10h30-19h et Sam 10h30-19h30",
                                          softWrap: true,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                            ),
                          ],)
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _boxes(String _image, double lat, double long, String restaurantName) {
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
      },
      child: Container(
        child: new FittedBox(
          child: Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 180,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(_image),
                      ),
                    ),),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myDetailsContainer1(restaurantName),
                    ),
                  ),
                ],)
          ),
        ),
      ),
    );
  }

  Widget myDetailsContainer1(String restaurantName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              child: Text(restaurantName,
                style: TextStyle(
                    color: Color(0xff6200ee),
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold),
              )),
        ),
        SizedBox(height: 5.0),
        Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                    child: Text(
                      "4.1",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18.0,
                      ),
                    )),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStar,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStar,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStar,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStar,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStarHalf,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                    child: Text(
                      "(946)",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18.0,
                      ),
                    )),
              ],
            )),
        SizedBox(height: 5.0),
        Container(
            child: Text(
              "American \u00B7 \u0024\u0024 \u00B7 1.6 mi",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
              ),
            )),
        Container(
            child: Text(
              "Closed \u00B7 Opens 17:00 Thu",
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            )),
        SizedBox(height: 5.0),
      ],
    );
  }

  _buildGoogleMap(BuildContext context) {
    //locationData = await location.getLocation();
    return _initialPosition == null ? Container(child: Center(child:
    Text('loading map..',
      style:
      TextStyle(fontFamily: 'Avenir-Medium', color: Colors.grey[400]),),),) :
    Container(
      height: MediaQuery
          .of(context)
          .size
          .height,
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
            target: _initialPosition, zoom: 12),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
      ),
    );
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, long), zoom: 15, tilt: 50.0,
          bearing: 45.0,)));
  }


}
