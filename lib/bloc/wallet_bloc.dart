import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/wallet_service.dart';

// Events
abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

class ConnectWallet extends WalletEvent {}

class DisconnectWallet extends WalletEvent {}

class CheckWalletConnection extends WalletEvent {}

// States
abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object> get props => [];
}

class WalletInitial extends WalletState {}

class WalletConnecting extends WalletState {}

class WalletConnected extends WalletState {
  final String address;

  const WalletConnected(this.address);

  @override
  List<Object> get props => [address];
}

class WalletDisconnected extends WalletState {}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletService walletService;

  WalletBloc({required this.walletService}) : super(WalletInitial()) {
    on<ConnectWallet>(_onConnectWallet);
    on<DisconnectWallet>(_onDisconnectWallet);
    on<CheckWalletConnection>(_onCheckWalletConnection);
  }

  Future<void> _onConnectWallet(
    ConnectWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletConnecting());
    try {
      final success = await walletService.connectWallet();
      if (success) {
        final address = await walletService.getConnectedWalletAddress();
        if (address != null) {
          emit(WalletConnected(address));
        } else {
          emit(WalletError('Failed to get wallet address'));
        }
      } else {
        emit(WalletError('Failed to connect wallet'));
      }
    } catch (e) {
      emit(WalletError('Error connecting wallet: ${e.toString()}'));
    }
  }

  Future<void> _onDisconnectWallet(
    DisconnectWallet event,
    Emitter<WalletState> emit,
  ) async {
    try {
      final success = await walletService.disconnectWallet();
      if (success) {
        emit(WalletDisconnected());
      } else {
        emit(WalletError('Failed to disconnect wallet'));
      }
    } catch (e) {
      emit(WalletError('Error disconnecting wallet: ${e.toString()}'));
    }
  }

  Future<void> _onCheckWalletConnection(
    CheckWalletConnection event,
    Emitter<WalletState> emit,
  ) async {
    try {
      final isConnected = await walletService.isWalletConnected();
      if (isConnected) {
        final address = await walletService.getConnectedWalletAddress();
        if (address != null) {
          emit(WalletConnected(address));
        } else {
          emit(WalletDisconnected());
        }
      } else {
        emit(WalletDisconnected());
      }
    } catch (e) {
      emit(WalletError('Error checking wallet connection: ${e.toString()}'));
    }
  }
}
