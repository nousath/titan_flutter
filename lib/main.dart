import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/domain/firebase.dart';

import 'env.dart';
import 'src/basic/bloc/app_bloc_delegate.dart';
import 'src/data/api/api.dart';
import 'src/data/db/search_history_dao.dart';
import 'src/data/repository/repository.dart';
import 'src/domain/domain.dart';
import 'src/inject/injector.dart';
import 'src/plugins/titan_plugin.dart';

void main() {
  if (env == null) {
    BuildEnvironment.init(channel: BuildChannel.OFFICIAL, buildType: BuildType.DEV);
  }

  TitanPlugin.initFlutterMethodCall();
  TitanPlugin.initKeyPair();

  Api api = Api();
  SearchHistoryDao searchDao = SearchHistoryDao();
  Repository repository = Repository(api: api, searchHistoryDao: searchDao);
  SearchInteractor searchInteractor = SearchInteractor(repository);

  BlocSupervisor.delegate = AppBlocDelegate();

  runApp(Injector(
    child: FireBaseLogic(
      child: App(),
    ),
    repository: repository,
    searchInteractor: searchInteractor,
  ));
//  FlutterBugly.postCatchedException(() {
//    //init dependency
//
//  });
}
