import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webtoon/models/webtoon_episode_model.dart';
import 'package:flutter_webtoon/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/webtoon_detail_model.dart';
import '../widgets/episode_widget.dart';

class DetailScreen extends StatefulWidget {
  final String title, thumb, id;

  DetailScreen({super.key, required this.title, required this.thumb, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoon;
  late Future<List<WebtoonEpisodeModel>> episodes;
  late SharedPreferences prefs;
  bool isLiked = false;

  Future initPrefs() async{
    prefs = await SharedPreferences.getInstance();
    final likedToons = prefs.getStringList("linkedToons");

    if(likedToons!=null){
      if(likedToons.contains(widget.id) == true){
        setState(() {
          isLiked = true;
        });
      }
    }else{
      await prefs.setStringList('linkedToons', []);
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    webtoon = ApiService.getToonById(widget.id);
    episodes = ApiService.getLatestEpisodesById(widget.id);
    initPrefs();
  }

  onHeartTap() async {
    final likedToons = prefs.getStringList("linkedToons");

    if(likedToons!=null){
      if(isLiked){
        likedToons.remove(widget.id);
      }else{
        likedToons.add(widget.id);
      }
      await prefs.setStringList("linkedToons", likedToons);
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        actions: [
          IconButton(
              onPressed: onHeartTap,
              icon: Icon(isLiked ? Icons.favorite : Icons.favorite_outline),
          )
        ],
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Hero(
                  tag: widget.id,
                  child: Container(
                    width: 250,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 15,
                          offset: Offset(10, 10),
                          color: Colors.black.withOpacity(0.5),
                        )
                      ],
                    ),
                    child: Image.network(
                      widget.thumb,
                      headers: const {
                        'User-Agent':
                            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36',
                        'Referer': 'https://comic.naver.com',
                      },
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 25,),
              FutureBuilder(
                future: webtoon,
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(snapshot.data!.about,
                          style: TextStyle(
                            fontSize: 16
                          ),
                        ),
                        SizedBox(height: 15,),
                        Text("${snapshot.data!.genre} / ${snapshot.data!.age}",
                          style: TextStyle(
                              fontSize: 16
                          ),
                        ),

                      ],
                    );
                  }
                  return Text(",..");
                },
              ),
              SizedBox(height: 50,),
              FutureBuilder(
                future: episodes,
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    return Column(
                      children: [
                        for(var episode in snapshot.data!) Episode(episode: episode, webtoonId: widget.id)
                      ],
                    );
                  }
                  return Container();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

