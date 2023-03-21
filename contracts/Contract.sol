// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Contract {
    address admin;

    struct Transaction {
        address payable seller;
        address payable buyer;
        uint256 amount;
        uint256 payed_amount;
        bool payed;
        string status;
    }

    constructor(address _admin) {
        admin = _admin;
    }

    mapping(string => Transaction) transactions;


    function create(string memory unique, address payable _buyer, address payable _seller,  uint256 _amount) public payable {
        Transaction storage transaction = transactions[unique];
        require(transaction.buyer == address(0) && transaction.seller == address(0), "transaction not unique");

        transaction.amount = _amount;
        transaction.seller = _seller;
        transaction.buyer = _buyer;
        transaction.payed = false;
        transaction.status = 'wait_payment';

    }

    function getTransaction(string memory unique) public view returns(Transaction memory) {
        return transactions[unique];
    }

    function pay(string memory unique) public payable {
        Transaction storage transaction = transactions[unique];
        require(
            transaction.buyer != address(0) && transaction.seller != address(0),
            "Transaction not found"
        );
        require(transaction.buyer == msg.sender, "Auth failed");
        transaction.payed_amount += msg.value;

        if (transaction.payed_amount >= transaction.amount) {
            transaction.payed = true;
            transaction.status = 'payed';
        }
    }

    function confirm(string memory unique) public payable {
        Transaction storage transaction = transactions[unique];
        require(transaction.buyer == msg.sender || admin == msg.sender, "Forbidden");
        require(keccak256(bytes(transaction.status)) == keccak256(bytes("payed")), "Forbidden");

        transaction.status = "sent_to_seller";
        transaction.seller.transfer(transaction.amount);
    }

    function cancel(string memory unique) public payable {
        Transaction storage transaction = transactions[unique];
        require(transaction.seller == msg.sender || admin == msg.sender, "Forbidden");
        require(keccak256(bytes(transaction.status)) == keccak256(bytes("payed")), "Forbidden");

        transaction.status = "sent_to_buyer";
        transaction.buyer.transfer(transaction.amount);
    }
}
