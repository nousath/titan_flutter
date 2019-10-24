import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/infomation/api/news_api.dart';
import 'package:titan/src/business/infomation/model/focus_response.dart' as focus;
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart' as map;
import '../dmap_define.dart';
import './bloc.dart';

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final BuildContext context;

  NewsApi _newsApi = NewsApi();

  DiscoverBloc(this.context);

  @override
  DiscoverState get initialState => InitialDiscoverState();

  @override
  Stream<DiscoverState> mapEventToState(DiscoverEvent event) async* {
    if (event is InitDiscoverEvent) {
      yield InitialDiscoverState();

      BlocProvider.of<map.ScaffoldMapBloc>(context).add(map.InitMapEvent());
    } else if (event is ActiveDMapEvent) {
      DMapCreationModel model = DMapDefine.kMapList[event.name];
      if (model != null) {
        yield ActiveDMapState(name: event.name);

        DMapCreationModel model = DMapDefine.kMapList[event.name];
        BlocProvider.of<map.ScaffoldMapBloc>(context).add(map.InitDMapEvent(
          dMapConfigModel: model.dMapConfigModel,
        ));
      }
    } else if (event is LoadFocusImageEvent) {
      List<focus.FocusImage> focusList = await _newsApi.getFocusList();
      yield (LoadedFocusState(focusImages: focusList));
    }
  }
}
