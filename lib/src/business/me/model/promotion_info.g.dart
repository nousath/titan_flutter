// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromotionInfo _$PromotionInfoFromJson(Map<String, dynamic> json) {
  return PromotionInfo(
    json['email'] as String,
    json['total'] as int,
    json['highest'] as int,
    json['second_highest'] as int,
    json['low'] as int,
  );
}

Map<String, dynamic> _$PromotionInfoToJson(PromotionInfo instance) =>
    <String, dynamic>{
      'email': instance.email,
      'total': instance.total,
      'highest': instance.highest,
      'second_highest': instance.secondHighest,
      'low': instance.low,
    };
