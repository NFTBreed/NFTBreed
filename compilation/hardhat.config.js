/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
const { API_URL, PRIVATE_KEY, API_URL_MAINNET, PRIVATE_KEY_MAINNET, ETHERSCAN_API_KEY, DEPLOYER_URL_MAINNET, DEPLOYER_URL_TESTNET } = process.env;
module.exports = {
	solidity: {
		version: "0.8.6",
		settings: {
			optimizer: {
				enabled: true
			}
		}
	},
	defaultNetwork: "testnet",
	networks: {
		hardhat: {},
		smartchain: {
			url: API_URL,
			accounts: [`0x${PRIVATE_KEY}`]
		},
		testnet: {
			url: DEPLOYER_URL_TESTNET,
			chainId: 97,
			gasPrice: 20000000000,
			accounts: [`0x${PRIVATE_KEY}`]
		},
		bsc_mainnet: {
			url: DEPLOYER_URL_MAINNET,
			chainId: 56,
			gasPrice: 20000000000,
			accounts: [`0x${PRIVATE_KEY}`]
		}
	},
	etherscan: {
		apiKey: ETHERSCAN_API_KEY
	},
	paths: {
		sources: "./contracts",
		tests: "./test",
		cache: "./ressources/cache",
		artifacts: "./ressources/artifacts"
	}
};
// compile -> npx hardhat compile 
// deploy -> npx hardhat run scripts/deploy.js --network testnet
// verif -> npx hardhat verify --network testnet 0x4468f1f0204C4bd705F1573607ebDCF16600A2Ad
/* 
Verif with contract who have argument 
-> npx hardhat verify --network mainnet DEPLOYED_CONTRACT_ADDRESS "Constructor argument 1"
example : npx hardhat verify --network testnet 0x1e182214bbca0b43acb0297835cbfeb0766fc611 "0xadbae6c937e196c4840d2a3d8f9c87a513177c27"
*/
// emplacement abi.json -> C:\Users\Améyibo Bévi\Documents\Node.js Project\NFTBreed\compilation\artifacts\contracts\NFTBreed.sol