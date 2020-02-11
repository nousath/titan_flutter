import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'symbol_quote_vo.g.dart';

@JsonSerializable()
class SymbolQuoteVo extends Equatable {
  ///ETH, HYN etc..
  final String symbol;

  ///USD, CNY etc..
  final String quote;

  ///the symbol base quote price
  final double price;

  SymbolQuoteVo({this.symbol, this.quote, this.price});

  factory SymbolQuoteVo.fromJson(Map<String, dynamic> json) => _$SymbolQuoteVoFromJson(json);

  Map<String, dynamic> toJson() => _$SymbolQuoteVoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  List<Object> get props => [symbol, quote, price];
}