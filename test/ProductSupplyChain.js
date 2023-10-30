const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('ProductSupplyChain', function () {
  let owner;
  let otherAddress;
  let productSupplyChain;

  before(async () => {
    [owner, otherAddress] = await ethers.getSigners();

    productSupplyChain = await ethers.deployContract('ProductSupplyChain');
  });

  describe('Deployment', function () {
    it('Should set the owner as the contract deployer', async function () {
      expect(await productSupplyChain.owner()).to.equal(owner.address);
    });
  });

  describe('Create Product', function () {
    it('Should allow the owner to create a product', async function () {
      const tx = await productSupplyChain.createProduct('Product 1', 100);
      await tx.wait();

      const product = await productSupplyChain.products(1);
      expect(product.productId).to.equal(1);
      expect(product.name).to.equal('Product 1');
      expect(product.currentOwner).to.equal(owner.address);
      expect(product.price).to.equal(100);
      expect(product.state).to.equal(0);
    });


   
  });

  describe('Sell Product', function () {
    beforeEach(async () => {
      await productSupplyChain.createProduct('Product 3', 150);
    });

    it('Should allow the owner to sell a product', async function () {
      const tx = await productSupplyChain.sellProduct(1, otherAddress.address);
      await tx.wait();

      const product = await productSupplyChain.products(1);
      expect(product.currentOwner).to.equal(otherAddress.address);
      expect(product.state).to.equal(1);
    });

    it('Should not allow selling a product that is already sold', async function () {
      await expect(productSupplyChain.connect(otherAddress).sellProduct(1, owner.address)).to.be.revertedWith('Product has already been sold');
    });
    
    
    
  });

  describe('Transfer Ownership', function () {
    it('Should allow the owner to transfer ownership', async function () {
      const tx = await productSupplyChain.transferOwnership(otherAddress.address);
      await tx.wait();

      expect(await productSupplyChain.owner()).to.equal(otherAddress.address);
    });


    
  });
});
