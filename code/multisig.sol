// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint256 amount);
    event SubmitTransaction(address indexed owner, uint256 indexed txId, address indexed to, uint256 value, bytes data);
    event ConfirmTransaction(address indexed owner, uint256 indexed txId);
    event RevokeConfirmation(address indexed owner, uint256 indexed txId);
    event ExecuteTransaction(address indexed owner, uint256 indexed txId);

    uint256 public constant REQUIRED = 2;

    address[] public owners;
    mapping(address => bool) public isOwner;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
        address submitter;
    }

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public isConfirmed;

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

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

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

    function executeTransaction(uint256 _txId)
        external onlyOwner txExists(_txId) notExecuted(_txId)
    {
        Transaction storage transaction = transactions[_txId];
        require(transaction.numConfirmations >= REQUIRED, "not enough confirmations");
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "tx execution failed");
        emit ExecuteTransaction(msg.sender, _txId);
    }

    function revokeConfirmation(uint256 _txId)
        external onlyOwner txExists(_txId) notExecuted(_txId)
    {
        require(isConfirmed[_txId][msg.sender], "tx not confirmed");
        Transaction storage transaction = transactions[_txId];
        transaction.numConfirmations -= 1;
        isConfirmed[_txId][msg.sender] = false;
        emit RevokeConfirmation(msg.sender, _txId);
    }

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