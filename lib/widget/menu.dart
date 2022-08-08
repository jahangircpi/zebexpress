import 'package:democab/dataprovider/appdata.dart';
import 'package:democab/globalvariable.dart';
import 'package:democab/screens/profile.dart';
import 'package:democab/widget/promocode.dart';
import 'package:democab/screens/loginpage.dart';
import 'package:democab/styles/styles.dart';
import 'package:democab/widget/BrandDivider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            InkWell(
              onTap: () {
                print('__________presed');
                Navigator.pushNamedAndRemoveUntil(
                    context, ProfilePage.id, (route) => false);
              },
              child: Container(
                color: Colors.white,
                height: 160,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/user_icon.png',
                        width: 70,
                        height: 70,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (currentUserInfo != null)
                                ? currentUserInfo.fullname.toUpperCase().trim()
                                : 'fetching...',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 20, fontFamily: 'Brand-Bold'),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            BrandDivider(),
            SizedBox(
              height: 10,
            ),
            ListTile(
              leading: Icon(OMIcons.cardGiftcard),
              title: Text(
                'Promo Code',
                style: kDrawerItemStyle,
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PromoCode()));
              },
            ),
            ListTile(
              leading: Icon(OMIcons.contactSupport),
              title: Text(
                'Support',
                style: kDrawerItemStyle,
              ),
              onTap: () => {},
            ),
            ListTile(
              leading: Icon(OMIcons.info),
              title: Text(
                'About',
                style: kDrawerItemStyle,
              ),
              onTap: () => {},
            ),
            ListTile(
              leading: Icon(OMIcons.exitToApp),
              title: Text(
                'Logout',
                style: kDrawerItemStyle,
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Provider.of<AppData>(context, listen: false)
                    .updateMessageKeys([]);
                Provider.of<AppData>(context, listen: false).updateTripCount(0);
                Provider.of<AppData>(context, listen: false).updateWallet('0');
                Provider.of<AppData>(context, listen: false).clearTripHistory();
                Provider.of<AppData>(context, listen: false).clearMessage();
                List<String> tripHistoryKeys = [];
                Provider.of<AppData>(context, listen: false)
                    .updateTripKeys(tripHistoryKeys);
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginPage.id, (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
