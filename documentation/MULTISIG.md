# Bonus — MultiSigWallet

## How it fits with Token42

[MultiSigWallet](../code/multisig.sol) is a separate contract that can hold 42TK
at its address. It creates no tokens and has no special privileges over Token42.
Its approval rules apply to tokens deposited at its own address.

Token42 records the balances. When a request is executed, the multisig calls
Token42's `transfer` function, which moves tokens from the multisig's balance.

| Contract | Sepolia address |
|---|---|
| Token42 | `0x8Af0e1120c5E9ba868C4a1d8b5e07D1900eaA12E` |
| MultiSigWallet | `0x4bb0EF8b7a588DA016B563be3961d9b11897D780` |

## Rules and choices

- At deployment, provide at least three distinct, nonzero owner addresses.
  `getOwners()` returns the deployed list; its order does not affect permissions.
- `REQUIRED` is fixed at **2**. A request needs two confirmations from owners
  **other than its submitter**. With A, B and C, if A submits, B and C confirm.
- Submission starts with zero confirmations. Execution is a separate action
  that any owner may perform after the threshold is reached.
- Owners cannot be changed through this contract. Only owners may submit,
  confirm, revoke or execute; anyone may read the requests.
- This is a generic multisig: each request specifies its target and encoded
  function call. For this project, the target is Token42.

## Functions

| Function | Purpose |
|---|---|
| `submitTransaction(to, value, data)` | Save a request; no tokens move yet |
| `confirmTransaction(id)` | Add the caller's confirmation |
| `revokeConfirmation(id)` | Withdraw the caller's confirmation before execution |
| `executeTransaction(id)` | Perform the approved call once |
| `getOwners()` / `REQUIRED()` | Read owners and confirmation threshold |
| `getTransactionCount()` | Read how many requests have been saved |
| `getTransaction(id)` | Read target, ETH value, data, execution flag, count and submitter |
| `isConfirmed(id, owner)` | Check whether an owner confirmed a request |

In `submitTransaction`, **to** is the Token42 contract, **value** is ETH in wei
(`0` for our token transfer), and **data** encodes the recipient and token amount.
The contract also accepts ETH through `receive()`. ETH value is separate from
the gas paid by the account sending each transaction.

## Demonstration: send 10 tokens

Use A, B and C from `getOwners()`. Give each account Sepolia ETH for its calls.
Keep Remix's separate **ETH Value at 0**.

1. In **Token42**, from an account holding tokens, call `transfer` with the
   multisig address as recipient and `10000000000000000000` as amount.
   Check **Token42's** `balanceOf(multisigAddress)` to read the deposited balance.
2. In **MultiSigWallet**, read `getTransactionCount()` before submitting; use
   that number as the new request ID, N. A calls `submitTransaction` with:
   - **to:** `0x8Af0e1120c5E9ba868C4a1d8b5e07D1900eaA12E`
   - **value:** `0`
   - **data:** the encoded call below, sending 10 tokens to account B at
     `0xC2704Dd78a3cff8c61BffC5f7A86Bf3f699224AB`.

```text
0xa9059cbb000000000000000000000000c2704dd78a3cff8c61bffc5f7a86bf3f699224ab0000000000000000000000000000000000000000000000008ac7230489e80000
```

3. B calls `confirmTransaction(N)`. To test revocation, B calls
   `revokeConfirmation(N)` and checks the count drops to zero, then confirms again.
4. C calls `confirmTransaction(N)`. Check `getTransaction(N)` shows two confirmations.
5. Any owner calls `executeTransaction(N)`. Check `executed` is true and use
   **Token42's** `balanceOf` to check the multisig lost 10 tokens and B gained 10.

The encoded data fixes the recipient and amount; generate new data to change
either. Funding once is enough for several requests while the balance lasts.

## Security checks

| Attempt | Expected rejection |
|---|---|
| Non-owner calls a write function | `not an owner` |
| Submitter confirms their own request | `cannot confirm your own transaction` |
| Same owner confirms twice | `tx already confirmed` |
| Execute with fewer than two confirmations | `not enough confirmations` |
| Execute the same request again | `tx already executed` |
| Execute a Token42 transfer without enough tokens | `tx execution failed` |

Failed execution rolls back the execution flag; earlier confirmations remain.
These are manual checks to rehearse, not a claim that every check was performed.
Owners should inspect the target, ETH value and decoded instructions before
confirming. With three owners, losing a required signing key can block spending.
