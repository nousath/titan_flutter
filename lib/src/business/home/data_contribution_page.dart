import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/home/contribution_page.dart';
import 'package:titan/src/business/wallet/service/wallet_service.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/utils/utils.dart';
import '../wallet/wallet_create_new_account_page.dart';
import 'package:titan/src/business/wallet/wallet_import_account_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_event.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_state.dart';
import 'package:titan/src/global.dart';
import '../wallet/wallet_manager/wallet_manager.dart';

class DataContributionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DataContributionState();
  }
}

class _DataContributionState extends State<DataContributionPage> with RouteAware {
  WalletBloc _walletBloc = WalletBloc();

  StreamSubscription _eventbusSubcription;
  WalletService _walletService = WalletService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    print("didPopNext");
    doDidPopNext();
  }

  Future doDidPopNext() async {
    if (currentWalletVo != null) {
      String defaultWalletFileName = await _walletService.getDefaultWalletFileName();
      logger.i("defaultWalletFileName:$defaultWalletFileName");
      String updateWalletFileName = currentWalletVo.wallet.keystore.fileName;
      logger.i("updateWalletFileName:$updateWalletFileName");
      if (defaultWalletFileName == updateWalletFileName) {
        logger.i("do UpdateWalletEvent");
        _walletBloc.add(UpdateWalletEvent(currentWalletVo));
      } else {
        currentWalletVo = null;
        logger.i("do ScanWalletEvent");
        _walletBloc.add(ScanWalletEvent());
      }
    } else {
      _walletBloc.add(ScanWalletEvent());
    }
  }

  @override
  void dispose() {
    _eventbusSubcription?.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    _walletBloc.add(ScanWalletEvent());

    _eventbusSubcription = eventBus.on().listen((event) {
      if (event is ScanWalletEvent) {
        _walletBloc.add(ScanWalletEvent());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          S.of(context).data_contribute,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      bloc: _walletBloc,
      builder: (BuildContext context, WalletState state) {
        if (state is WalletEmptyState) {
          return _walletTipsView();
//          return _listView();
        } else if (state is ShowWalletState) {
          currentWalletVo = state.wallet;
//          return _walletTipsView();
          return _listView();
        } else if (state is ScanWalletLoadingState) {
          return _buildLoading(context);
        } else {
          return Container(
            width: 0.0,
            height: 0.0,
          );
        }
      },
    );
  }

  Widget _buildLoading(context) {
    return Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _walletTipsView() {
    return Center(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 39, 0, 26),
              child: Image.asset(
                'res/drawable/data_contribution_wallet_check.png',
                width: 110,
                height: 108,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 34),
              width: 194,
              child: Text(
                S.of(context).data_contrebution_with_hyn_wallet_tips,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: HexColor('#333333'),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: SizedBox(
//                height: 38,
//                width: 152,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(38)),
                  onPressed: () {
                    createWalletPopUtilName = '/data_contribution_page';
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                      child: Text(
                        S.of(context).create_wallet,
                        style:
                            TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: SizedBox(
//                height: 38,
//                width: 152,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(38)),
                  onPressed: () {
                    createWalletPopUtilName = '/data_contribution_page';
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ImportAccountPage()));
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                      child: Text(
                        S.of(context).import_wallet,
                        style:
                            TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listView() {
    return ListView(
      children: <Widget>[
        Container(
          height: 8,
          color: Colors.grey[200],
        ),
        _wallet(),
        Container(
          height: 8,
          color: Colors.grey[200],
        ),
        _buildItem('signal', S.of(context).scan_signal_item_title, () async {
          bool status = await checkSignalPermission();
          print('[Permission] -->status:$status');

          if (status) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContributionPage(),
              ),
            );
          }
        }, isOpen: true),
        _divider(),
        _buildItem('position', S.of(context).add_poi_item_title, () {}),
        _divider(),
        _buildItem('check', S.of(context).check_poi_item_title, () {}),
        _divider(),
      ],
    );
  }

  Widget _wallet() {
    if (currentWalletVo == null) {
      return Container();
    }
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WalletManagerPage(), settings: RouteSettings(name: "/wallet_manager_page")));
      },
      child: SizedBox(
        height: 64,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(15, 4, 10, 0),
                child: Image.asset(
                  'res/drawable/data_contribution_wallet.png',
                  width: 40,
                  height: 40,
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  currentWalletVo.wallet.keystore.name ?? "",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.w500, color: HexColor('#333333')),
                ),
                SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    shortEthAddress(currentWalletVo.wallet.getEthAccount().address) ?? "",
                    style: TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF9B9B9B), fontSize: 12),
                  ),
                )
              ],
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                S.of(context).switch_contribute_address,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: HexColor('#333333'),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String iconName, String title, Function ontap, {bool isOpen = false}) {
    return InkWell(
      onTap: ontap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(15, 12, 12, 12),
              child: Image.asset(
                'res/drawable/data_contribution_$iconName.png',
                width: 22,
                height: 22,
              )),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: HexColor('#333333')),
          ),
          Spacer(),
          _end(isOpen: isOpen),
        ],
      ),
    );
  }

  Widget _end({bool isOpen = false}) {
    if (isOpen) {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Icon(
          Icons.chevron_right,
          color: HexColor('#E9E9E9'),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Text(
          S.of(context).coming_soon,
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: HexColor('#AAAAAA')),
        ),
      );
    }
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 8,
        color: HexColor('#E9E9E9'),
      ),
    );
  }

  Future<bool> checkSignalPermission() async {
    //1、检查定位的权限

    //check location service

    ServiceStatus serviceStatus = await PermissionHandler().checkServiceStatus(PermissionGroup.location);

    if (serviceStatus == ServiceStatus.disabled) {
      _showGoToOpenLocationServceDialog();
      return false;
    }

    PermissionStatus locationPermission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
    if (locationPermission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler().requestPermissions([PermissionGroup.location]);
      if (permissions[PermissionGroup.location] != PermissionStatus.granted) {
        _showGoToOpenAppSettingsDialog();
        return false;
      }
    }

    //2. 检查电话权限

    if (Platform.isAndroid) {
      PermissionStatus phonePermission = await PermissionHandler().checkPermissionStatus(PermissionGroup.phone);
      if (phonePermission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler().requestPermissions([PermissionGroup.phone]);
        if (permissions[PermissionGroup.phone] != PermissionStatus.granted) {
          _showGoToOpenCommonAppSettingsDialog(
              S.of(context).require_permission, S.of(context).collect_signal_require_telephone, () {
            PermissionHandler().openAppSettings();
          });
          return false;
        }
      }
    }

    //3. 检查蓝牙权限

    bool blueAvaiable = await TitanPlugin.bluetoothEnable();
    if (Platform.isAndroid) {
      if (!blueAvaiable) {
        _showGoToOpenCommonAppSettingsDialog(S.of(context).open_bluetooth, S.of(context).please_open_bluetooth, () {
          AppSettings.openBluetoothSettings();
        });
        return false;
      }
    }
    else {
      if (!blueAvaiable) {
        return false;
      }
    }

    //4. 安卓增加判断wifi
    if (Platform.isAndroid) {
      bool wifiAvaiable = await TitanPlugin.wifiEnable();
      if (!wifiAvaiable) {
        _showGoToOpenCommonAppSettingsDialog(S.of(context).open_wifi, S.of(context).please_open_wifi, () {
          AppSettings.openWIFISettings();
        });
        return false;
      }
    }

    return true;
  }

  void _showGoToOpenCommonAppSettingsDialog(String title, String message, Function goToSetting) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(S.of(context).cancel),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text(S.of(context).setting),
                      onPressed: () {
                        goToSetting();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(S.of(context).cancel),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text(S.of(context).setting),
                      onPressed: () {
                        goToSetting();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
        });
  }

  void _showGoToOpenAppSettingsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text(S.of(context).require_location),
                  content: Text(S.of(context).require_location_message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(S.of(context).cancel),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text(S.of(context).setting),
                      onPressed: () {
                        PermissionHandler().openAppSettings();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text(S.of(context).require_location),
                  content: Text(S.of(context).require_location_message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(S.of(context).cancel),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text(S.of(context).setting),
                      onPressed: () {
                        PermissionHandler().openAppSettings();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
        });
  }

  void _showGoToOpenLocationServceDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text(S.of(context).open_location_service),
                  content: Text(S.of(context).open_location_service_message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(S.of(context).cancel, style: TextStyle(color: Colors.blue),),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text(S.of(context).setting, style: TextStyle(color: Colors.blue),),
                      onPressed: () {
                        PermissionHandler().openAppSettings();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text(S.of(context).open_location_service),
                  content: Text(S.of(context).open_location_service_message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(S.of(context).cancel),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text(S.of(context).setting),
                      onPressed: () {
                        AndroidIntent intent = new AndroidIntent(
                          action: 'action_location_source_settings',
                        );
                        intent.launch();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
        });
  }
}
