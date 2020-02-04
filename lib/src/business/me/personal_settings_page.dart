import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/login/login_bus_event.dart';
import 'package:titan/src/business/login/reset_fund_password_page.dart';
import 'package:titan/src/business/login/reset_password_page.dart';
import 'package:titan/src/business/me/user_info_state.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/consts/extends_icon_font.dart';

class PersonalSettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PersonalSettingsState();
  }
}

class _PersonalSettingsState extends UserState<PersonalSettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
//        backgroundColor: Colors.white,
        title: Text(
          S.of(context).personal_information,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Image.asset(
                    "res/drawable/email_icon.png",
                    width: 36,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      S.of(context).email_label,
                      style: TextStyle(color: Color(0xFF333333), fontSize: 16),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      LOGIN_USER_INFO?.email??'',
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                _buildMemuBar(S.of(context).modify_account_password, ExtendsIconFont.lock, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ResetPasswordPage(email: LOGIN_USER_INFO.email)));
                }),
                Divider(),
                _buildMemuBar(S.of(context).modify_fund_password, ExtendsIconFont.lock, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ResetFundPasswordPage(email: LOGIN_USER_INFO.email)));
                }),
              ],
            ),
          ),
//          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: RaisedButton(
              elevation: 1,
              color: Color(0xFFBCC1C7),
              onPressed: () {
                eventBus.fire(ReloginBusEvent());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                child: SizedBox(
                    height: 40,
                    width: 192,
                    child: Center(
                        child: Text(
                      S.of(context).login_out,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemuBar(String title, IconData iconData, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  child: Text(
                    title,
                    style: TextStyle(color: Color(0xFF333333), fontSize: 15),
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: Colors.black54,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
