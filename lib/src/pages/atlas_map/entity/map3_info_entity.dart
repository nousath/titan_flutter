import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/utils/format_util.dart';

import 'atlas_info_entity.dart';
import 'enum_atlas_type.dart';
import 'map3_atlas_entity.dart';
import 'user_map3_entity.dart';

part 'map3_info_entity.g.dart';

@JsonSerializable()
class Map3InfoEntity extends Object {
  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'bls_key')
  String blsKey;

  @JsonKey(name: 'bls_sign')
  String blsSign;

  @JsonKey(name: 'atlas')
  AtlasInfoEntity atlas;

  @JsonKey(name: 'contact')
  String contact;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'creator')
  String creator;

  @JsonKey(name: 'describe')
  String describe;

  @JsonKey(name: 'end_block')
  int endBlock;

  @JsonKey(name: 'fee_rate')
  String feeRate;

  @JsonKey(name: 'home')
  String home;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'mod')
  int mod;

  @JsonKey(name: 'mine')
  UserMap3Entity mine;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'node_id')
  String nodeId;

  @JsonKey(name: 'parent_address')
  String parentAddress;

  @JsonKey(name: 'pic')
  String pic;

  @JsonKey(name: 'provider')
  String provider;

  @JsonKey(name: 'region')
  String region;

  @JsonKey(name: 'relative')
  Map3AtlasEntity relative;

  @JsonKey(name: 'reward_history')
  String rewardHistory;

  @JsonKey(name: 'reward_rate')
  String rewardRate;

  @JsonKey(name: 'staking')
  String staking;

  @JsonKey(name: 'total_pending_taking')
  String totalPendingStaking;

  @JsonKey(name: 'start_block')
  int startBlock;

  @JsonKey(name: 'start_epoch')
  int startEpoch;

  @JsonKey(name: 'end_epoch')
  int endEpoch;

  ///Map3InfoStatus
  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  @JsonKey(name: 'RateForNextPeriod')
  String rateForNextPeriod;

  @JsonKey(name: 'create_time')
  int createTime;

  @JsonKey(name: 'start_time')
  int startTime;

  @JsonKey(name: 'end_time')
  int endTime;

  @JsonKey(name: 'share_url')
  String shareUrl;

  Map3InfoEntity(
    this.address,
    this.blsKey,
    this.blsSign,
    this.atlas,
    this.contact,
    this.createdAt,
    this.creator,
    this.describe,
    this.endBlock,
    this.feeRate,
    this.home,
    this.id,
    this.mod,
    this.mine,
    this.name,
    this.nodeId,
    this.parentAddress,
    this.pic,
    this.provider,
    this.region,
    this.relative,
    this.rewardHistory,
    this.rewardRate,
    this.staking,
    this.totalPendingStaking,
    this.startBlock,
    this.status,
    this.updatedAt,
    this.startEpoch,
    this.endEpoch,
    this.rateForNextPeriod,
    this.createTime,
    this.startTime,
    this.endTime,
    this.shareUrl,
  );

  String getFeeRate() {
    return FormatUtil.weiToEtherStr(feeRate);
  }

  String getStaking() {
    return FormatUtil.weiToEtherStr(staking);
  }

  bool isCreator() {
    return mine?.creator == NodeJoinType.CREATOR.index;
  }

  get isJoiner => mine?.creator != NodeJoinType.CREATOR.index;

  Map3InfoEntity.onlyNodeId(this.nodeId);

  Map3InfoEntity.onlyId(this.id);

  Map3InfoEntity.onlyStaking(this.staking, this.totalPendingStaking);

  factory Map3InfoEntity.fromJson(Map<String, dynamic> srcJson) => _$Map3InfoEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Map3InfoEntityToJson(this);
}
