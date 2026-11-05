# Tokenizer — 42 Token

An educational ERC-20 token for the 42 Tokenizer project. It demonstrates how
to create a fixed supply, transfer tokens, and authorize another address to
spend a limited amount. The token does not represent a claim on money or goods.

## Token

| Property | Value |
| --- | --- |
| Name | 42 Token |
| Symbol / ticker | 42TK |
| Contract name | Token42 |
| Standard | ERC-20 |
| Initial supply | 1,000,000 42TK |
| Decimals | 18 |
| Initial recipient | The address deploying the contract |
| Network | Ethereum Sepolia testnet |

## Technical choices

- **Ethereum:** supports programmable tokens and the ERC-20 standard, with
  compatible wallets and blockchain explorers. The subject also permits other
  platforms, such as BNB Smart Chain; this project uses Ethereum's ecosystem.
- **Sepolia:** lets us demonstrate deployment and transfers using test ETH for
  fees. No mainnet deployment or real-money purchase is required. See
  [Ethereum's network documentation](https://ethereum.org/developers/docs/networks/).
- **Solidity:** targets the Ethereum Virtual Machine and supports the contract
  inheritance used by this token.
- **OpenZeppelin Contracts 5.4.0:** supplies the ERC-20 implementation instead of
  rewriting balance, transfer, and allowance logic. The import pins the version.
- **Remix:** provides compilation, a simulated blockchain, and wallet-connected
  deployment from a browser, suitable for demonstrating the project.
- **Fixed supply:** creates all tokens during construction and gives the
  deployed contract no public way to mint additional tokens.

## Repository

| Path | Contents |
| --- | --- |
| [code/Tokenizer.sol](code/Tokenizer.sol) | Token contract source |
| `deployment/` | Deployment setup, instructions, and network records; pending |
| [documentation/token-design.md](documentation/token-design.md) | Purpose, behavior, units, and permissions |
| `tokenizer.pdf` | Project subject |

## Existing deployment — details pending

The token has been deployed and transfers have been performed on Sepolia.
Before submission, record the full contract address, explorer link, and
deployment transaction here. The repository source must also be checked against
that deployment; this match has not yet been established.

Record the actual compiler version, optimizer settings, and EVM target in
`deployment/`. The Solidity pragma specifies compatible compiler versions, not
the exact version used for an existing deployment.

For evaluation, prepare a repeatable deployment and demonstrate token actions.
A new deployment creates a separate token instance at a new address, even when
the name and symbol are identical.

Never commit private keys, seed phrases, passwords, or secret API keys.

## Remaining work

- Record and check the existing Sepolia deployment.
- Add reproducible deployment instructions and the required setup files.
- Add usage instructions and a demonstration checklist.
- Commit the completed files to the submission repository.
- Consider the optional multisig bonus after completing the mandatory part.
