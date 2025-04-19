import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/coin.dart';
import '../services/coin_api_service.dart';

// Events
abstract class CoinEvent extends Equatable {
  const CoinEvent();

  @override
  List<Object> get props => [];
}

class FetchTrendingCoins extends CoinEvent {}

class FetchCoinDetails extends CoinEvent {
  final String coinId;

  const FetchCoinDetails(this.coinId);

  @override
  List<Object> get props => [coinId];
}

// States
abstract class CoinState extends Equatable {
  const CoinState();

  @override
  List<Object> get props => [];
}

class CoinInitial extends CoinState {}

class CoinLoading extends CoinState {}

class TrendingCoinsLoaded extends CoinState {
  final List<Coin> coins;

  const TrendingCoinsLoaded(this.coins);

  @override
  List<Object> get props => [coins];
}

class CoinDetailsLoaded extends CoinState {
  final Coin coin;

  const CoinDetailsLoaded(this.coin);

  @override
  List<Object> get props => [coin];
}

class CoinError extends CoinState {
  final String message;

  const CoinError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class CoinBloc extends Bloc<CoinEvent, CoinState> {
  final CoinApiService apiService;

  CoinBloc({required this.apiService}) : super(CoinInitial()) {
    on<FetchTrendingCoins>(_onFetchTrendingCoins);
    on<FetchCoinDetails>(_onFetchCoinDetails);
  }

  Future<void> _onFetchTrendingCoins(
    FetchTrendingCoins event,
    Emitter<CoinState> emit,
  ) async {
    emit(CoinLoading());
    try {
      final coins = await apiService.getTrendingCoins();
      emit(TrendingCoinsLoaded(coins));
    } catch (e) {
      emit(CoinError('Failed to fetch trending coins: ${e.toString()}'));
    }
  }

  Future<void> _onFetchCoinDetails(
    FetchCoinDetails event,
    Emitter<CoinState> emit,
  ) async {
    emit(CoinLoading());
    try {
      final coin = await apiService.getCoinDetails(event.coinId);
      emit(CoinDetailsLoaded(coin));
    } catch (e) {
      emit(CoinError('Failed to fetch coin details: ${e.toString()}'));
    }
  }
}
