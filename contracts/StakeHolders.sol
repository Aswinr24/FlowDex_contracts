// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract StakeHolders is ReentrancyGuard {
    enum StakeholderType { None, Supplier, Buyer, Arbiter }
    
    struct Buyer {
        address wallet;
        string name;
        string publicDetailsHash; 
        string privateDetailsHash; 
        string documentsHash;
        bool isRegistered;
    }

    struct Supplier {
        address wallet;
        string name;
        string publicDetailsHash; 
        string privateDetailsHash; 
        string documentsHash; 
        bool isRegistered;
    }

    struct Arbiter {
        address wallet;
        string name;
        string detailsHash; 
        bool isRegistered;
    }

    mapping(address => Buyer) public buyers;
    mapping(address => Supplier) public suppliers;
    mapping(address => Arbiter) public arbiters;

    mapping(address => StakeholderType) public walletToStakeholder;

    address[] public buyerAddresses;
    address[] public supplierAddresses;

    event BuyerRegistered(address indexed wallet, StakeholderType indexed stakeholderType, string message);
    event BuyerUpdated(address indexed wallet, StakeholderType indexed stakeholderType, string message);
    event SupplierRegistered(address indexed wallet, StakeholderType indexed stakeholderType, string message);
    event SupplierUpdated(address indexed wallet, StakeholderType indexed stakeholderType, string message);
    event ArbiterRegistered(address indexed wallet, StakeholderType indexed stakeholderType, string message);

    modifier uniqueWalletForStakeholder(address _wallet, StakeholderType _type) {
        require(walletToStakeholder[_wallet] == StakeholderType.None || walletToStakeholder[_wallet] == _type, "Wallet address already registered for another stakeholder type");
        _;
    }

    modifier onlyBuyer() {
        require(walletToStakeholder[msg.sender] == StakeholderType.Buyer, "Only buyers can perform this action");
        _;
    }

    modifier onlySupplier() {
        require(walletToStakeholder[msg.sender] == StakeholderType.Supplier, "Only suppliers can perform this action");
        _;
    }

    function registerBuyer(
        string memory _name,
        string memory _publicDetailsHash,
        string memory _privateDetailsHash,
        string memory _documentsHash
    ) public uniqueWalletForStakeholder(msg.sender, StakeholderType.Buyer) {
        require(!buyers[msg.sender].isRegistered, "Buyer already registered");
        buyers[msg.sender] = Buyer({
            wallet: msg.sender,
            name: _name,
            publicDetailsHash: _publicDetailsHash,
            privateDetailsHash: _privateDetailsHash,
            documentsHash: _documentsHash,
            isRegistered: true
        });
        walletToStakeholder[msg.sender] = StakeholderType.Buyer;
        buyerAddresses.push(msg.sender);
        emit BuyerRegistered(msg.sender, StakeholderType.Buyer, "Buyer Registered");
    }

    function registerSupplier(
        string memory _name,
        string memory _publicDetailsHash,
        string memory _privateDetailsHash,
        string memory _documentsHash
    ) public uniqueWalletForStakeholder(msg.sender, StakeholderType.Supplier) {
        require(!suppliers[msg.sender].isRegistered, "Supplier already registered");
        suppliers[msg.sender] = Supplier({
            wallet: msg.sender,
            name: _name,
            publicDetailsHash: _publicDetailsHash,
            privateDetailsHash: _privateDetailsHash,
            documentsHash: _documentsHash,
            isRegistered: true
        });
        walletToStakeholder[msg.sender] = StakeholderType.Supplier;
        supplierAddresses.push(msg.sender);
        emit SupplierRegistered(msg.sender, StakeholderType.Supplier, "Supplier Registered");
    }

    function registerArbiter(
        string memory _name,
        string memory _detailsHash
    ) public uniqueWalletForStakeholder(msg.sender, StakeholderType.Arbiter) {
        require(!arbiters[msg.sender].isRegistered, "Arbiter already registered");     
        arbiters[msg.sender] = Arbiter({
            wallet: msg.sender,
            name: _name,
            detailsHash: _detailsHash,
            isRegistered: true
        });

        walletToStakeholder[msg.sender] = StakeholderType.Arbiter;
        emit ArbiterRegistered(msg.sender, StakeholderType.Arbiter, "Arbiter Registered");
    }

    function updateBuyer(
        string memory _publicDetailsHash
    ) public onlyBuyer {
        require(buyers[msg.sender].isRegistered, "Buyer not registered");
        buyers[msg.sender].publicDetailsHash = _publicDetailsHash;
        emit BuyerUpdated(msg.sender, StakeholderType.Buyer, "Buyer Updated");
    }

    function updateSupplier(
        string memory _publicDetailsHash
    ) public onlySupplier {
        require(suppliers[msg.sender].isRegistered, "Supplier not registered");
        suppliers[msg.sender].publicDetailsHash = _publicDetailsHash;
        emit SupplierUpdated(msg.sender, StakeholderType.Supplier, "Supplier Updated");
    }

    function getBuyer(address _wallet) public view returns (
        string memory name,
        string memory publicDetailsHash
    ) {
        require(buyers[_wallet].isRegistered, "Buyer not registered");
        Buyer memory buyer = buyers[_wallet];
        return (buyer.name, buyer.publicDetailsHash);
    }

    function getSupplier(address _wallet) public view returns (
        string memory name, 
        string memory publicDetailsHash
    ) {
        require(suppliers[_wallet].isRegistered, "Supplier not registered");
        Supplier memory supplier = suppliers[_wallet];
        return (supplier.name, supplier.publicDetailsHash);
    }

    function getArbiter(address _wallet) public view returns (
        string memory name,
        string memory detailsHash
    ) {
        require(arbiters[_wallet].isRegistered, "Arbiter not registered");
        Arbiter memory arbiter = arbiters[_wallet];
        return (arbiter.name, arbiter.detailsHash);
    }

    function getAllBuyers() public view returns (address[] memory) {
        return buyerAddresses;
    }

    function getAllSuppliers() public view returns (address[] memory) {
        return supplierAddresses;
    }
}