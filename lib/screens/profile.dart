import 'dart:io';

import 'package:democab/brand_colors.dart';
import 'package:democab/globalvariable.dart';
import 'package:democab/requests/requestmethods.dart';
import 'package:democab/screens/home.dart';
import 'package:democab/widget/TaxiButton.dart';
import 'package:democab/widget/progressDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  static const String id = 'profile';
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  File _image;
  final picker = ImagePicker();

  var phoneCtrl = TextEditingController();
  var emailCtrl = TextEditingController();
  var nameCtrl = TextEditingController();

  Future choiceImage() async {
    var pickedImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = (pickedImage != null) ? File(pickedImage.path) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    phoneCtrl.text = currentUserInfo.phone;
    emailCtrl.text = currentUserInfo.email;
    nameCtrl.text = currentUserInfo.fullname;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontFamily: 'Brand-Bold'),
        ),
        backgroundColor: BrandColors.colorTextDark,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, MyMainHomePage.id, (route) => false);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: BrandColors.colorDimText,
                  ),
                  SizedBox(
                    width: 18,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: BrandColors.colorLightGrayFair,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: TextField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            hintText: 'Full name',
                            fillColor: BrandColors.colorLightGrayFair,
                            filled: true,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                EdgeInsets.only(left: 10, top: 8, bottom: 8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(
                    Icons.email,
                    color: BrandColors.colorDimText,
                  ),
                  SizedBox(
                    width: 18,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: BrandColors.colorLightGrayFair,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: emailCtrl,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            fillColor: BrandColors.colorLightGrayFair,
                            filled: true,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                EdgeInsets.only(left: 10, top: 8, bottom: 8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: BrandColors.colorDimText,
                  ),
                  SizedBox(
                    width: 18,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: BrandColors.colorLightGrayFair,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Phone number',
                            fillColor: BrandColors.colorLightGrayFair,
                            filled: true,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                EdgeInsets.only(left: 10, top: 8, bottom: 8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.camera),
                    onPressed: () {
                      choiceImage();
                    },
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Container(
                    height: 60,
                    width: 60,
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
                      ],
                    ),
                    child: Center(
                      child: (_image != null)
                          ? Image.file(_image)
                          : Text('No image'),
                    ),
                  ),
                ],
              ),
              /*
              SizedBox(
                height: 10,
              ),
              Container(
                  child: CircleAvatar(
                child: (_image != null) ? Image.file(_image) : Text('No image'),
              )),*/
              SizedBox(
                height: 20,
              ),
              TaxiButton(
                title: 'Update',
                height: 40,
                color: BrandColors.colorTextDark,
                onPressed: () {
                  //print('updated');
                  if (phoneCtrl.text.length != 11) {
                    showSnackBar('Enter a valid phone number');
                    return;
                  }
                  if (nameCtrl.text.length < 3) {
                    showSnackBar('Name should be at least 5 characters');
                    return;
                  }
                  if (!emailCtrl.text.contains('@')) {
                    showSnackBar('Enter a valid email');
                    return;
                  }
                  updateUserinfo();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void updateUserinfo() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Updating...',
      ),
    );
    Map<String, String> userMap = {
      'fullname': nameCtrl.text,
      'email': emailCtrl.text,
      'phone': phoneCtrl.text,
      // 'wallet': '${currentUserInfo.wallet}',
    };
    currentFirebaseUser = await FirebaseAuth.instance.currentUser();
    currentFirebaseUser.updateEmail(emailCtrl.text);
    String userID = currentFirebaseUser.uid;

    DatabaseReference userRef =
        FirebaseDatabase.instance.reference().child('users/$userID');
    userRef.update(userMap);
    if (_image != null) {
      await uploadImage();
    }
    RequestMethods.getCurrentUserInfo(context);
    Navigator.pop(context);
    showSnackBar('Updated successfully');
  }

  Future uploadImage() async {
    final uri = Uri.parse('$baseUrl/posticon');
    var request = http.MultipartRequest('POST', uri);
    request.fields['name'] = '${currentFirebaseUser.uid}';
    request.fields['type'] = 'users';
    var pic = await http.MultipartFile.fromPath("image", _image.path);
    request.files.add(pic);
    print(pic.filename);
    var response = await request.send();
    if (response.statusCode == 200) {
      print('Image Uploaded');
    } else {
      print('Image not Uploaded');
    }
  }
}
