import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/model/update.dart';

class Api {
  Future<UpdateEntity> update(String channel, String lang) async {
    var data = await HttpCore.instance.getEntity('api/v1/titan/app/update', EntityFactory<UpdateEntity>((json) => UpdateEntity.fromJson(json)),
        params: {'channel': channel, 'lang': lang});

    return data;
  }

  Future<Map<String, dynamic>> searchPoiByMapbox(String query, String proximity, String language, {String types = 'poi', int limit = 10}) async {
    var data = await HttpCore.instance.get('geocoding/v1/hyperion.places/$query.json',
        params: {'proximity': proximity, 'language': language, 'types': types, 'limit': limit});
    return data;
  }
}
