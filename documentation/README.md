# Mandatory — Token42

## Implementation

[Token42](../code/Tokenizer.sol) inherits OpenZeppelin's `ERC20` implementation.
Its constructor sets the name to **42 Token**, the symbol to **42TK**, and mints
the initial supply to `msg.sender`: the account deploying it through Remix.

The token contract keeps the balances of all addresses, including the multisig.
A wallet manages signing keys; an address's tokens are recorded in Token42.

## Supply and units

The supply is **1,000,000 tokens**. There is no public function to mint more or
burn tokens, and normal transfers do not change the total supply.

The token uses 18 decimals. Direct contract calls use integer base units:

| Tokens | Base units |
|---|---|
| 1 | `1000000000000000000` |
| 5 | `5000000000000000000` |
| 10 | `10000000000000000000` |

## Functions

| Function | Purpose |
|---|---|
| `name()`, `symbol()`, `decimals()` | Read token information |
| `totalSupply()` | Read supply in base units: `1000000000000000000000000` |
| `balanceOf(account)` | Read a wallet or contract address's token balance |
| `transfer(to, amount)` | Transfer tokens from the caller's balance |
| `approve(spender, amount)` | Set another address's spending allowance |
| `allowance(owner, spender)` | Read the remaining spending allowance |
| `transferFrom(from, to, amount)` | Transfer using the caller's allowance |

These functions are inherited. `INITIAL_SUPPLY()` is our own getter and returns
`1000000` whole tokens. `_mint` is internal, so it cannot be called from Remix.

## Demonstration

Connect MetaMask to Sepolia. Load **Token42**, not MultiSigWallet, at
[`0x8Af0e1120c5E9ba868C4a1d8b5e07D1900eaA12E`](https://sepolia.etherscan.io/address/0x8Af0e1120c5E9ba868C4a1d8b5e07D1900eaA12E).
Use A as an account holding tokens and B as another account you control.

1. Read the name, symbol, decimals, total supply and both balances.
2. From A, call `transfer(B, 10000000000000000000)`: B receives 10 tokens.
3. From A, call `approve(B, 5000000000000000000)`: B may spend 5 of A's tokens.
   Check `allowance(A, B)`. Approval itself moves no tokens.
4. Switch to B and call `transferFrom(A, B, 2000000000000000000)`.
   B receives 2 tokens; the remaining allowance is 3 tokens.
5. Switch to A and call `approve(B, 0)` to revoke the remaining allowance.

Replace A and B with full wallet addresses. Keep Remix's separate **ETH Value
at 0**. Each account needs Sepolia ETH for the transactions it signs; ordinary
read calls do not require a signed transaction.

## Security checks

| Attempt | Expected result |
|---|---|
| Transfer more than the sender holds | Reverts: insufficient balance |
| Transfer to the zero address | Reverts: invalid recipient |
| `transferFrom` without sufficient allowance | Reverts: insufficient allowance |

A rejected action leaves token state unchanged. Cancel expected failures during
gas estimation; a failed transaction that is actually mined can still cost gas.
The deployer has no administrator privileges over other holders' balances.

Use Etherscan's **Token Transfers (ERC-20)** tab to inspect sender, recipient and
amount. Use the network and full contract address to identify the token: two
deployments with the same name still have separate balances.
