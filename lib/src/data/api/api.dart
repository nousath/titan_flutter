import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/model/update.dart';

class Api {
  Future<UpdateEntity> update(String channel, String lang) async {
    var data = await HttpCore.instance.getEntity(
        'api/v1/titan/app/update', EntityFactory<UpdateEntity>((json) => UpdateEntity.fromJson(json)),
        params: {'channel': channel, 'lang': lang});

    return data;
  }

  Future<Map<String, dynamic>> searchPoiByMapbox(String query, String proximity, String language,
      {String types = 'poi', int limit = 10}) async {
    var data = await HttpCore.instance.get('geocoding/v1/hyperion.places/$query.json',
        params: {'proximity': proximity, 'language': language, 'types': types, 'limit': limit});
    return data;
  }

  Future<Map<String, dynamic>> getReEncryptPubKey() async {
    var data = await HttpCore.instance.get('re/');
    return data;
  }

  Future<dynamic> storeCls(
      {@required String commitment, @required String ciphertext, @required int expiracy, @required String kid}) async {
    var data = await HttpCore.instance.post('re/cls', params: {
      'commitment': commitment,
      'ciphertext': ciphertext,
      'expiracy': expiracy,
      'kid': kid,
    });
    return data;
  }

  Future<Map<String, dynamic>> getCls(
      {@required String commitment, @required String pubkey, @required String kid}) async {
    var data = await HttpCore.instance.get('re/cls', params: {
      'commitment': commitment,
      'pubkey': pubkey,
      'kid': kid,
    });
    return data;
  }

  Future<dynamic> requestDianping(double lat, double lon) async {
    return HttpCore.instance.post('index/api/module',
        params: {
          'moduleInfoList[0][version]': 0,
          'moduleInfoList[0][moduleName]': 'cnxh',
          'moduleInfoList[0][config][bord]': true,
          'moduleInfoList[0][config][hideWelfare]': false,
          'moduleInfoList[0][config][adId]': 'm_dacu_banner',
          'moduleInfoList[0][config][categoryType]': 'standard',
          'moduleInfoList[0][config][mainwelfare_utm]': 'ulink_mainwelfare',
          'moduleInfoList[0][query][startNum]': 1,
          'moduleInfoList[0][lat]': lat,
          'moduleInfoList[0][lng]': lon,
          'originUrl': 'https://m.dianping.com/',
          'pageEnName': 'index',
        },
        options: RequestOptions(baseUrl: 'https://m.dianping.com/', headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Mobile Safari/537.36',
          'Referer': 'https://m.dianping.com/',
        }));
  }
}
