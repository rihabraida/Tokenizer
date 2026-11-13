# Tokenizer — 42 Token (42TK)

## Overview

An educational ERC-20 token for the 42 Tokenizer project, deployed on Ethereum
Sepolia using Remix and MetaMask. The bonus adds a separate multisig contract
for transfers that require several owners' approval.

## Features

| Property | Value |
|---|---|
| Name / symbol | 42 Token / 42TK |
| Standard | ERC-20 |
| Initial supply | 1,000,000 tokens, assigned to the deployer |
| Decimals | 18 |
| Network | Sepolia, chain ID `11155111` |
| Token permissions | No administrator or public mint/burn function |
| Bonus | Two confirmations from owners other than the request's submitter |

## Why these choices

- **Ethereum / ERC-20:** a standard interface understood by wallets and explorers.
- **Solidity:** supports Ethereum contracts and inheritance.
- **OpenZeppelin 5.4.0:** reuses its ERC-20 balance, transfer and allowance logic;
  the import pins the dependency version.
- **Sepolia:** allows deployment and testing with test ETH, without real money.
- **Remix / MetaMask:** compile and deploy from the browser, then sign actions
  with the selected wallet account.
- **Fixed supply:** the constructor creates all tokens once; there is no
  administrator able to create more afterward.
- **Separate multisig:** several owners control tokens deposited at its address.
  Token42 continues to record balances and process transfers normally.

## Deployments

| Contract | Sepolia address |
|---|---|
| Token42 used for the bonus | [`0x8Af0e1120c5E9ba868C4a1d8b5e07D1900eaA12E`](https://sepolia.etherscan.io/address/0x8Af0e1120c5E9ba868C4a1d8b5e07D1900eaA12E) |
| MultiSigWallet | [`0x4bb0EF8b7a588DA016B563be3961d9b11897D780`](https://sepolia.etherscan.io/address/0x4bb0EF8b7a588DA016B563be3961d9b11897D780) |

## Project structure

```text
Tokenizer/
├── code/
│   ├── Tokenizer.sol
│   └── multisig.sol
├── deployment/
│   └── README.md
├── documentation/
│   ├── README.md
│   └── MULTISIG.md
└── README.md
```

## Documentation

- [Mandatory: token behaviour and demonstration](documentation/README.md)
- [Bonus: multisig behaviour and demonstration](documentation/MULTISIG.md)
- [Deploy both contracts with Remix](deployment/README.md)

## Project goal

Learn how token balances, wallet signatures, allowances and shared approvals
work on a public test blockchain. 42TK is an educational asset with no promised
monetary value. Transaction fees are paid in Sepolia ETH, not in 42TK.
