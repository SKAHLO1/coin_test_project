import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/coin_bloc.dart';
import '../bloc/wallet_bloc.dart';
import '../models/coin.dart';
import '../widgets/connect_wallet_button.dart';

class CoinPurchaseScreen extends StatefulWidget {
  final String coinId;

  const CoinPurchaseScreen({Key? key, required this.coinId}) : super(key: key);

  @override
  State<CoinPurchaseScreen> createState() => _CoinPurchaseScreenState();
}

class _CoinPurchaseScreenState extends State<CoinPurchaseScreen> {
  final TextEditingController _amountController = TextEditingController();
  double _totalCost = 0.0;
  Coin? _coin;

  @override
  void initState() {
    super.initState();
    context.read<CoinBloc>().add(FetchCoinDetails(widget.coinId));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateTotalCost() {
    if (_coin != null) {
      final amount = double.tryParse(_amountController.text) ?? 0;
      setState(() {
        _totalCost = amount * _coin!.currentPrice;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Coin'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ConnectWalletButton(),
          ),
        ],
      ),
      body: BlocBuilder<CoinBloc, CoinState>(
        builder: (context, state) {
          if (state is CoinLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CoinDetailsLoaded) {
            _coin = state.coin;
            return _buildPurchaseForm(context, state.coin);
          } else if (state is CoinError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<CoinBloc>()
                          .add(FetchCoinDetails(widget.coinId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildPurchaseForm(BuildContext context, Coin coin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coin info header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      coin.image,
                      width: 48,
                      height: 48,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 48,
                          height: 48,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coin.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          coin.symbol.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${coin.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: coin.priceChangePercentage24h >= 0
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${coin.priceChangePercentage24h >= 0 ? '+' : ''}${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: coin.priceChangePercentage24h >= 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Market data
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Market Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMarketDataRow(
                      'Market Cap', '\$${_formatNumber(coin.marketCap)}'),
                  const Divider(),
                  _buildMarketDataRow(
                      '24h Volume', '\$${_formatNumber(coin.volume)}'),
                  const Divider(),
                  _buildMarketDataRow('Circulating Supply',
                      '${_formatNumber(coin.circulatingSupply)} ${coin.symbol.toUpperCase()}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Purchase form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Purchase',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,8}')),
                    ],
                    onChanged: (_) => _calculateTotalCost(),
                    decoration: InputDecoration(
                      labelText: 'Amount to buy',
                      hintText: '0.0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixText: coin.symbol.toUpperCase(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Cost:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '\$${_totalCost.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<WalletBloc, WalletState>(
                    builder: (context, walletState) {
                      final bool isWalletConnected =
                          walletState is WalletConnected;

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isWalletConnected &&
                                  _amountController.text.isNotEmpty
                              ? () => _showPurchaseConfirmation(context, coin)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: Text(
                            isWalletConnected
                                ? 'Buy ${coin.symbol.toUpperCase()}'
                                : 'Connect Wallet to Buy',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    } else {
      return number.toStringAsFixed(2);
    }
  }

  void _showPurchaseConfirmation(BuildContext context, Coin coin) {
    final amount = double.tryParse(_amountController.text) ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to purchase:'),
            const SizedBox(height: 8),
            Text(
              '$amount ${coin.symbol.toUpperCase()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Text('Total cost: \$${_totalCost.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text(
              'Note: This is a demo app. No actual transaction will occur.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPurchaseSuccess(context);
            },
            child: const Text('Confirm Purchase'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Successful'),
        content: const Text('Your purchase was completed successfully!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear the form
              _amountController.clear();
              setState(() {
                _totalCost = 0.0;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
