import 'package:shared_preferences/shared_preferences.dart';

class WalletService {
  static const String _walletAddressKey = 'wallet_address';

  Future<bool> connectWallet() async {
    // In a real app, this would connect to MetaMask or other wallet providers
    // For demo purposes, we'll simulate a successful connection
    final String mockAddress = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';
    return await _saveWalletAddress(mockAddress);
  }

  Future<bool> disconnectWallet() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_walletAddressKey);
  }

  Future<String?> getConnectedWalletAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_walletAddressKey);
  }

  Future<bool> isWalletConnected() async {
    final address = await getConnectedWalletAddress();
    return address != null && address.isNotEmpty;
  }

  Future<bool> _saveWalletAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_walletAddressKey, address);
  }
}
