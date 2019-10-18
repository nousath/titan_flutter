import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {
  @JsonKey(name: "id")
  String id;
  @JsonKey(name: "email")
  String email;
  @JsonKey(name: "parent_id")
  String parentId;
  @JsonKey(name: "balance")
  double balance;
  @JsonKey(name: "charge_balance")
  double chargeBalance;
  @JsonKey(name: "total_power")
  int totalPower;
  @JsonKey(name: "mortgage_nodes")
  int mortgageNodes;
  @JsonKey(name: "highest_power")
  int highestPower;
  @JsonKey(name: "second_highest_power")
  int secondHighestPower;
  @JsonKey(name: "low_power")
  int lowPower;
  @JsonKey(name: "total_invitations")
  int totalInvitations;
  @JsonKey(name: "level")
  String level;

  UserInfo(this.id, this.email, this.parentId, this.balance, this.chargeBalance, this.totalPower, this.mortgageNodes,
      this.highestPower, this.secondHighestPower, this.lowPower, this.totalInvitations, this.level);

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
