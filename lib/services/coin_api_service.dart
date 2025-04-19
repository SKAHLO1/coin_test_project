import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coin.dart';

class CoinApiService {
  final String baseUrl =
      'https://api.example.com/v1'; // Replace with actual Zora Base API

  Future<List<Coin>> getTrendingCoins() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/trending'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Coin.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trending coins');
      }
    } catch (e) {
      // For demo purposes, return mock data
      return _getMockCoins();
    }
  }

  Future<Coin> getCoinDetails(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/coins/$id'));

      if (response.statusCode == 200) {
        return Coin.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load coin details');
      }
    } catch (e) {
      // Return a mock coin for demo
      return _getMockCoins().firstWhere((coin) => coin.id == id);
    }
  }

  // Mock data for development
  List<Coin> _getMockCoins() {
    return [
      Coin(
        id: 'zora-eth',
        name: 'Zora ETH',
        symbol: 'ZETH',
        image:
            'https://assets.coingecko.com/coins/images/279/large/ethereum.png',
        currentPrice: 3245.67,
        priceChangePercentage24h: 2.45,
        marketCap: 389456789.0,
        volume: 23456789.0,
        circulatingSupply: 120000.0,
        contractAddress: '0x123abc...',
      ),
      Coin(
        id: 'zora-token',
        name: 'Zora Token',
        symbol: 'ZORA',
        image:
            'https://assets.coingecko.com/coins/images/24383/large/apecoin.jpg',
        currentPrice: 12.34,
        priceChangePercentage24h: -1.23,
        marketCap: 123456789.0,
        volume: 9876543.0,
        circulatingSupply: 10000000.0,
        contractAddress: '0x456def...',
      ),
      Coin(
        id: 'base-coin',
        name: 'Base Coin',
        symbol: 'BASE',
        image: 'https://assets.coingecko.com/coins/images/325/large/Tether.png',
        currentPrice: 5.67,
        priceChangePercentage24h: 0.34,
        marketCap: 78901234.0,
        volume: 4567890.0,
        circulatingSupply: 15000000.0,
        contractAddress: '0x789ghi...',
      ),
    ];
  }
}
