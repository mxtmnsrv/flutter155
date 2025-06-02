import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:GarageSync/services/auth/auth_gate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

//import 'package:GarageSync/pages/ChatPagesList.dart';
import 'package:GarageSync/pages/Login.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(AraEleman());
}

class AraEleman extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AuthGate(), // Başlangıçta giriş ekranını göster
    );
  }
}

//////////////////////

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(
        title: 'Flutter Demo Home Page',
        password: '',
        username: '',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key,
      required this.title,
      required this.username,
      required this.password});

  final String title, username, password;

  @override
  State<MyHomePage> createState() =>
      _MyHomePageState(sifre: password, kullanici: username);
}

class _MyHomePageState extends State<MyHomePage> {
  final String sifre;
  final String kullanici;

  _MyHomePageState({required this.sifre, required this.kullanici});

  MapController mapController = MapController();
  late String imageUrl;
  final storage = FirebaseStorage.instance;
  final refff = FirebaseDatabase.instance.ref();
  LatLng _markerLoc = LatLng(40.90659952, 29.15410012);
  late var latitude, longitude;
  Position? _currentPosition;
  late StreamSubscription<Position> _positionStream;
  final _imagesRef = FirebaseDatabase.instance.ref().child('Targets');
  final DatabaseReference _selectedImgRef =
      FirebaseDatabase.instance.ref().child('selected_img');
  final DatabaseReference _hedefButonu =
      FirebaseDatabase.instance.ref().child('Selected_Image');
  final DatabaseReference _markerLocationRef =
      FirebaseDatabase.instance.ref().child('Marker');
  bool isSelected = false;
  String? selectedImageId;
  List<Map<String, dynamic>> images = [];
  double _currentHeading = 1000;
  late StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<DatabaseEvent>? _markerSubscription;
  var _compassDirection = 0.0;
  StreamSubscription? _authoritySubscription;
  List<Marker> _markers = [];
  bool inView = false;
  int colorIndex = 0;
  final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.grey,
    Colors.red,
    Colors.pinkAccent,
    Colors.brown,
    Colors.lime
  ];
  Random random = Random();

  @override
  void initState() {
    super.initState();
    imageUrl = '';
    mapController = MapController();
    getImageUrl2(); //getImageURL idi değiştirdim.
    _listenToData();
    _setupDatabaseListener();
    _getLocation();
    _startCompassUpdates();
    _loadMarkers();
  }

  void _startCompassUpdates() {
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (event.heading != null) {
        setState(() {
          _currentHeading = event.heading!;
        });
      }
    });
  }

  void _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    _positionStream =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _performAction() async {
    await _getCurrentLocation();
    if (_currentPosition != null) {
      refff.child('${sifre}/Position').update({
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'altitude': _currentPosition!.altitude,
      });
      if (_currentHeading != 1000) {
        refff.child('${sifre}/Position').update({'angle': _currentHeading});
      }
    }
  }

  void _setupDatabaseListener() {
    _authoritySubscription =
        refff.child('$sifre/Authority').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == true && mounted) {
        _showAlertDialog();
      }
    });
  }

  void _showAlertDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yetkilendirildiniz'),
          content: Text('Yetki verildi!'),
          actions: [
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _loadMarkers() {
    _imagesRef.onValue.listen((event) {
      if (event.snapshot.value == null) {
        return;
      }

      final dynamic snapshotValue = event.snapshot.value;
      final newMarkers = <Marker>[];

      // Check if the snapshot value is a Map
      if (snapshotValue is Map<dynamic, dynamic>) {
        final people = Map<dynamic, dynamic>.from(snapshotValue);

        people.forEach((key, value) {
          bool inView = value['in_view'] ?? false;
          if (value != null && inView == true) {
            final lat = (value['latitude'] as num?)?.toDouble();
            final lon = (value['longitude'] as num?)?.toDouble();
            int colorIndx =
                int.tryParse(key.toString()) ?? 3; // ID'yi anahtardan al
            //colorIndx--;
            if (colorIndx < 0) colorIndx = 0;
            if (colorIndx > 9) colorIndx = colorIndx % 10;

            if (lat != null && lon != null) {
              final marker = Marker(
                width: 40.0,
                height: 40.0,
                point: LatLng(lat, lon),
                child: Icon(
                  Icons.location_on,
                  color: colors[colorIndx],
                  size: 35.0,
                ),
              );
              newMarkers.add(marker);
            }
          }
        });
      }
      //             the snapshot value is a List
      else if (snapshotValue is List<dynamic>) {
        for (var i = 0; i < snapshotValue.length; i++) {
          final value = snapshotValue[i];
          if (value != null && value is Map<dynamic, dynamic>) {
            bool inView = value['in_view'] ?? false;
            if (inView == true) {
              final lat = (value['latitude'] as num?)?.toDouble();
              final lon = (value['longitude'] as num?)?.toDouble();
              int colorIndx = i; // ID'yi indeks olarak al
              //colorIndx--;
              if (colorIndx < 0) colorIndx = 0;
              if (colorIndx > 9) colorIndx = colorIndx % 10;

              if (lat != null && lon != null) {
                final marker = Marker(
                  width: 40.0,
                  height: 40.0,
                  point: LatLng(lat, lon),
                  child: Icon(
                    Icons.location_on,
                    color: colors[colorIndx],
                    size: 35.0,
                  ),
                );
                newMarkers.add(marker);
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _markers = newMarkers;
        });
      }
    });
  }

  void _listenToData() {
    _markerSubscription = _markerLocationRef.onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null && snapshot.value is Map) {
        var valueMap = snapshot.value as Map;
        if (valueMap.containsKey('latitude') &&
            valueMap.containsKey('longitude')) {
          latitude = (valueMap['latitude'] as num).toDouble();
          longitude = (valueMap['longitude'] as num).toDouble();
          final compass = (valueMap['compass'] as num).toDouble();
          if (mounted) {
            setState(() {
              _markerLoc = LatLng(latitude, longitude);
              _compassDirection = compass;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _positionStream.cancel();
    _compassSubscription?.cancel();
    _imagesRef.onValue.listen((event) {}).cancel();
    _markerSubscription?.cancel();
    _authoritySubscription?.cancel();
    super.dispose();
  }

  Future<void> getImageUrl() async {
    final ref = storage.ref().child('airplane-mode.png');
    final url = await ref.getDownloadURL();
    setState(() {
      imageUrl = url;
    });
  }

  Future<void> getImageUrl2() async {
    final ref =
        refff.child('$sifre/Profil_URL').onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      imageUrl = data.toString();
    });
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    DataSnapshot snapshot = await refff.child('$sifre/Authority').get();

    if (snapshot.value == true) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Emin misiniz?'),
            content: Text('Görevi başlatmak istediğinizden EMİN MİSİNİZ?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dialogu kapat
                },
                child: Text('Hayır'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dialogu kapat
                  _performAction();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ImageSelectionPage()),
                  );
                },
                child: Text('Evet'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('UYARI'),
            content: Text('Görevi başlatma yetkiniz bulunmuyor.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dialogu kapat
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
    }
  }

  void _selectImage(String imageId) {
    setState(() {
      selectedImageId = imageId;
    });
  }

  final test = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.black26,
      //-/*/*/*--AppBar kısmını silebilrim. Çünkü girişten bu sayfaya geçerken otomatik GERI TUSU(<-) ekliyordu. Buton şimdi eklenmiyor.
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Color(0xFF535353),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Row(
          children: [
            SafeArea(
                child: ClipOval(
              child: Image.network(
                imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.account_circle_rounded);
                },
              ),
            )),
            SizedBox(width: 10),
            Text(
              '${kullanici}',
              style: TextStyle(
                color: Colors.white70,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          /*
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageSelectionPage()),
              );
            },
          ),*/
          IconButton(
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
                await refff.child(widget.password).update({'Online': false});
                await refff.child(widget.password).update({'Authority': false});
                await _selectedImgRef.update({'isSelected': false});
                await refff.update({'Selected_Image': -1});
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.grey,
              ))
        ],
      ),

      body: SafeArea(
        child: Stack(
          children: [
            Container(
              //height: 200,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(initialCenter: _markerLoc, zoom: 18.0),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: _markerLoc,
                      child: Transform.rotate(
                        child: Icon(Icons.airplanemode_on, size: 43),
                        angle: _compassDirection * (3.14159 / 180),
                      ),
                    ),
                    if (_currentPosition != null)
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        child: Icon(
                          size: 45,
                          Icons.emoji_people,
                          color: Colors.indigo,
                        ),
                      ),
                    ..._markers,
                  ])
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(3),
                  height: 35,
                  alignment: Alignment.topLeft,
                  child: FloatingActionButton(
                    heroTag: "button1",
                    onPressed: () {
                      // Butona tıklandığında zoom değerini artır
                      mapController.move(
                          mapController.center, mapController.zoom + 1.0);
                    },
                    child: Icon(
                      Icons.zoom_in,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(3, 0, 0, 0),
                  height: 35,
                  alignment: Alignment.topLeft,
                  child: FloatingActionButton(
                    heroTag: "button2",
                    onPressed: () {
                      // Butona tıklandığında zoom değerini azaltır
                      mapController.move(
                          mapController.center, mapController.zoom - 1.0);
                    },
                    child: Icon(
                      Icons.zoom_out,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                SizedBox(
                  height: 7,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(3, 0, 0, 0),
                  height: 40,
                  alignment: Alignment.topLeft,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        mapController.move(_markerLoc, mapController.zoom);
                      });
                    },
                    icon: Icon(
                      Icons.airplane_ticket_sharp,
                    ),
                    label: Text('İHA'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(3),
                  height: 40,
                  alignment: Alignment.topLeft,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        mapController.move(
                            LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude),
                            mapController.zoom);
                      });
                    },
                    icon: Icon(Icons.emoji_people_sharp),
                    label: Text('BEN'),
                  ),
                ),
                StreamBuilder<DatabaseEvent>(
                  stream: _selectedImgRef.child('isSelected').onValue,
                  builder: (context, snapshot) {
                    //if (snapshot.connectionState == ConnectionState.waiting) {
                    //return SizedBox.shrink();
                    //}

                    if (snapshot.hasData) {
                      final data = snapshot.data!.snapshot.value;

                      if (data != null) {
                        //print('Data received: $data'); // Veriyi konsola yazdır
                        if (data is bool) {
                          isSelected = data;
                          //print('Data receivedkk: $isSelected');
                        } else {}
                      }

                      return isSelected
                          ? Container(
                              margin: EdgeInsets.fromLTRB(3, 0, 0, 0),
                              height: 40,
                              alignment: Alignment.topLeft,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  int keyID =
                                      (await _hedefButonu.get()).value as int;

                                  var latitudeSnapshot = await _imagesRef
                                      .child('$keyID/latitude')
                                      .get();
                                  var longitudeSnapshot = await _imagesRef
                                      .child('$keyID/longitude')
                                      .get();

                                  if (latitudeSnapshot.exists &&
                                      longitudeSnapshot.exists) {
                                    var latitudeHedef =
                                        (latitudeSnapshot.value as num)
                                            .toDouble();
                                    var longitudeHedef =
                                        (longitudeSnapshot.value as num)
                                            .toDouble();

                                    setState(() {
                                      mapController.move(
                                          LatLng(latitudeHedef, longitudeHedef),
                                          mapController.zoom);
                                    });
                                  } else {
                                    // Eğer latitude veya longitude verisi yoksa yapılacak işlemler
                                    print(
                                        "Latitude veya Longitude değeri bulunamadı.");
                                  }
                                },
                                icon: Icon(Icons.warning),
                                label: Text('HEDEF'),
                              ),
                            )
                          : SizedBox
                              .shrink(); // Return an empty widget if the button should not be shown
                    } else {
                      return SizedBox
                          .shrink(); // Return an empty widget if no data is available
                    }
                  },
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 50,
                    width: 250,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      onPressed: () {
                        _showConfirmationDialog(context);
                      },
                      child: Text('Görevi Başlat',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.5)), // Butonun içindeki metin
                    ),
                  ),
                  Container(
                    width: 180,
                    margin: EdgeInsetsDirectional.only(bottom: 12, top: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      onPressed: () {
                        // Butona tıklandığında yapılacak işlemler buraya yazılır.
                        print('Button pressed!');
                      },
                      child: Text(
                        'Görevi Bitir',
                        style: TextStyle(color: Colors.white),
                      ), // Butonun içindeki metin
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              left: 5,
              child: StreamBuilder(
                stream: _imagesRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data!.snapshot.value != null) {
                    var data = snapshot.data!.snapshot.value;
                    Map<dynamic, dynamic> images;
                    if (data is List) {
                      images = Map.fromIterable(
                        data.asMap().entries,
                        key: (entry) => entry.key.toString(),
                        value: (entry) => entry.value,
                      );
                    } else {
                      if (data is Map) {
                        // Eğer data bir Map ise, dönüştürme yap
                        images = Map<dynamic, dynamic>.from(data as Map);
                      } else {
                        // Eğer data Map değilse, null ya da boş bir değer ata veya farklı bir işlem yap
                        images =
                            {}; // Boş bir map oluşturabilirsiniz veya uygun bir default işlem yapabilirsiniz
                        //print("Veri Map formatında değil: $data");
                      }
                    }

                    inView = images.values.any((element) =>
                        element != null && element['in_view'] == true);
                  }
                  return Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.black.withOpacity(0.5),
                    child: Text(
                      inView ? 'Hedef: Mevcut' : 'Hedef: Bulunmuyor',
                      style: TextStyle(
                          color: inView ? Colors.white : Colors.red,
                          fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageSelectionPage extends StatefulWidget {
  @override
  _ImageSelectionPageState createState() => _ImageSelectionPageState();
}

class _ImageSelectionPageState extends State<ImageSelectionPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('Targets');
  final DatabaseReference _isSelectedRef =
      FirebaseDatabase.instance.ref().child('selected_img');
  String? _selectedImageUrl;
  String? _selectedKey;
  Map<String, dynamic>? _selectedImageData;
  final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.grey,
    Colors.red,
    Colors.pinkAccent,
    Colors.brown,
    Colors.lime
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Takip edilecek hedef seçin'),
      ),
      body: StreamBuilder(
        stream: _databaseReference.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = snapshot.data!.snapshot.value;
            if (data is Map<dynamic, dynamic>) {
              Map<dynamic, dynamic> images = data;
              List<Widget> imageWidgets = [];

              images.forEach((key, value) {
                if (value is Map<dynamic, dynamic>) {
                  bool inView = value['in_view'] ?? false;
                  String base64String = value['image'] ?? '';
                  String? imageUrl;
                  if (base64String.startsWith("data:image/")) {
                    // "data:image/jpeg;base64," veya "data:image/png;base64," kısmını kaldırarak saf Base64 verisini elde et
                    imageUrl = base64String.split(',').last;
                  } else {
                    // Eğer base64 stringi format bilgisini içermiyorsa, doğrudan kullan
                    imageUrl = base64String;
                  }
                  //String imageUrl = value['image'] ?? '';
                  bool isSelected = _selectedKey == key.toString();
                  int colorIndx = int.tryParse(key) ?? 3;
                  //colorIndx--;
                  if (colorIndx < 0) colorIndx = 0;
                  if (colorIndx > 9) colorIndx = colorIndx % 10;

                  if (imageUrl.isNotEmpty) {
                    imageWidgets.add(
                      GestureDetector(
                        onTap: inView
                            ? () => _selectImage(key.toString(), value)
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: inView ? colors[colorIndx] : Colors.black,
                              width: 4.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  inView ? Colors.transparent : Colors.grey,
                                  BlendMode.saturation,
                                ),
                                child: Image.memory(
                                  base64Decode(imageUrl),
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: double.infinity,
                                ),
                              ),
                              if (!inView)
                                Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 50,
                                ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 50,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }
              });

              return GridView.count(
                crossAxisCount: 2,
                children: imageWidgets,
              );
            } else if (data is List<Object?>) {
              // Eğer veri List<Object?> türündeyse, listeyi işleyin
              List<Widget> imageWidgets = [];

              for (var i = 0; i < data.length; i++) {
                final value = data[i];
                if (value is Map<dynamic, dynamic>) {
                  bool inView = value['in_view'] ?? false;
                  String base64String = value['image'] ?? '';
                  String? imageUrl;
                  if (base64String.startsWith("data:image/")) {
                    // "data:image/jpeg;base64," veya "data:image/png;base64," kısmını kaldırarak saf Base64 verisini elde et
                    imageUrl = base64String.split(',').last;
                  } else {
                    // Eğer base64 stringi format bilgisini içermiyorsa, doğrudan kullan
                    imageUrl = base64String;
                  }
                  //String imageUrl = value['url'] ?? '';
                  bool isSelected = _selectedKey == i.toString();
                  int colorIndx = i;
                  //colorIndx--;
                  if (colorIndx < 0) colorIndx = 0;
                  if (colorIndx > 9) colorIndx = colorIndx % 10;

                  if (imageUrl.isNotEmpty) {
                    imageWidgets.add(
                      GestureDetector(
                        onTap: inView
                            ? () => _selectImage(i.toString(), value)
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: inView ? colors[colorIndx] : Colors.black,
                              width: 4.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  inView ? Colors.transparent : Colors.grey,
                                  BlendMode.saturation,
                                ),
                                child: Image.memory(
                                  base64Decode(imageUrl),
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: double.infinity,
                                ),
                              ),
                              if (!inView)
                                Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 50,
                                ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 50,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }
              }

              return GridView.count(
                crossAxisCount: 2,
                children: imageWidgets,
              );
            } else {
              return Center(child: Text('Invalid data format.'));
            }
          } else {
            return Center(child: Text('Seçilebilir hedef bulunmuyor.'));
          }
        },
      ),
      floatingActionButton: _selectedKey != null
          ? FloatingActionButton(
              child: Icon(Icons.send),
              onPressed: () {
                _confirmSelection();
              },
            )
          : null,
    );
  }

  void _selectImage(String key, Map<dynamic, dynamic> value) {
    setState(() {
      //_selectedImageUrl = value['url'];
      _selectedKey = key;
      _selectedImageData = {
        //'url': value['url'],
        'in_view': value['in_view'],
        'latitude': value['latitude'],
        'longitude': value['longitude'],
      };
    });
  }

  void _updateInViewStates(String? selectedKey) {
    _databaseReference.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value;
        if (data is Map<dynamic, dynamic>) {
          Map<dynamic, dynamic> images = data;

          images.forEach((key, value) {
            if (key != selectedKey) {
              _databaseReference
                  .child(key.toString())
                  .update({'in_view': false});
            }
          });
        } else if (data is List) {
          for (int i = 0; i < data.length; i++) {
            if (data[i] != null &&
                data[i] is Map &&
                i.toString() != selectedKey) {
              _databaseReference.child(i.toString()).update({'in_view': false});
            }
          }
        }
      }
    }).catchError((error) {
      print('Error: $error');
    });
  }

//confirmselection yeni eklendi deneme yapılmadı
  void _confirmSelection() {
    if (_selectedKey != null && _selectedImageData != null) {
      final DatabaseReference selectedImgRef = FirebaseDatabase.instance.ref();

      selectedImgRef
          .update({'Selected_Image': int.parse(_selectedKey!)}).then((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Resim seçildi'),
            content: Text('Seçilen resim bilgisi veritabanına iletildi.'),
            actions: [
              TextButton(
                onPressed: () {
                  _isSelectedRef.update({'isSelected': true});
                  _updateInViewStates(_selectedKey);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Close the ImageSelectionPage
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }).catchError((error) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while saving the image to the database.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }
}
