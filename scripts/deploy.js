//File used to compile and deploy our contract ALCHEMY ETHEREUM NETWORK 

const { hexStripZeros } = require("@ethersproject/bytes")

const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT'); //Compile contract and generate necessary files under artifacts
    const nftContract = await nftContractFactory.deploy(); //Local ethereum network is created and our contract is deployed over it
    await nftContract.deployed(); //Wait until block is mint! (real minners are generated)
    console.log("Contract deployed to:", nftContract.address);

    //We call the 'makeAnEpicNFT' function
    let txn = await nftContract.makeAnEpicNFT()
    //Wait for minting
    await txn.wait()
    console.log("Minted NFT #1")

    //Try to mint a second NFT (to see change of ID)
    txn = await nftContract.makeAnEpicNFT()
    await txn.wait()
    console.log("Minted NFT #2")
  };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();