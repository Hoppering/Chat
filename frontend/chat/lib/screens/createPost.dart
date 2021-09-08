import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:chat/screens/allPosts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';
import 'package:chat/global.dart';

class NewPost extends StatefulWidget {
  final int id;

  NewPost({Key key, @required this.id});

  @override
  NewPostState createState() => NewPostState();
}

class NewPostState extends State<NewPost> {
  var _image;
  double containerHeight = 600;
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      getDetailPost(widget.id);
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  getDetailPost(int id) async {
    Response response = await dio.get('http://<localhost>/api/v1/post/$id');
    setState(() {
      _image = 'http://<localhost>' + response.data['image']['url'];
      contentController.text = response.data['content'];
    });
  }

  Future<Response> sendForm(
      String url, String content, int id, File file) async {
    FormData formdata = FormData.fromMap({
      "content": content,
      "user": id,
      "image": await MultipartFile.fromFile(file.path,
          filename: basename(file.path)),
    });
    if (widget.id == null) {
      return await dio.post(url,
          data: formdata, options: Options(contentType: 'multipart/form-data'));
    }
    return await dio.put(url,
        data: formdata, options: Options(contentType: 'multipart/form-data'));
  }

  Future<Response> updateForm(
      String url, String content, int id, String file) async {
    FormData formdata = FormData.fromMap({
      "content": content,
      "user": id,
      "image": file,
    });

    return await dio.put(url,
        data: formdata, options: Options(contentType: 'multipart/form-data'));
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Warning"),
      content: Text("Your form is empty!"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  allForms() async {
    if (widget.id == null) {
      await sendForm('http://<localhost>/api/v1/post/', contentController.text,
          userId, _image);
    } else {
      if (_image is File) {
        await sendForm('http://<localhost>/api/v1/post/${widget.id}',
            contentController.text, userId, _image);
      } else {
        await updateForm('http://<localhost>/api/v1/post/${widget.id}',
            contentController.text, userId, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color.fromRGBO(237, 238, 240, 1),
        appBar: AppBar(
          leading: GestureDetector(
              child: Icon(Icons.arrow_back, color: Colors.black),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Posts(id: null)),
                );
              }),
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: Center(
            child: Container(
                height: containerHeight,
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    _image == null
                        ? GestureDetector(
                            onTap: () {
                              _showDialog(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(254, 255, 255, 1)
                                    .withOpacity(0.9),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                      spreadRadius: 0,
                                      blurRadius: 10.0,
                                      offset: Offset(3, 8)),
                                ],
                              ),
                              height: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Add image"),
                                  Icon(Icons.add,
                                      color: Color.fromRGBO(79, 182, 250, 1))
                                ],
                              ),
                            ),
                          )
                        : Stack(children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.4,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: _image is File
                                        ? FileImage(_image)
                                        : NetworkImage(_image)),
                              ),
                            ),
                            Positioned(
                                top: MediaQuery.of(context).size.width * 0.65,
                                left: MediaQuery.of(context).size.height * 0.37,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                        color:
                                            Color.fromRGBO(232, 232, 232, 1)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(40, 40, 40, 0.2),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: Offset(
                                            1, 0), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: GestureDetector(
                                    child: Icon(Icons.cancel),
                                    onTap: () {
                                      setState(() {
                                        _image = null;
                                      });
                                    },
                                  ),
                                )),
                          ]),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: 'Content'),
                      keyboardType: TextInputType.multiline,
                      maxLines: 6,
                      maxLength: 200,
                      controller: contentController,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (contentController.text.isEmpty || _image == null) {
                          showAlertDialog(context);
                        } else {
                          await allForms();
                          widget.id == null
                              ? Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Posts(id: null)),
                                )
                              : Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Posts(id: widget.id)),
                                );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(79, 182, 250, 1),
                            borderRadius: BorderRadius.circular(40)),
                        height: 50,
                        width: 250,
                        child: Center(
                            child: Text('Post',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600))),
                      ),
                    ),
                  ],
                ))));
  }

  Future getImageCamera(BuildContext context) async {
    final pickedFile = await ImagePicker.platform.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        maxHeight: 830,
        maxWidth: 814);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    Navigator.of(context).pop();
  }

  Future getImageGallery(BuildContext context) async {
    final pickedFile = await ImagePicker.platform.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxHeight: 830,
        maxWidth: 814);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    Navigator.of(context).pop();
  }

  Future<void> _showDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("What will you select?"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    GestureDetector(
                      child: Text(
                        "Take photo",
                        style: TextStyle(fontFamily: "mr_med"),
                      ),
                      onTap: () {
                        getImageCamera(context);
                      },
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      child: Text(
                        "From gallery",
                        style: TextStyle(fontFamily: "mr_med"),
                      ),
                      onTap: () {
                        getImageGallery(context);
                      },
                    ),
                  ],
                ),
              ));
        });
  }
}
