import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:get/get.dart';
import 'package:umusicv2/Classes/PlayInfo.dart';
import 'package:umusicv2/Engine/MusicEngine.dart';
import 'package:umusicv2/Engine/PlayerEngine.dart';
import 'package:umusicv2/ModernUi/LyricUi.dart';
import 'package:umusicv2/ModernUi/PlayUi.dart';
import 'package:umusicv2/ModernUi/SongsListUI.dart';
import 'package:umusicv2/ServiceModules/AudioEngine.dart';


class MainHome extends StatefulWidget {
  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {


  void getImage(String songID) async{
    Future frp = audioQuery.getArtwork(
        type: ResourceType.SONG, id: songID
    );
  }

  void stateSetter(){
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    sEngine.getSongs().then((value) => stateSetter());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx((){
            return FutureBuilder(
              future: audioQuery.getArtwork(
                type: ResourceType.SONG,
                id: currentSong.value.id,
              ),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.done) {
                  if (snap.data.toString() == '[]'){
                    return ClipRRect(
                      child: Container(
                        height: Get.height,
                        width: Get.width,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Container(
                              height: Get.height,
                              width: Get.width,
                              child: Image.memory(snap.data, fit: BoxFit.cover),
                            ),
                            Container(
                              height: Get.height,
                              width: Get.width,
                              color: Colors.grey.shade800.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return ClipRRect(
                      child: Container(
                        height: Get.height,
                        width: Get.width,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Container(
                              height: Get.height,
                              width: Get.width,
                              child: Image.memory(snap.data, fit: BoxFit.cover),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          }),
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10,
                sigmaY: 10
            ),
              child: Column(
                children: [
                  Container(
                      height: Get.height-190,
                      child: PageView(
                        children: [
                          SongsListUi(pE: pEngine),
                          PlayUi(),
                          LyricsUI(),
                        ],
                      )
                  ),
                  Obx((){
                    return Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.black54.withOpacity(0.75),
                      height: 190,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                  child: Text(currentSong.value.title, maxLines: 1,),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(Duration(milliseconds: songPosition.value).toString().split('.')[0]),
                              Text(' | '),
                              Text(Duration(milliseconds: currentSong.value.length).toString().split('.')[0])
                            ],
                          ),
                          Slider(
                            value: songPosition.value.toDouble() > currentSong.value.length.toDouble() ? 0: songPosition.value.toDouble(),
                            min: 0,
                            max: currentSong.value.length.toDouble(),
                            onChanged: (value){
                              songPosition.value = value.toInt();
                              pEngine.seek(value.milliseconds);
                            },
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: 32,
                                width: 64,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2048)
                                  ),
                                  child: Icon(Icons.skip_previous_rounded),
                                  onPressed: (){
                                    pEngine.back();
                                  },
                                ),
                              ),
                              Container(
                                height: 72,
                                width: 72,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2048)
                                  ),
                                  child: isPlaying.value ? Icon(Icons.pause) : Icon(Icons.play_arrow_rounded),
                                  onPressed: (){
                                    pEngine.pause();
                                  },
                                ),
                              ),
                              Container(
                                height: 32,
                                width: 72,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2048)
                                  ),
                                  child: Icon(Icons.skip_next_rounded),
                                  onPressed: (){
                                    pEngine.next();
                                  },
                                ),
                              )
                            ],
                          )

                        ],
                      ),
                    );
                  })
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}
