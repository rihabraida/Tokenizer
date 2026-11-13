# Deploying Token42 and MultiSigWallet

Both parts were deployed on **Sepolia**, using Remix and MetaMask. These steps
also explain how to deploy new instances for evaluation.

## Prerequisites

- [Remix IDE](https://app.remix.live) and MetaMask on Sepolia, chain ID `11155111`.
- Sepolia test ETH for deployment and transaction fees.
- At least three owner accounts for the bonus, each with test ETH for its calls.

## Mandatory: deploy Token42

1. Copy [code/Tokenizer.sol](../code/Tokenizer.sol) into Remix. Its import uses
   OpenZeppelin Contracts `5.4.0`.
2. Select a compiler compatible with `^0.8.20`, for example `0.8.34`, and compile.
   Record the exact compiler, optimisation and EVM settings for verification.
3. In **Deploy & Run**, select **Browser Extension → MetaMask**. Check Sepolia
   and the account that should receive the initial supply.
4. Select **Token42**, leave **Value at 0**, and provide no constructor arguments.
   Click **Deploy** and confirm in MetaMask.
5. Save the generated contract address and deployment transaction hash. Read
   `name`, `symbol`, `totalSupply` and the deployer's `balanceOf`.

The constructor assigns 1,000,000 tokens to the deploying account. A second
deployment creates a separate token at a new address with independent balances.

## Bonus: deploy MultiSigWallet

1. Copy [code/multisig.sol](../code/multisig.sol) into Remix and compile it.
2. Select **MultiSigWallet**. Its only constructor argument, **_owners**, is an
   array of at least three different, nonzero wallet addresses you control.
   Enter them as `["fullAddressA", "fullAddressB", "fullAddressC"]`, replacing
   each example string with a full address. To reuse the existing setup, read
   its actual address array through `getOwners()`.
3. Leave **Value at 0**, deploy on Sepolia and confirm in MetaMask. Save the new
   multisig address and transaction hash. Check `getOwners()` and `REQUIRED()`.
4. The threshold is hardcoded to two confirmations excluding the submitter.
   There is no token-address or threshold argument in this constructor.
5. Open **Token42** and call `transfer(newMultisigAddress, amount)` from an
   account holding tokens. Check `balanceOf(newMultisigAddress)` on Token42.
6. Follow the [bonus demonstration](../documentation/MULTISIG.md) to submit,
   confirm and execute a token transfer. For new deployments, substitute both
   new contract addresses in that example.

## Recorded addresses

| Contract | Sepolia address |
|---|---|
| Token42 used for the bonus | [`0x8Af0e1120c5E9ba868C4a1d8b5e07D1900eaA12E`](https://sepolia.etherscan.io/address/0x8Af0e1120c5E9ba868C4a1d8b5e07D1900eaA12E) |
| MultiSigWallet | [`0x4bb0EF8b7a588DA016B563be3961d9b11897D780`](https://sepolia.etherscan.io/address/0x4bb0EF8b7a588DA016B563be3961d9b11897D780) |
| Earlier, independent Token42 | [`0x9AC2B6c78870494483ECfd3A1848095Cd9e8693D`](https://sepolia.etherscan.io/address/0x9AC2B6c78870494483ECfd3A1848095Cd9e8693D) |

The deploying wallet was `0x8C460b5C343A5b77d3cd8F5c1ABBeA4aAc2f5b96`.
Wallet addresses, token addresses and multisig addresses have different roles.

## Verification and reopening

Use Remix's **Contract Verification** plugin, or **Verify Contract on Explorers**
when deploying. Verification requires the same source, compiler, optimisation,
EVM settings and constructor arguments used at deployment. Check the verification
receipt for the chosen explorer; deployment alone does not verify source code.

To reopen a deployed instance, compile its matching source and use **Deployed
Contracts → Add Contract** with its address. Recompiling or clearing Remix's
list does not change the deployed contract. To recover a lost address, open the
deploying wallet on Sepolia Etherscan and inspect its **Contract Creation** transaction.

Official guides: [Deploy & Run](https://remix-ide.readthedocs.io/en/latest/run.html)
and [Contract Verification](https://remix-ide.readthedocs.io/en/latest/contract_verification.html).
