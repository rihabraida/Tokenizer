# Token design

## Purpose

42 Token (42TK) is an educational token used to demonstrate ERC-20 behavior on
Sepolia. Its scope is creating an initial supply, reading balances, transferring
tokens, and managing spending permissions. It does not promise a market price.

## Creation and supply

The constructor sets the name and symbol and calls `_mint` once. The initial
1,000,000 42TK are assigned to `msg.sender`, the caller creating the contract.
When deploying directly from a wallet through Remix, this is the selected
deploying wallet's address.

The source exposes no further minting or burning function. Transferring tokens
changes balances without changing the total supply.

## Token units

The token uses 18 decimal places. Contract functions take integer amounts in
base units; a wallet may convert a human-readable amount automatically.

| Human-readable amount | Base units used by contract functions |
| --- | --- |
| 1 42TK | 1000000000000000000 |
| 10 42TK | 10000000000000000000 |
| Entire initial supply | 1000000000000000000000000 |

When calling a function directly, entering `10` means ten base units, not ten
whole tokens.

## Functions

The contract inherits these functions from OpenZeppelin's ERC-20 implementation:

| Function | Purpose |
| --- | --- |
| `name()`, `symbol()`, `decimals()` | Read token metadata |
| `totalSupply()` | Read the supply in base units |
| `balanceOf(account)` | Read an address's balance |
| `transfer(to, amount)` | Send the caller's tokens |
| `approve(spender, amount)` | Set a spender's allowance |
| `allowance(owner, spender)` | Read the remaining allowance |
| `transferFrom(from, to, amount)` | Spend tokens within the caller's allowance |
| `INITIAL_SUPPLY()` | Read the constant in whole tokens: 1,000,000 |

`approve` does not transfer tokens and does not implement multisig. It lets the
spender use `transferFrom`. Setting the allowance to zero revokes remaining
permission; it does not undo completed transfers.

Read-only calls normally require no transaction fee. Balance and allowance
changes require signed transactions, with fees paid in Sepolia ETH.

## Ownership and security

There is no administrator or special owner role. The deployer initially holds
all tokens but cannot alter other holders' balances or create more tokens.
Each holder controls transfers of their balance and the allowances they grant.

Transfers reject an insufficient balance or the zero address as recipient.
`transferFrom` also checks the spender's allowance. A transaction that reverts
does not apply its token changes, although a mined transaction can still cost
gas. Successful transfers emit `Transfer` events.

Protect wallet signing keys and grant allowances only to intended spenders.
Identify the token using its network and full contract address; names and
symbols can be reused by unrelated contracts.

The current contract includes no multisig. That is a separate, optional bonus.

## Implementation reference

The dependency is pinned to
[OpenZeppelin ERC20 version 5.4.0](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.4.0/contracts/token/ERC20/ERC20.sol).
Using this dependency does not replace checking the deployment and
demonstrating the documented behavior during evaluation.
