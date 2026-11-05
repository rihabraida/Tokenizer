// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.4.0/token/ERC20/ERC20.sol";

/**
 * @title Token42
 * @notice Fixed-supply ERC-20 token for the 42 Tokenizer project.
 * @dev The full supply is assigned to the deployer.
 */
contract Token42 is ERC20 {
    // Initial supply expressed in whole tokens.
    uint256 public constant INITIAL_SUPPLY = 1_000_000;

    constructor() ERC20("42 Token", "42TK") {
        // Convert whole tokens into ERC-20 base units.
        _mint(
            msg.sender,
            INITIAL_SUPPLY * 10 ** decimals()
        );
    }
}
