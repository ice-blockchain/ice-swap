# ICE Swap-Bridge Deployments

## ION Bridge Router Testnet Deployment 2024.02.13 (release candidate #2)

### Resulting addresses
Deployer address: `0x84b09b87fda11f845b2e611da5ea5c4f4bb9df0c`
https://testnet.bscscan.com/address/0x84b09b87fda11f845b2e611da5ea5c4f4bb9df0c

IONBridgeRouter address: `0x4A4DF9b7f529DC9c88c4b21f55aAe1a806eEfE4c`
https://testnet.bscscan.com/address/0x4A4DF9b7f529DC9c88c4b21f55aAe1a806eEfE4c

IONSwap address: `0x16f421aE3be15210553559793290269e2a3A6E5a`
https://testnet.bscscan.com/address/0x16f421aE3be15210553559793290269e2a3A6E5a

### Deployment log

```text
[block:48253097 txIndex:2]from: 0x37b...62491to: IONBridgeRouterTestnetDeployer.(constructor)value: 0 weidata: 0x608...b0033logs: 2hash: 0x728...78e87
status	0x1 Transaction mined and execution succeed
transaction hash	0x6c59b7a07ebc36402d361ab1fb466fe75f981c06802ed9e64119484e418d2008
block hash	0x728d07e05e4f9e1e703103a51f76da293715427e4e7cbc7cb29e88fd2dd78e87
block number	48253097
contract address	0x84b09b87fda11f845b2e611da5ea5c4f4bb9df0c
from	0x37bc9cdd62bebcabb9f3104556779f1ca2d62491
to	IONBridgeRouterTestnetDeployer.(constructor)
gas	1578897 gas
transaction cost	1578897 gas 
input	0x608...b0033
decoded input	{}
decoded output	 - 
logs	[
	{
		"from": "0x84b09b87fda11f845b2e611da5ea5c4f4bb9df0c",
		"topic": "0x71af5bed2316069d5e0d6c8ea5855878ac0b425427d2b11469a1bc6e300c6fdb",
		"event": "IONSwapDeployed",
		"args": {
			"0": "0xC632928ab4fC995e04b4D66da62C28cE56e2bd73",
			"1": "0x2A0864a15a63AC237a46405CCd6aD7Fa0513050D",
			"pooledToken": "0xC632928ab4fC995e04b4D66da62C28cE56e2bd73",
			"otherToken": "0x2A0864a15a63AC237a46405CCd6aD7Fa0513050D"
		}
	},
	{
		"from": "0x84b09b87fda11f845b2e611da5ea5c4f4bb9df0c",
		"topic": "0xa062cb6b0ba82ca946a470fffd62688ee66e17c476cb1d97eec7de15e66fe032",
		"event": "IONBridgeRouterDeployed",
		"args": {
			"0": "0x2A0864a15a63AC237a46405CCd6aD7Fa0513050D",
			"1": "0xC632928ab4fC995e04b4D66da62C28cE56e2bd73",
			"2": "0xC632928ab4fC995e04b4D66da62C28cE56e2bd73",
			"3": "0x16f421aE3be15210553559793290269e2a3A6E5a",
			"otherToken": "0x2A0864a15a63AC237a46405CCd6aD7Fa0513050D",
			"bridgeToken": "0xC632928ab4fC995e04b4D66da62C28cE56e2bd73",
			"pooledToken": "0xC632928ab4fC995e04b4D66da62C28cE56e2bd73",
			"swapAddress": "0x16f421aE3be15210553559793290269e2a3A6E5a"
		}
	}
]
raw logs	[
  {
    "address": "0x84b09b87fda11f845b2e611da5ea5c4f4bb9df0c",
    "topics": [
      "0x71af5bed2316069d5e0d6c8ea5855878ac0b425427d2b11469a1bc6e300c6fdb",
      "0x000000000000000000000000c632928ab4fc995e04b4d66da62c28ce56e2bd73",
      "0x0000000000000000000000002a0864a15a63ac237a46405ccd6ad7fa0513050d"
    ],
    "data": "0x",
    "blockNumber": "0x2e048a9",
    "transactionHash": "0x6c59b7a07ebc36402d361ab1fb466fe75f981c06802ed9e64119484e418d2008",
    "transactionIndex": "0x2",
    "blockHash": "0x728d07e05e4f9e1e703103a51f76da293715427e4e7cbc7cb29e88fd2dd78e87",
    "logIndex": "0x1",
    "removed": false
  },
  {
    "address": "0x84b09b87fda11f845b2e611da5ea5c4f4bb9df0c",
    "topics": [
      "0xa062cb6b0ba82ca946a470fffd62688ee66e17c476cb1d97eec7de15e66fe032",
      "0x0000000000000000000000002a0864a15a63ac237a46405ccd6ad7fa0513050d",
      "0x000000000000000000000000c632928ab4fc995e04b4d66da62c28ce56e2bd73",
      "0x000000000000000000000000c632928ab4fc995e04b4d66da62c28ce56e2bd73"
    ],
    "data": "0x00000000000000000000000016f421ae3be15210553559793290269e2a3a6e5a",
    "blockNumber": "0x2e048a9",
    "transactionHash": "0x6c59b7a07ebc36402d361ab1fb466fe75f981c06802ed9e64119484e418d2008",
    "transactionIndex": "0x2",
    "blockHash": "0x728d07e05e4f9e1e703103a51f76da293715427e4e7cbc7cb29e88fd2dd78e87",
    "logIndex": "0x2",
    "removed": false
  }
]
```

## ION Bridge Router Mainnet Deployment 2024.02.13 (release candidate #2)

### Resulting addresses
Deployer address: `0x0eb8992836dd1a6b36f93a745f84a1adeeaf3716`
https://bscscan.com/address/0x0eb8992836dd1a6b36f93a745f84a1adeeaf3716

IONBridgeRouter address: `0x227002f9042ce429e9055189A2a41e9D8D69D9Be`
https://bscscan.com/address/0x227002f9042ce429e9055189A2a41e9D8D69D9Be

IONSwap address: `0xecA717337Ba328414908413a6a19d67C00BFAcE2`
https://bscscan.com/address/0xecA717337Ba328414908413a6a19d67C00BFAcE2

### Deployment log

```text
[block:46623474 txIndex:71]from: 0x955...24cc4to: IONBridgeRouterMainnetDeployer.(constructor)value: 0 weidata: 0x608...b0033logs: 2hash: 0x619...f5e21
status	0x1 Transaction mined and execution succeed
transaction hash	0xc0e695bce3beb22da482744614ce0c9cacd1731065fc768a0b08fc835ead12b2
block hash	0x61903a1acb97b19f6e391cc65973e8b1cbb6f370646623d998fc316b0a6f5e21
block number	46623474
contract address	0x0eb8992836dd1a6b36f93a745f84a1adeeaf3716
from	0x955ca2bc020e10abaab75f8c92e9b9b80a224cc4
to	IONBridgeRouterMainnetDeployer.(constructor)
gas	1578898 gas
transaction cost	1578898 gas 
input	0x608...b0033
decoded input	{}
decoded output	 - 
logs	[
	{
		"from": "0x0eb8992836dd1a6b36f93a745f84a1adeeaf3716",
		"topic": "0x71af5bed2316069d5e0d6c8ea5855878ac0b425427d2b11469a1bc6e300c6fdb",
		"event": "IONSwapDeployed",
		"args": {
			"0": "0x1B31606fcb91BaE1DFFD646061f6dD6FB35D0Bb5",
			"1": "0xc335Df7C25b72eEC661d5Aa32a7c2B7b2a1D1874",
			"pooledToken": "0x1B31606fcb91BaE1DFFD646061f6dD6FB35D0Bb5",
			"otherToken": "0xc335Df7C25b72eEC661d5Aa32a7c2B7b2a1D1874"
		}
	},
	{
		"from": "0x0eb8992836dd1a6b36f93a745f84a1adeeaf3716",
		"topic": "0xa062cb6b0ba82ca946a470fffd62688ee66e17c476cb1d97eec7de15e66fe032",
		"event": "IONBridgeRouterDeployed",
		"args": {
			"0": "0xc335Df7C25b72eEC661d5Aa32a7c2B7b2a1D1874",
			"1": "0x1B31606fcb91BaE1DFFD646061f6dD6FB35D0Bb5",
			"2": "0x1B31606fcb91BaE1DFFD646061f6dD6FB35D0Bb5",
			"3": "0xecA717337Ba328414908413a6a19d67C00BFAcE2",
			"otherToken": "0xc335Df7C25b72eEC661d5Aa32a7c2B7b2a1D1874",
			"bridgeToken": "0x1B31606fcb91BaE1DFFD646061f6dD6FB35D0Bb5",
			"pooledToken": "0x1B31606fcb91BaE1DFFD646061f6dD6FB35D0Bb5",
			"swapAddress": "0xecA717337Ba328414908413a6a19d67C00BFAcE2"
		}
	}
]
raw logs	[
  {
    "address": "0x0eb8992836dd1a6b36f93a745f84a1adeeaf3716",
    "topics": [
      "0x71af5bed2316069d5e0d6c8ea5855878ac0b425427d2b11469a1bc6e300c6fdb",
      "0x0000000000000000000000001b31606fcb91bae1dffd646061f6dd6fb35d0bb5",
      "0x000000000000000000000000c335df7c25b72eec661d5aa32a7c2b7b2a1d1874"
    ],
    "data": "0x",
    "blockNumber": "0x2c76af2",
    "transactionHash": "0xc0e695bce3beb22da482744614ce0c9cacd1731065fc768a0b08fc835ead12b2",
    "transactionIndex": "0x47",
    "blockHash": "0x61903a1acb97b19f6e391cc65973e8b1cbb6f370646623d998fc316b0a6f5e21",
    "logIndex": "0x94",
    "removed": false
  },
  {
    "address": "0x0eb8992836dd1a6b36f93a745f84a1adeeaf3716",
    "topics": [
      "0xa062cb6b0ba82ca946a470fffd62688ee66e17c476cb1d97eec7de15e66fe032",
      "0x000000000000000000000000c335df7c25b72eec661d5aa32a7c2b7b2a1d1874",
      "0x0000000000000000000000001b31606fcb91bae1dffd646061f6dd6fb35d0bb5",
      "0x0000000000000000000000001b31606fcb91bae1dffd646061f6dd6fb35d0bb5"
    ],
    "data": "0x000000000000000000000000eca717337ba328414908413a6a19d67c00bface2",
    "blockNumber": "0x2c76af2",
    "transactionHash": "0xc0e695bce3beb22da482744614ce0c9cacd1731065fc768a0b08fc835ead12b2",
    "transactionIndex": "0x47",
    "blockHash": "0x61903a1acb97b19f6e391cc65973e8b1cbb6f370646623d998fc316b0a6f5e21",
    "logIndex": "0x95",
    "removed": false
  }
]
>
```

## ION Bridge Router Mainnet Deployment 2025.01.20 (release candidate #1)

### Resulting addresses

Deployer address: `0xdb6c94d279740222f0dc2f0da5cf8afccf7e4f74`
https://bscscan.com/address/0xdb6c94d279740222f0dc2f0da5cf8afccf7e4f74

IONBridgeRouter address: `0xd62148F4c8269DA6BF7E3C2d3A0E0363C924590E`
https://bscscan.com/address/0xd62148F4c8269DA6BF7E3C2d3A0E0363C924590E

IONSwap address: `0x6443854AA5E773BEc36329Ff7A3Ca62a65cecD63`
https://bscscan.com/address/0x6443854AA5E773BEc36329Ff7A3Ca62a65cecD63

MultiSigWallet address: `0xDFDe8108E14c70B6796bdd220454A80E849C7689`
https://bscscan.com/address/0xDFDe8108E14c70B6796bdd220454A80E849C7689

### Oracles configuration update (`.env`)

The following is the environment variable, which instructs the `BSC-ION` oracle to parse transactions from the router address.
Needs to be defined only for the `BSC-ION` oracles.

```dotenv
EVM_ROUTER_CONTRACT_ADDRESS=0xd62148F4c8269DA6BF7E3C2d3A0E0363C924590E
```

### Deployment log

Below is the Remix IDE log while deploying the contracts, which may be useful while validating contracts.

```text
[block:45934482 txIndex:59]from: 0x955...24cc4to: IONBridgeRouterMainnetDeployer.(constructor)value: 0 weidata: 0x608...b0033logs: 3hash: 0x238...2815e
status	0x1 Transaction mined and execution succeed
transaction hash	0xb673ccb16da90dc7765d17211473996b03991b98f801787418b88aee266b7786
block hash	0x2389974691c0fe70d789e2cd2b646ebb7c5b91307eaf53633aa50721cb02815e
block number	45934482
contract address	0xdb6c94d279740222f0dc2f0da5cf8afccf7e4f74
from	0x955ca2bc020e10abaab75f8c92e9b9b80a224cc4
to	IONBridgeRouterMainnetDeployer.(constructor)
gas	1872484 gas
transaction cost	1872484 gas 
input	0x608...b0033
decoded input	{}
decoded output	 - 
logs	[
	{
		"from": "0x6443854aa5e773bec36329ff7a3ca62a65cecd63",
		"topic": "0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0",
		"event": "OwnershipTransferred",
		"args": {
			"0": "0x0000000000000000000000000000000000000000",
			"1": "0xDFDe8108E14c70B6796bdd220454A80E849C7689",
			"previousOwner": "0x0000000000000000000000000000000000000000",
			"newOwner": "0xDFDe8108E14c70B6796bdd220454A80E849C7689"
		}
	},
	{
		"from": "0xdb6c94d279740222f0dc2f0da5cf8afccf7e4f74",
		"topic": "0x12ee4d607c95ed59c225e621b01ad8701d734265467d670f88cce31db25a43ee",
		"event": "IONSwapDeployed",
		"args": {
			"0": "0xDFDe8108E14c70B6796bdd220454A80E849C7689",
			"1": "0x1B31606fcb91BaE1DFFD646061f6dD6FB35D0Bb5",
			"2": "0xc335Df7C25b72eEC661d5Aa32a7c2B7b2a1D1874",
			"owner": "0xDFDe8108E14c70B6796bdd220454A80E849C7689",
			"pooledToken": "0x1B31606fcb91BaE1DFFD646061f6dD6FB35D0Bb5",
			"otherToken": "0xc335Df7C25b72eEC661d5Aa32a7c2B7b2a1D1874"
		}
	},
	{
		"from": "0xdb6c94d279740222f0dc2f0da5cf8afccf7e4f74",
		"topic": "0xa062cb6b0ba82ca946a470fffd62688ee66e17c476cb1d97eec7de15e66fe032",
		"event": "IONBridgeRouterDeployed",
		"args": {
			"0": "0xc335Df7C25b72eEC661d5Aa32a7c2B7b2a1D1874",
			"1": "0x1B31606fcb91BaE1DFFD646061f6dD6FB35D0Bb5",
			"2": "0x1B31606fcb91BaE1DFFD646061f6dD6FB35D0Bb5",
			"3": "0x6443854AA5E773BEc36329Ff7A3Ca62a65cecD63",
			"otherToken": "0xc335Df7C25b72eEC661d5Aa32a7c2B7b2a1D1874",
			"bridgeToken": "0x1B31606fcb91BaE1DFFD646061f6dD6FB35D0Bb5",
			"pooledToken": "0x1B31606fcb91BaE1DFFD646061f6dD6FB35D0Bb5",
			"swapAddress": "0x6443854AA5E773BEc36329Ff7A3Ca62a65cecD63"
		}
	}
]
raw logs	[
  {
    "address": "0x6443854aa5e773bec36329ff7a3ca62a65cecd63",
    "topics": [
      "0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0",
      "0x0000000000000000000000000000000000000000000000000000000000000000",
      "0x000000000000000000000000dfde8108e14c70b6796bdd220454a80e849c7689"
    ],
    "data": "0x",
    "blockNumber": "0x2bce792",
    "transactionHash": "0xb673ccb16da90dc7765d17211473996b03991b98f801787418b88aee266b7786",
    "transactionIndex": "0x3b",
    "blockHash": "0x2389974691c0fe70d789e2cd2b646ebb7c5b91307eaf53633aa50721cb02815e",
    "logIndex": "0xea",
    "removed": false
  },
  {
    "address": "0xdb6c94d279740222f0dc2f0da5cf8afccf7e4f74",
    "topics": [
      "0x12ee4d607c95ed59c225e621b01ad8701d734265467d670f88cce31db25a43ee",
      "0x000000000000000000000000dfde8108e14c70b6796bdd220454a80e849c7689",
      "0x0000000000000000000000001b31606fcb91bae1dffd646061f6dd6fb35d0bb5",
      "0x000000000000000000000000c335df7c25b72eec661d5aa32a7c2b7b2a1d1874"
    ],
    "data": "0x",
    "blockNumber": "0x2bce792",
    "transactionHash": "0xb673ccb16da90dc7765d17211473996b03991b98f801787418b88aee266b7786",
    "transactionIndex": "0x3b",
    "blockHash": "0x2389974691c0fe70d789e2cd2b646ebb7c5b91307eaf53633aa50721cb02815e",
    "logIndex": "0xeb",
    "removed": false
  },
  {
    "address": "0xdb6c94d279740222f0dc2f0da5cf8afccf7e4f74",
    "topics": [
      "0xa062cb6b0ba82ca946a470fffd62688ee66e17c476cb1d97eec7de15e66fe032",
      "0x000000000000000000000000c335df7c25b72eec661d5aa32a7c2b7b2a1d1874",
      "0x0000000000000000000000001b31606fcb91bae1dffd646061f6dd6fb35d0bb5",
      "0x0000000000000000000000001b31606fcb91bae1dffd646061f6dd6fb35d0bb5"
    ],
    "data": "0x0000000000000000000000006443854aa5e773bec36329ff7a3ca62a65cecd63",
    "blockNumber": "0x2bce792",
    "transactionHash": "0xb673ccb16da90dc7765d17211473996b03991b98f801787418b88aee266b7786",
    "transactionIndex": "0x3b",
    "blockHash": "0x2389974691c0fe70d789e2cd2b646ebb7c5b91307eaf53633aa50721cb02815e",
    "logIndex": "0xec",
    "removed": false
  }
]
>
```

## ION Bridge Router Mainnet Deployment 2025.01.19

https://bscscan.com/address/0x160e7d3e0f506dbaa07fe5d2c9455e988524e656#code

Simulating Safe.global liquidity withdrawal for this contracts cluster:
https://dashboard.tenderly.co/public/safe/safe-apps/simulator/98409aab-10be-4d04-8b19-521f83a64751

Below is the Remix IDE log while deploying the contracts, which may be useful while validating contracts.


```text

[block:45904581 txIndex:41]from: 0x955...24cc4to: IONBridgeRouterMainnetDeployer.(constructor)value: 0 weidata: 0x608...b0033logs: 3hash: 0x037...36c5b
status	0x1 Transaction mined and execution succeed
transaction hash	0xde68e1c04cd97025106618f3ccb71141d0629f1c481ae08ceb87f8b31c1a2248
block hash	0x037da070adeccf872cb5d183772e1edb545677317ab2873e2290006f69036c5b
block number	45904581
contract address	0x160e7d3e0f506dbaa07fe5d2c9455e988524e656
from	0x955ca2bc020e10abaab75f8c92e9b9b80a224cc4
to	IONBridgeRouterMainnetDeployer.(constructor)
gas	3206676 gas
transaction cost	3206676 gas 
input	0x608...b0033
decoded input	{}
decoded output	 - 
logs	[
	{
		"from": "0xce33eca273e857b6af213755cf42ff1fd3efc26a",
		"topic": "0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0",
		"event": "OwnershipTransferred",
		"args": {
			"0": "0x0000000000000000000000000000000000000000",
			"1": "0xae4094223718f34f581485E56C209bfa281290dc",
			"previousOwner": "0x0000000000000000000000000000000000000000",
			"newOwner": "0xae4094223718f34f581485E56C209bfa281290dc"
		}
	},
	{
		"from": "0x160e7d3e0f506dbaa07fe5d2c9455e988524e656",
		"topic": "0x12ee4d607c95ed59c225e621b01ad8701d734265467d670f88cce31db25a43ee",
		"event": "IONSwapDeployed",
		"args": {
			"0": "0xae4094223718f34f581485E56C209bfa281290dc",
			"1": "0x2B90E061a517dB2BbD7E39Ef7F733Fd234B494CA",
			"2": "0xc335Df7C25b72eEC661d5Aa32a7c2B7b2a1D1874",
			"owner": "0xae4094223718f34f581485E56C209bfa281290dc",
			"pooledToken": "0x2B90E061a517dB2BbD7E39Ef7F733Fd234B494CA",
			"otherToken": "0xc335Df7C25b72eEC661d5Aa32a7c2B7b2a1D1874"
		}
	},
	{
		"from": "0x160e7d3e0f506dbaa07fe5d2c9455e988524e656",
		"topic": "0xa062cb6b0ba82ca946a470fffd62688ee66e17c476cb1d97eec7de15e66fe032",
		"event": "IONBridgeRouterDeployed",
		"args": {
			"0": "0xc335Df7C25b72eEC661d5Aa32a7c2B7b2a1D1874",
			"1": "0x2B90E061a517dB2BbD7E39Ef7F733Fd234B494CA",
			"2": "0x2B90E061a517dB2BbD7E39Ef7F733Fd234B494CA",
			"3": "0xCe33ECA273e857B6Af213755CF42ff1fD3efC26a",
			"otherToken": "0xc335Df7C25b72eEC661d5Aa32a7c2B7b2a1D1874",
			"bridgeToken": "0x2B90E061a517dB2BbD7E39Ef7F733Fd234B494CA",
			"pooledToken": "0x2B90E061a517dB2BbD7E39Ef7F733Fd234B494CA",
			"swapAddress": "0xCe33ECA273e857B6Af213755CF42ff1fD3efC26a"
		}
	}
]
raw logs	[
  {
    "address": "0xce33eca273e857b6af213755cf42ff1fd3efc26a",
    "topics": [
      "0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0",
      "0x0000000000000000000000000000000000000000000000000000000000000000",
      "0x000000000000000000000000ae4094223718f34f581485e56c209bfa281290dc"
    ],
    "data": "0x",
    "blockNumber": "0x2bc72c5",
    "transactionHash": "0xde68e1c04cd97025106618f3ccb71141d0629f1c481ae08ceb87f8b31c1a2248",
    "transactionIndex": "0x29",
    "blockHash": "0x037da070adeccf872cb5d183772e1edb545677317ab2873e2290006f69036c5b",
    "logIndex": "0xae",
    "removed": false
  },
  {
    "address": "0x160e7d3e0f506dbaa07fe5d2c9455e988524e656",
    "topics": [
      "0x12ee4d607c95ed59c225e621b01ad8701d734265467d670f88cce31db25a43ee",
      "0x000000000000000000000000ae4094223718f34f581485e56c209bfa281290dc",
      "0x0000000000000000000000002b90e061a517db2bbd7e39ef7f733fd234b494ca",
      "0x000000000000000000000000c335df7c25b72eec661d5aa32a7c2b7b2a1d1874"
    ],
    "data": "0x",
    "blockNumber": "0x2bc72c5",
    "transactionHash": "0xde68e1c04cd97025106618f3ccb71141d0629f1c481ae08ceb87f8b31c1a2248",
    "transactionIndex": "0x29",
    "blockHash": "0x037da070adeccf872cb5d183772e1edb545677317ab2873e2290006f69036c5b",
    "logIndex": "0xaf",
    "removed": false
  },
  {
    "address": "0x160e7d3e0f506dbaa07fe5d2c9455e988524e656",
    "topics": [
      "0xa062cb6b0ba82ca946a470fffd62688ee66e17c476cb1d97eec7de15e66fe032",
      "0x000000000000000000000000c335df7c25b72eec661d5aa32a7c2b7b2a1d1874",
      "0x0000000000000000000000002b90e061a517db2bbd7e39ef7f733fd234b494ca",
      "0x0000000000000000000000002b90e061a517db2bbd7e39ef7f733fd234b494ca"
    ],
    "data": "0x000000000000000000000000ce33eca273e857b6af213755cf42ff1fd3efc26a",
    "blockNumber": "0x2bc72c5",
    "transactionHash": "0xde68e1c04cd97025106618f3ccb71141d0629f1c481ae08ceb87f8b31c1a2248",
    "transactionIndex": "0x29",
    "blockHash": "0x037da070adeccf872cb5d183772e1edb545677317ab2873e2290006f69036c5b",
    "logIndex": "0xb0",
    "removed": false
  }
]
>
```

## ION Bridge Router Testnet Deployment 2025.01.19
https://testnet.bscscan.com/address/0xd89d758689226590113a83d3c6104016bb97e895#readContract

Below is the Remix IDE log while deploying the contracts, which may be useful while validating contracts.

```text
[block:47508819 txIndex:2]from: 0x37b...62491to: IONBridgeRouterTestnetDeployer.(constructor)value: 0 weidata: 0x608...b0033logs: 3hash: 0x001...b7177
status	0x1 Transaction mined and execution succeed
transaction hash	0x46c2929dbb61a0efcc05e5c366bd062bdc143c7822b749ddd477f53b49e18682
block hash	0x0010338885727186a42a91443086abe6220ff2bbcfb21bb0dba28bcf8f0b7177
block number	47508819
contract address	0xd89d758689226590113a83d3c6104016bb97e895
from	0x37bc9cdd62bebcabb9f3104556779f1ca2d62491
to	IONBridgeRouterTestnetDeployer.(constructor)
gas	3189426 gas
transaction cost	3189426 gas 
input	0x608...b0033
decoded input	{}
decoded output	 - 
logs	[
	{
		"from": "0xeec086956bafe2d6225285ab99292722171a92da",
		"topic": "0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0",
		"event": "OwnershipTransferred",
		"args": {
			"0": "0x0000000000000000000000000000000000000000",
			"1": "0xae4094223718f34f581485E56C209bfa281290dc",
			"previousOwner": "0x0000000000000000000000000000000000000000",
			"newOwner": "0xae4094223718f34f581485E56C209bfa281290dc"
		}
	},
	{
		"from": "0xd89d758689226590113a83d3c6104016bb97e895",
		"topic": "0x12ee4d607c95ed59c225e621b01ad8701d734265467d670f88cce31db25a43ee",
		"event": "IONSwapDeployed",
		"args": {
			"0": "0xae4094223718f34f581485E56C209bfa281290dc",
			"1": "0xC632928ab4fC995e04b4D66da62C28cE56e2bd73",
			"2": "0x2A0864a15a63AC237a46405CCd6aD7Fa0513050D",
			"owner": "0xae4094223718f34f581485E56C209bfa281290dc",
			"pooledToken": "0xC632928ab4fC995e04b4D66da62C28cE56e2bd73",
			"otherToken": "0x2A0864a15a63AC237a46405CCd6aD7Fa0513050D"
		}
	},
	{
		"from": "0xd89d758689226590113a83d3c6104016bb97e895",
		"topic": "0xa062cb6b0ba82ca946a470fffd62688ee66e17c476cb1d97eec7de15e66fe032",
		"event": "IONBridgeRouterDeployed",
		"args": {
			"0": "0x2A0864a15a63AC237a46405CCd6aD7Fa0513050D",
			"1": "0xC632928ab4fC995e04b4D66da62C28cE56e2bd73",
			"2": "0xC632928ab4fC995e04b4D66da62C28cE56e2bd73",
			"3": "0xEeC086956bAfe2D6225285aB99292722171A92Da",
			"otherToken": "0x2A0864a15a63AC237a46405CCd6aD7Fa0513050D",
			"bridgeToken": "0xC632928ab4fC995e04b4D66da62C28cE56e2bd73",
			"pooledToken": "0xC632928ab4fC995e04b4D66da62C28cE56e2bd73",
			"swapAddress": "0xEeC086956bAfe2D6225285aB99292722171A92Da"
		}
	}
]
raw logs	[
  {
    "address": "0xeec086956bafe2d6225285ab99292722171a92da",
    "topics": [
      "0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0",
      "0x0000000000000000000000000000000000000000000000000000000000000000",
      "0x000000000000000000000000ae4094223718f34f581485e56c209bfa281290dc"
    ],
    "data": "0x",
    "blockNumber": "0x2d4ed53",
    "transactionHash": "0x46c2929dbb61a0efcc05e5c366bd062bdc143c7822b749ddd477f53b49e18682",
    "transactionIndex": "0x2",
    "blockHash": "0x0010338885727186a42a91443086abe6220ff2bbcfb21bb0dba28bcf8f0b7177",
    "logIndex": "0x0",
    "removed": false
  },
  {
    "address": "0xd89d758689226590113a83d3c6104016bb97e895",
    "topics": [
      "0x12ee4d607c95ed59c225e621b01ad8701d734265467d670f88cce31db25a43ee",
      "0x000000000000000000000000ae4094223718f34f581485e56c209bfa281290dc",
      "0x000000000000000000000000c632928ab4fc995e04b4d66da62c28ce56e2bd73",
      "0x0000000000000000000000002a0864a15a63ac237a46405ccd6ad7fa0513050d"
    ],
    "data": "0x",
    "blockNumber": "0x2d4ed53",
    "transactionHash": "0x46c2929dbb61a0efcc05e5c366bd062bdc143c7822b749ddd477f53b49e18682",
    "transactionIndex": "0x2",
    "blockHash": "0x0010338885727186a42a91443086abe6220ff2bbcfb21bb0dba28bcf8f0b7177",
    "logIndex": "0x1",
    "removed": false
  },
  {
    "address": "0xd89d758689226590113a83d3c6104016bb97e895",
    "topics": [
      "0xa062cb6b0ba82ca946a470fffd62688ee66e17c476cb1d97eec7de15e66fe032",
      "0x0000000000000000000000002a0864a15a63ac237a46405ccd6ad7fa0513050d",
      "0x000000000000000000000000c632928ab4fc995e04b4d66da62c28ce56e2bd73",
      "0x000000000000000000000000c632928ab4fc995e04b4d66da62c28ce56e2bd73"
    ],
    "data": "0x000000000000000000000000eec086956bafe2d6225285ab99292722171a92da",
    "blockNumber": "0x2d4ed53",
    "transactionHash": "0x46c2929dbb61a0efcc05e5c366bd062bdc143c7822b749ddd477f53b49e18682",
    "transactionIndex": "0x2",
    "blockHash": "0x0010338885727186a42a91443086abe6220ff2bbcfb21bb0dba28bcf8f0b7177",
    "logIndex": "0x2",
    "removed": false
  }
]
>
```

## ION Bridge Router Testnet Deployment 2025.01.15
Here is the ION Bridge Router factory, which contains all major addresses for the deployed system:

Optimization: ON
Optimization-level: 200
https://testnet.bscscan.com/address/0x0297114f42ec7a6447a590d02458c4916ffc4e52#readContract

ION Bridge Router: 0xD83827590808a3130Cf097AF59F12b6A979898b9

## `Safe.global` Accounts

### `TEST ICE Swap-Bridge` Safe.global Account
Deployed at transaction: https://bscscan.com/tx/0x6409576892837c4117dc3a46a38cd2411657ea2f92676efbc243001608bcf97c

Account address: `bnb:0xae4094223718f34f581485E56C209bfa281290dc`.
`SafeProxy` address: `0xae4094223718f34f581485E56C209bfa281290dc`.
`Signer 1` address: `bnb:0x955cA2bC020E10abaaB75f8C92E9b9b80A224cc4`, `0x955cA2bC020E10abaaB75f8C92E9b9b80A224cc4`.

**NOTE**: The `SafeProxy` is the address, which should be specified as the contract owner for contracts, controlled by the multi-sig wallet.

