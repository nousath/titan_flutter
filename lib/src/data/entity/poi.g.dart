// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PoiEntity _$PoiEntityFromJson(Map<String, dynamic> json) {
  return PoiEntity(
    name: json['name'] as String,
    address: json['address'] as String,
    tags: json['tags'] as String,
    latLng: LatLngConverter.latLngFromJson(json['latLng']),
    phone: json['phone'] as String,
    remark: json['remark'] as String,
  );
}

Map<String, dynamic> _$PoiEntityToJson(PoiEntity instance) => <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'tags': instance.tags,
      'latLng': LatLngConverter.latLngToJson(instance.latLng),
      'phone': instance.phone,
      'remark': instance.remark,
    };