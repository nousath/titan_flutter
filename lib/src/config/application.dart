import 'package:event_bus/event_bus.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class Application {
  //-----------------
  // route
  //-----------------
  static Router router;
  static RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  /// The global [EventBus] object.
  static EventBus eventBus = EventBus();

  //-----------------
  //app global vars
  //-----------------
  //default set to guangzhou tower center
  static LatLng recentlyLocation = LatLng(23.10901, 113.31799);
}
