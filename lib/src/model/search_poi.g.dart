// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_poi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchPoiEntity _$SearchPoiEntityFromJson(Map<String, dynamic> json) {
  return SearchPoiEntity(
      name: json['name'] as String,
      address: json['address'] as String,
      tags: json['tags'] as String,
      loc: (json['loc'] as List)?.map((e) => (e as num)?.toDouble())?.toList(),
      phone: json['phone'] as String,
      remark: json['remark'] as String);
}

Map<String, dynamic> _$SearchPoiEntityToJson(SearchPoiEntity instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'tags': instance.tags,
      'loc': instance.loc,
      'phone': instance.phone,
      'remark': instance.remark
    };
