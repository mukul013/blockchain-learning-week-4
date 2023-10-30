// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ExternalRegistry {
    function verifyCondition(address _productOwner) external view returns (bool);
}

contract ProductSupplyChain is Ownable(msg.sender) {

    enum ProductState { Created, Sold }
    
    struct Product {
        uint productId;
        string name;
        address currentOwner;
        uint price;
        ProductState state;
    }

    mapping(uint => Product) public products;
    uint public productCount = 0;

    event ProductCreated(uint indexed productId, string name, address owner, uint price);
    event ProductSold(uint indexed productId, address from, address to, uint price);
    event OwnerChanged(address indexed previousOwner, address indexed newOwner);

    modifier onlyProductOwner(uint _productId) {
        require(products[_productId].currentOwner == msg.sender, "Only the product owner can call this function");
        _;
    }

    modifier productExists(uint _productId) {
        require(_productId <= productCount, "Product with this ID does not exist");
        _;
    }

    function createProduct(string memory _name, uint _price) public onlyOwner {
        require(msg.sender == owner(), "Only the owner can create a product");
        productCount++;
        products[productCount] = Product(productCount, _name, owner(), _price, ProductState.Created);
        emit ProductCreated(productCount, _name, owner(), _price);
    }

    function sellProduct(uint _productId, address _newOwner) external onlyProductOwner(_productId) productExists(_productId) {
        require(_newOwner != address(0), "Invalid new owner address");
        require(products[_productId].state == ProductState.Created, "Product has already been sold");

        // You can add an external contract interaction
        // if you want to verify a condition using an external contract.
        // require(externalRegistry.verifyCondition(msg.sender), "Condition not met");

        products[_productId].state = ProductState.Sold;
        products[_productId].currentOwner = _newOwner;
        emit ProductSold(_productId, msg.sender, _newOwner, products[_productId].price);
    }

    function changeOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid new owner address");
        address previousOwner = owner();
        transferOwnership(_newOwner);
        emit OwnerChanged(previousOwner, _newOwner);
    }
}
