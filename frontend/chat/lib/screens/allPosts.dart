import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:chat/screens/createPost.dart';
import 'package:chat/global.dart';

var dio = Dio();
List allPost = [];
ScrollController _scrollController = ScrollController();
int firstListPosts = 0;

class Posts extends StatefulWidget {
  final int id;

  Posts({Key key, @required this.id});

  @override
  PostsState createState() => PostsState();
}

class PostsState extends State<Posts> {
  getLastPosts() async {
    Response response = await dio.get('http://<localhost>/api/v1/post/');
    for (var i = 0; i < response.data.length; i++) {
      if (response.data[i]['id'] > allPost[allPost.length - 1]['id'])
        setState(() {
          allPost.add(response.data[i]);
        });
    }
  }

  updatePost(int id) async {
    Response response = await dio.get('http://<localhost>/api/v1/post/$id');
    setState(() {
      allPost.where((element) => element['id'] == id).first['content'] =
          response.data['content'];
      allPost.where((element) => element['id'] == id).first['image']['name'] =
          response.data['image']['name'];
      allPost.where((element) => element['id'] == id).first['image']['url'] =
          response.data['image']['url'];
      allPost.where((element) => element['id'] == id).first['image']['height'] =
          response.data['image']['height'];
      allPost.where((element) => element['id'] == id).first['image']['width'] =
          response.data['image']['width'];
    });
  }

  getAllPosts() async {
    Response response = await dio.get('http://<localhost>/api/v1/post/');
    for (var i = 0; i < response.data.length; i++) {
      setState(() {
        allPost.add(response.data[i]);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (firstListPosts == 0) {
      getAllPosts();
      firstListPosts++;
    }
    if (widget.id != null) {
      updatePost(widget.id);
    }
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getLastPosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(237, 238, 240, 1),
        appBar: AppBar(
          title: Text(
            "Publications",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => NewPost(id: null)),
                );
              },
              child: Icon(Icons.add, color: Color.fromRGBO(79, 182, 250, 1)),
            ),
            SizedBox(
              width: 10,
            )
          ],
        ),
        body: Center(
            child: ListView.builder(
                itemCount: allPost.length,
                controller: _scrollController,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(254, 255, 255, 1).withOpacity(0.9),
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 0,
                            blurRadius: 10.0,
                            offset: Offset(3, 8)),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        Color.fromRGBO(79, 182, 250, 1),
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundImage: AssetImage(
                                          'assets/image/profile.jpg'),
                                    )),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '@' + allPost[index]['user']['name'],
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(79, 182, 250, 1)),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(allPost[index]['date_created'])
                                  ],
                                ),
                              ],
                            ),
                            userId == allPost[index]['user']['id']
                                ? DropdownButton<String>(
                                    icon: Icon(Icons.more_horiz,
                                        color: Color.fromRGBO(79, 182, 250, 1)),
                                    iconSize: 24,
                                    elevation: 16,
                                    underline: Container(
                                      height: 0,
                                    ),
                                    onChanged: (String value) async {
                                      if (value == 'Delete') {
                                        Response response = await dio.delete(
                                            'http://<localhost>/api/v1/post/',
                                            data: {'id': allPost[index]['id']},
                                            options: Options(
                                                contentType:
                                                    'application/json'));
                                        print(response.statusCode);
                                        if (response.statusCode == 204) {
                                          setState(() {
                                            allPost.removeWhere((item) =>
                                                item['id'] ==
                                                allPost[index]['id']);
                                          });
                                        }
                                      } else {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => NewPost(
                                                  id: allPost[index]['id'])),
                                        );
                                      }
                                    },
                                    items: <String>['Delete', 'Update']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  )
                                : Container()
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Image.network(
                          'http://<localhost>' + allPost[index]['image']['url'],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Align(
                            child: Text(allPost[index]['content']),
                            alignment: Alignment.centerLeft),
                        Divider(
                          color: Color.fromRGBO(99, 99, 99, 1),
                          height: 10,
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                child: Icon(
                                  Icons.favorite_border,
                                  color: Color.fromRGBO(79, 182, 250, 1),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                })));
  }
}
