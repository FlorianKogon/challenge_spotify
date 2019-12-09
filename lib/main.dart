import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'music.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.brown),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _Home();
  }
}

class _Home extends State<Home> {
  List<Music> myMusicList = [
    Music(
        'Theme Swift',
        'Codabee',
        'https://codabee.com/wp-content/uploads/2018/06/un.mp3',
        "https://cdn.pixabay.com/photo/2019/11/27/23/35/elephant-4658095__480.jpg"),
    Music(
        'Theme Flutter',
        'Codabee',
        'https://codabee.com/wp-content/uploads/2018/06/deux.mp3',
        'https://cdn.pixabay.com/photo/2019/11/21/06/13/peacock-4641792__480.jpg')
  ];

  AudioPlayer audioPlayer;

  // ignore: cancel_subscriptions
  StreamSubscription positionSub;

  // ignore: cancel_subscriptions
  StreamSubscription stateSub;
  Music myCurrentMusic;
  Duration position = Duration(seconds: 0);
  Duration duree = Duration(seconds: 10);
  PlayerState status = PlayerState.stopped;
  int index = 0;

  @override
  void initState() {
    super.initState();
    myCurrentMusic = myMusicList[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        leading: Icon(Icons.insert_drive_file),
        title: Text('Coda Music'),
        elevation: 10.0,
        actions: <Widget>[
          Icon(Icons.network_wifi),
          Icon(Icons.signal_cellular_4_bar),
          Icon(Icons.battery_charging_full),
          Icon(Icons.timer),
        ],
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Card(
              elevation: 9.0,
              child: Container(
                width: MediaQuery.of(context).size.height / 2.5,
                height: 250,
                child:
                    Image.network(myCurrentMusic.imagePath, fit: BoxFit.cover),
              ),
            ),
            textWithStyle(myCurrentMusic.title, 1.5),
            textWithStyle(myCurrentMusic.artist, 1.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                button(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                (status == PlayerState.playing)
                    ? button(Icons.pause, 45.0, ActionMusic.pause)
                    : button(Icons.play_arrow, 45.0, ActionMusic.play),
                button(Icons.fast_forward, 30.0, ActionMusic.forward),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                textWithStyle(fromDuration(position), 0.8),
                textWithStyle(fromDuration(duree), 0.8)
              ],
            ),
            Slider(
              value: position.inSeconds.toDouble(),
              min: 0,
              max: duree.inSeconds.toDouble(),
              inactiveColor: Colors.white,
              activeColor: Colors.amber,
              onChanged: (double d) {
                setState(() {
                  audioPlayer.seek(Duration(seconds: d.toInt()));
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  IconButton button(IconData icon, double size, ActionMusic action) {
    return IconButton(
        icon: Icon(icon),
        color: Colors.white,
        iconSize: size,
        onPressed: () {
          switch (action) {
            case ActionMusic.play:
              play();
              break;
            case ActionMusic.pause:
              pause();
              break;
            case ActionMusic.forward:
              forward();
              break;
            case ActionMusic.rewind:
              rewind();
              break;
          }
        });
  }

  Text textWithStyle(String data, double scale) {
    return Text(
      data,
      textScaleFactor: scale,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  void configurationAudioPlayer() {
    audioPlayer = AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged
        .listen((pos) => setState(() => position = pos));
    stateSub = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          audioPlayer.onDurationChanged.listen((Duration d) {
            setState(() => duree = d);
          });
        });
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          status = PlayerState.stopped;
        });
      }
    }, onError: (message) {
      print('erreur: $message');
      setState(() {
        status = PlayerState.stopped;
        duree = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(myCurrentMusic.urlSong, isLocal: true);
    setState(() {
      status = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      status = PlayerState.paused;
    });
  }

  void forward() {
    if (index == myMusicList.length - 1) {
      index = 0;
    } else {
      index++;
    }
    myCurrentMusic = myMusicList[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }

  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(Duration(seconds: 0));
    } else {
      if (index == 0) {
        index = myMusicList.length - 1;
      } else {
        index--;
      }
      myCurrentMusic = myMusicList[index];
      audioPlayer.stop();
      configurationAudioPlayer();
      play();
    }
  }

  String fromDuration(Duration duree) {
    return duree.toString().split('.').first;
  }
}

enum ActionMusic { play, pause, rewind, forward }

enum PlayerState { playing, stopped, paused }
