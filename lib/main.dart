import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wasteAdvisor/api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Waste Advisor',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'WASTE ADVISOR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  List _outputs = null;
  File _image = null;
  bool _loading = false;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      //backgroundColor: Colors.greenAccent,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 30,
            color: Colors.indigo[900],
          ),
        ),
        elevation: 10,
        backgroundColor: Colors.greenAccent,
        toolbarHeight: 60,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 300,
              padding: const EdgeInsets.only(top: 100),
              child: Center(
                child: _image == null
                    ? Container()
                    : Container(
                        width: 400,
                        height: 300,
                        child: Image.file(
                          _image,
                          width: 400,
                          height: 300,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
              ),
            ),
            Container(
              height: 200,
              width: 350,
              child: Column(
                // Column is also a layout widget. It takes a list of children and
                // arranges them vertically. By default, it sizes itself to fit its
                // children horizontally, and tries to be as tall as its parent.
                //
                // Invoke "debug painting" (press "p" in the console, choose the
                // "Toggle Debug Paint" action from the Flutter Inspector in Android
                // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                // to see the wireframe for each widget.
                //
                // Column has various properties to control how it sizes itself and
                // how it positions its children. Here we use mainAxisAlignment to
                // center the children vertically; the main axis here is the vertical
                // axis because Columns are vertical (the cross axis would be
                // horizontal).
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _image == null
                      ? Text(
                          'Hi! I\'m your Waste Adviser...',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.indigo[900],
                          ),
                          textAlign: TextAlign.left,
                        )
                      : Container(
                          height: 0,
                        ),
                  _image == null
                      ? Text(
                          'Show me a waste item...',
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.indigo[900],
                          ),
                          textAlign: TextAlign.left,
                        )
                      : _outputs != null
                          ? Text(
                              "${_outputs.first}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                              ),
                            )
                          : CircularProgressIndicator(),
                ],
              ),
            ),
            ElevatedButton(
              child: Text('Show Me'),
              style: ElevatedButton.styleFrom(primary: Colors.indigo[900]),
              onPressed: () {
                setState(() {
                  _image = null;
                  _outputs = null;
                });
                pickImage();
              },
            )
          ],
        ),
      ),
    );
  }

  pickImage() async {
    setState(() {
      _loading = true;
      _outputs = null;
    });
    _showPicker(context);
    classifyOnline(_image);
  }

  classifyOnline(File image) async {
    var output = await uploadImage(image);
    setState(() {
      _loading = false;
      _outputs = [output];
    });
  }

  classifyOffline(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
    );
    print(image.path);
    print(output);
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/converted_model.tflite",
      labels: "assets/labels.txt",
    );
  }

  //code for image picker
  _imgFromCamera() async {
    var _pickedFile = await picker.getImage(
        source: ImageSource.camera,
        imageQuality: 90, // <- Reduce Image quality
        maxHeight: 700, // <- reduce the image size
        maxWidth: 700);

    var image = File(_pickedFile.path);

    setState(() {
      _image = image;
      _loading = false;
      _outputs = null;
    });
    classifyOnline(image);
  }

  _imgFromGallery() async {
    var _pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      //imageQuality: 80, // <- Reduce Image quality
      //maxHeight: 700, // <- reduce the image size
      //maxWidth: 700);
    );
    var image = File(_pickedFile.path);

    setState(() {
      _image = image;
      _loading = false;
      _outputs = null;
    });
    classifyOnline(image);
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                        setState(() {
                          //
                        });
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                      setState(() {
                        //
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
