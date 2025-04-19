import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wallet_bloc.dart';

class ConnectWalletButton extends StatelessWidget {
  const ConnectWalletButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(builder: (context, state) {
      if (state is WalletConnecting) {
        return const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        );
      } else if (state is WalletConnected) {
        return GestureDetector(
          onTap: () {
            context.read<WalletBloc>().add(DisconnectWallet());
          },
          child: Chip(
            backgroundColor: Colors.green.shade100,
            label: Text(
              '${state.address.substring(0, 6)}...${state.address.substring(state.address.length - 4)}',
              style: const TextStyle(
                  color: Colors.green, fontWeight: FontWeight.bold),
            ),
            avatar: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.account_balance_wallet,
                  color: Colors.white, size: 16),
            ),
          ),
        );
      } else {
        return ElevatedButton.icon(
          onPressed: () {
            context.read<WalletBloc>().add(ConnectWallet());
          },
          icon: const Icon(Icons.account_balance_wallet),
          label: const Text('Connect Wallet'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    });
  }
}
