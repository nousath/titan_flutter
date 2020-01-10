import 'package:json_annotation/json_annotation.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/model/converter/model_converter.dart';
import 'package:titan/src/model/poi_interface.dart';

part 'confirm_poi_item.g.dart';


@JsonSerializable()
class ConfirmPoiItem extends Object implements IPoi{

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'category')
  String category;

  @JsonKey(name: 'location')
  Location location;

  @JsonKey(name: 'ext')
  String ext;

  @JsonKey(name: 'state')
  int state;

  @JsonKey(name: 'phone')
  String phone;

  @JsonKey(name: 'work_time')
  String workTime;

  @JsonKey(name: 'images')
  List<String> images;

  @JsonKey(name: 'postcode')
  String postcode;

  @JsonKey(name: 'website')
  String website;

  ConfirmPoiItem(this.id,this.name,this.address,this.category,this.location,this.ext,this.state,this.phone,this.workTime,this.images,this.postcode,this.website,);

  factory ConfirmPoiItem.fromJson(Map<String, dynamic> srcJson) => _$ConfirmPoiItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ConfirmPoiItemToJson(this);

  @override
  String remark;

  @override
  @JsonKey(fromJson: LatLngConverter.latLngFromJson, toJson: LatLngConverter.latLngToJson)
  LatLng latLng;

  ConfirmPoiItem.setPid(this.id);

}


@JsonSerializable()
class Location extends Object {

  @JsonKey(name: 'coordinates')
  List<double> coordinates;

  @JsonKey(name: 'type')
  String type;

  Location(this.coordinates,this.type,);

  factory Location.fromJson(Map<String, dynamic> srcJson) => _$LocationFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LocationToJson(this);

}

