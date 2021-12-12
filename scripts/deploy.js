const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("MyEpicNFT");
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();
  console.log("Contract deployed to:", nftContract.address);

  // call the mint NFT function
  let txn = await nftContract.makeAnEpicNFT();
  // wait for txn to be mined
  console.log("Mining NFT #1 ⛏️");
  await txn.wait();
  console.log("Mined NFT #1 💎");

  let totalNFTsMinted = await nftContract.getTotalNFTsMinted();
  console.log("A total of %d NFTs have been minted!", totalNFTsMinted);
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