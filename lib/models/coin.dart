class Coin {
  final String id;
  final String name;
  final String symbol;
  final String image;
  final double currentPrice;
  final double priceChangePercentage24h;
  final double marketCap;
  final double volume;
  final double circulatingSupply;
  final String contractAddress;

  Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.image,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.marketCap,
    required this.volume,
    required this.circulatingSupply,
    required this.contractAddress,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      image: json['image'],
      currentPrice: json['current_price']?.toDouble() ?? 0.0,
      priceChangePercentage24h:
          json['price_change_percentage_24h']?.toDouble() ?? 0.0,
      marketCap: json['market_cap']?.toDouble() ?? 0.0,
      volume: json['total_volume']?.toDouble() ?? 0.0,
      circulatingSupply: json['circulating_supply']?.toDouble() ?? 0.0,
      contractAddress: json['contract_address'] ?? '',
    );
  }
}
