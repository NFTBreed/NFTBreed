async function main() {
  const NFTBreed = await ethers.getContractFactory("NFTBreed");
  const AuctionRepository = await ethers.getContractFactory("AuctionRepository");

  // Start deployment, returning a promise that resolves to a contract object
  const NFTBreedObject = await NFTBreed.deploy();
  const AuctionRepositoryObject = await AuctionRepository.deploy(NFTBreedObject.address);
  
  console.log("NFTBreed Contract deployed to address:", NFTBreedObject.address);
  console.log("AuctionRepository Contract deployed to address:", AuctionRepositoryObject.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
