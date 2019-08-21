import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:titan/env.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/inject/injector.dart';
import './bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  @override
  AppState get initialState => InitialAppState();

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is CheckUpdate) {
      yield UpdateState(isChecking: true);
      try {
        var injector = Injector.of(Keys.materialAppKey.currentContext);
        var versionModel = await injector.repository.checkNewVersion(env.flavor, event.lang);

        yield UpdateState(isChecking: false, updateEntity: versionModel);
      } catch (err) {
        yield UpdateState(isError: true, isChecking: false);
      }
    }
  }
}
