import 'package:democab/brand_colors.dart';
import 'package:democab/requests/requestmethods.dart';
import 'package:democab/tabs/historytab.dart';
import 'package:democab/tabs/personal.dart';
import 'package:democab/tabs/wallettab.dart';
import 'package:flutter/material.dart';

class MyMainHomePage extends StatefulWidget {
  static const String id = 'mainpage';

  @override
  _MyMainHomePageState createState() => _MyMainHomePageState();
}

class _MyMainHomePageState extends State<MyMainHomePage>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  int selecetdIndex = 0;

  void onItemClicked(int index) {
    setState(() {
      selecetdIndex = index;
      tabController.index = selecetdIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    RequestMethods.getCurrentUserInfo(context);
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // implement dispose
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: <Widget>[
          PersonalRidePage(),
          HistoryTab(),
          WalletTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            label: 'Wallet',
          ),
        ],
        currentIndex: selecetdIndex,
        unselectedItemColor: BrandColors.colorIcon,
        selectedItemColor: BrandColors.colorLightGray,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onItemClicked,
      ),
    );
  }
}
