// Import the required libraries
import { createPublicClient, http } from 'viem';
import { mainnet } from 'viem/chains';
import { getCoins, getTrendingCoins } from '@zoralabs/coins-sdk';

// Make them available globally
window.viem = { createPublicClient, http };
window.chains = { mainnet };
window.zoraCoinsSDK = { getCoins, getTrendingCoins };
