import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/bloc/bloc.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/components/setting/setting_component.dart';

class MeLanguagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanguageState();
  }
}

class _LanguageState extends BaseState<MeLanguagePage> {
  LanguageModel selectedLanguageModel;

//  var isComplete = false;

  @override
  void onCreated() {
    selectedLanguageModel = SettingInheritedModel.of(context, aspect: SettingAspect.language).languageModel;
  }

//  @override
//  void deactivate() {
//    if(isComplete) {
//      var currentAreaModel = SettingInheritedModel
//          .of(context, aspect: SettingAspect.area)
//          .areaModel;
//
//      for (AreaModel areaModel in SupportedArea.all(context)) {
//        if (currentAreaModel.id == areaModel.id) {
//          BlocProvider.of<SettingBloc>(context).add(
//              UpdateAreaEvent(areaModel: areaModel));
//        }
//      }
//    }
//
//    super.deactivate();
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            S.of(context).language,
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          elevation: 0,
          actions: <Widget>[
            InkWell(
              onTap: () {
                BlocProvider.of<SettingBloc>(context).add(UpdateSettingEvent(languageModel: selectedLanguageModel));
//                isComplete = true;
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                alignment: Alignment.centerRight,
                child: Text(
                  S.of(context).confirm,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
        body: ListView(children: _buildLanguageList()));
  }

  List<Widget> _buildLanguageList() {
    return SupportedLanguage.all.map<Widget>((language) {
      return _buildInfoContainer(language);
    }).toList();
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1.0,
        color: HexColor('#D7D7D7'),
      ),
    );
  }

  Widget _buildInfoContainer(LanguageModel languageModel) {

    var _visible = false;
    if (selectedLanguageModel.locale.languageCode == 'zh') {
      _visible = (selectedLanguageModel.locale.countryCode == languageModel.locale.countryCode);
      //print('[language] --> countryCode:${locale.countryCode}, selectedLocale.countryCode:${selectedLocale.countryCode}');
    } else {
      _visible = (selectedLanguageModel.locale.languageCode == languageModel.locale.languageCode);
      //print('[language] --> language:${locale.languageCode}, selectedLocale.languageCode:${selectedLocale.languageCode}');
    }
    
    return InkWell(
      onTap: () {
        print("$selectedLanguageModel  $languageModel");
        setState(() {
          selectedLanguageModel = languageModel;
        });
      },
      child: Column(
        children: <Widget>[
          Container(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 15, 15, 13),
                  child: Text(
                    languageModel.name,
                    style: TextStyle(color: HexColor("#333333"), fontSize: 16),
                  ),
                ),
                Spacer(),
                Visibility(
                  visible: _visible,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 15, 15, 13),
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                  ),
                )
              ],
            ),
          ),
          _divider()
        ],
      ),
    );
  }
}
