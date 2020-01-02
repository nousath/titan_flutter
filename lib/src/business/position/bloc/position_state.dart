import 'package:equatable/equatable.dart';
import 'package:titan/src/business/position/model/category_item.dart';

abstract class PositionState {
  const PositionState();
}

class InitialPositionState extends PositionState {
  @override
  List<Object> get props => [];
}

class AddPositionState extends PositionState {
  AddPositionState();
}

class SelectCategoryLoadingState extends PositionState {
  SelectCategoryLoadingState();
}

class SelectCategoryResultState extends PositionState {
  List<CategoryItem> categoryList;
  SelectCategoryResultState({this.categoryList});
}