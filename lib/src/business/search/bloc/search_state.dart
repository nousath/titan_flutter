import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../store.dart';

@immutable
abstract class SearchState extends Equatable {
  SearchState([List props = const []]) : super(props);

  Map<String, dynamic> get store => getStoreOfGlobal('searchState');
}

class InitialSearchState extends SearchState {}

class SearchLoadedState extends SearchState {
  SearchLoadedState({
    @required items,
    @required currentSearchText,
    @required isHistory,
  }) : super([items, currentSearchText, isHistory]) {
    store['items'] = items;
    store['currentSearchText'] = currentSearchText;
    store['isHistory'] = isHistory;
  }

  List<dynamic> get items => store['items'];

  String get currentSearchText => store['currentSearchText'];

  bool get isHistory => store['isHistory'];

  @override
  String toString() {
    return '$runtimeType(isHistory: $isHistory, currentSearchText: $currentSearchText, items: $items)';
  }
}
