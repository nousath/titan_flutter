import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/wallet/forgot_wallet_password_page.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:vibration/vibration.dart';

typedef Future<bool> CheckPwdValid(String pwd);

class WalletPasswordDialog extends StatefulWidget {
  final String title;
  final CheckPwdValid checkPwdValid;

  WalletPasswordDialog({this.title, this.checkPwdValid});

  @override
  BaseState<StatefulWidget> createState() {
    return _WalletPasswordDialogState();
  }
}

class _WalletPasswordDialogState extends BaseState<WalletPasswordDialog> {
  Wallet wallet;
  final TextEditingController _pinPutController = TextEditingController();
  bool _pwdInvalid = false;

  void initState() {
    super.initState();
    // TODO: implement initState
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
    wallet = WalletInheritedModel.of(context).activatedWallet.wallet;
  }

  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 32.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        margin: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 8.0,
                              ),
                              child: PinInputTextField(
                                enabled: true,
                                pinLength: 6,
                                decoration: _pwdInvalid
                                    ? BoxTightDecoration(
                                        strokeColor: Colors.red,
                                        obscureStyle: ObscureStyle(
                                          isTextObscure: true,
                                          obscureText: '●',
                                        ),
                                      )
                                    : BoxTightDecoration(
                                        strokeColor: Colors.grey,
                                        obscureStyle: ObscureStyle(
                                          isTextObscure: true,
                                          obscureText: '●',
                                        ),
                                      ),
                                controller: _pinPutController,
                                autoFocus: true,
                                textInputAction: TextInputAction.done,
                                onChanged: (pin) async {
                                  if (pin.length == 6) {
                                    var result =
                                        await widget.checkPwdValid(pin);
                                    if (result) {
                                      Navigator.of(context).pop(pin);
                                    } else {
                                      setState(() {
                                        setState(() {
                                          _pwdInvalid = true;
                                        });
                                        _pinPutController.clear();
                                      });
                                      if (await Vibration.hasVibrator()) {
                                        Vibration.vibrate();
                                      }
                                    }
                                  } else {
                                    setState(() {
                                      _pwdInvalid = false;
                                    });
                                  }
                                },
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                if (_pwdInvalid)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      '您的密码有误',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                Spacer(),
                                InkWell(
                                  child: Text(
                                    '忘记密码',
                                    style:
                                        TextStyle(color: HexColor('#FF1F81FF')),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ForgotWalletPasswordPage(),
                                        ));
                                  },
                                ),
                                SizedBox(
                                  width: 8.0,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 16.0,
                            ),
                            Center(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'res/drawable/ic_wallet.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    wallet.keystore.name,
                                    style: TextStyle(
                                      color: HexColor('#FF999999'),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                            'res/drawable/ic_dialog_close.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
