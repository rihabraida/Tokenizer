// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Executes shared-account requests after approval from other owners.
contract MultiSigWallet {
    event Deposit(address indexed sender, uint256 amount);
    event SubmitTransaction(address indexed owner, uint256 indexed txId, address indexed to, uint256 value, bytes data);
    event ConfirmTransaction(address indexed owner, uint256 indexed txId);
    event RevokeConfirmation(address indexed owner, uint256 indexed txId);
    event ExecuteTransaction(address indexed owner, uint256 indexed txId);

    // The submitter cannot count toward these two confirmations.
    uint256 public constant REQUIRED = 2;

    address[] public owners;
    mapping(address => bool) public isOwner;

    struct Transaction {
        address to; // Target contract, such as Token42.
        uint256 value; // ETH in wei; use zero for an ERC-20 transfer.
        bytes data; // Encoded function selector and arguments.
        bool executed;
        uint256 numConfirmations;
        address submitter;
    }

    // Request IDs are array indexes: 0, 1, 2, ...
    Transaction[] public transactions;
    // Track each owner's confirmation separately for every request.
    mapping(uint256 => mapping(address => bool)) public isConfirmed;

    // Modifiers check permissions and request state before running a function.
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not an owner");
        _;
    }

    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint256 _txId) {
        require(!isConfirmed[_txId][msg.sender], "tx already confirmed");
        _;
    }

    modifier notSubmitter(uint256 _txId) {
        require(transactions[_txId].submitter != msg.sender, "cannot confirm your own transaction");
        _;
    }

    // Owners are registered once at deployment and cannot be changed afterward.
    constructor(address[] memory _owners)  {
        require(_owners.length >= 3, "need at least 3 owners so a 2-confirmation quorum excluding the proposer is reachable");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
    }

    // Accept ETH deposits; ERC-20 deposits are recorded by the token contract.
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // Save a request with zero confirmations; nothing is transferred yet.
    function submitTransaction(address _to, uint256 _value, bytes memory _data)
        external onlyOwner returns (uint256 txId)
    {
        txId = transactions.length;
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0,
            submitter: msg.sender
        }));
        emit SubmitTransaction(msg.sender, txId, _to, _value, _data);
    }

    // Each other owner can confirm once; the submitter cannot confirm.
    function confirmTransaction(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
        notConfirmed(_txId)
        notSubmitter(_txId)
    {
        Transaction storage transaction = transactions[_txId];
        transaction.numConfirmations += 1;
        isConfirmed[_txId][msg.sender] = true;
        emit ConfirmTransaction(msg.sender, _txId);
    }

    // Any owner can execute after enough confirmations.
    function executeTransaction(uint256 _txId)
        external onlyOwner txExists(_txId) notExecuted(_txId)
    {
        Transaction storage transaction = transactions[_txId];
        require(transaction.numConfirmations >= REQUIRED, "not enough confirmations");
        // Block repeated execution before making the external call.
        transaction.executed = true;

        // Token42 sees the multisig as msg.sender and spends its token balance.
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        // A failure also rolls back the execution flag.
        require(success, "tx execution failed");
        emit ExecuteTransaction(msg.sender, _txId);
    }

    // Withdraw only the caller's confirmation while the request is pending.
    function revokeConfirmation(uint256 _txId)
        external onlyOwner txExists(_txId) notExecuted(_txId)
    {
        require(isConfirmed[_txId][msg.sender], "tx not confirmed");
        Transaction storage transaction = transactions[_txId];
        transaction.numConfirmations -= 1;
        isConfirmed[_txId][msg.sender] = false;
        emit RevokeConfirmation(msg.sender, _txId);
    }

    // Read-only helpers for inspecting owners and saved requests.
    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(uint256 _txId) external view returns (
        address to, uint256 value, bytes memory data, bool executed, uint256 numConfirmations, address submitter
    ) {
        Transaction storage transaction = transactions[_txId];
        return (transaction.to, transaction.value, transaction.data, transaction.executed, transaction.numConfirmations, transaction.submitter);
    }
}
