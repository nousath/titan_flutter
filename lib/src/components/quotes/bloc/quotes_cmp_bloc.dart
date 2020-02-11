import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:titan/src/global.dart';
import '../coin_market_api.dart';
import '../model.dart';
import './bloc.dart';

class QuotesCmpBloc extends Bloc<QuotesCmpEvent, QuotesCmpState> {
  CoinMarketApi _coinMarketApi;

  static const DEFAULT_SYMBOLS = ['ETH', 'HYN'];

  static const UPDATE_THRESHOLD = 5 * 60 * 1000; //5 minute
  QuotesModel currentQuotesModel;

  @override
  QuotesCmpState get initialState => InitialQuotesCmpState();

  @override
  Stream<QuotesCmpState> mapEventToState(QuotesCmpEvent event) async* {
    if (event is UpdateQuotesEvent) {
      if (currentQuotesModel == null ||
          DateTime.now().millisecondsSinceEpoch - currentQuotesModel.lastUpdateTime > UPDATE_THRESHOLD) {
        yield UpdatingQuotesState();

        try {
          var symbols = DEFAULT_SYMBOLS;
          final symbolString = symbols.reduce((value, element) => value + ',' + element);

          var converts = SupportedQuotes.all.map((sign) => sign.quote).toList();
          var quotes = await _coinMarketApi.quotes(DEFAULT_SYMBOLS, converts);
          currentQuotesModel = QuotesModel(
              quotes: quotes, symbolStr: symbolString, lastUpdateTime: DateTime.now().millisecondsSinceEpoch);

          yield UpdatedQuotesState(quoteModel: currentQuotesModel);
        } catch (e) {
          logger.e(e);

          yield UpdateQuotesFailState();
        }
      }
    } else if (event is UpdateQuotesSignEvent) {
      yield UpdatedQuotesSignState(sign: event.sign);
    }
  }
}