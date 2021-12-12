const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("MyEpicNFT");
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();
  console.log("Contract deployed to:", nftContract.address);

  // call the mint function
  let txn = await nftContract.makeAnEpicNFT();
  // wait for txn to be mined
  console.log("Mining NFT ⛏️");
  await txn.wait();
  console.log("Mined NFT 💎");

  // mint another nft
  // txn = await nftContract.makeAnEpicNFT();
  // // wait for it to be mined
  // console.log("Minting NFT...");
  // await txn.wait();
  // console.log("Minted NFT #2");

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