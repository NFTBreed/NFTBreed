async function main() {
  const IterableMapping = await ethers.getContractFactory("IterableMapping");

    const IterableMappingObject = await IterableMapping.deploy();

  const NFTBreed = await ethers.getContractFactory("NFTBreed", {
      libraries: {
          IterableMapping: IterableMappingObject.address,
      },
  });
  //const AuctionRepository = await ethers.getContractFactory("AuctionRepository");

  // Start deployment, returning a promise that resolves to a contract object
    /*
        _secretCode = 16
        _fundAddress = 0x2925194bCd12620e09c5A072b9e33a03541B44a4
     */
  const NFTBreedObject = await NFTBreed.deploy();
  //const NFTBreedObject = await NFTBreed.deploy(16, "0x2925194bCd12620e09c5A072b9e33a03541B44a4");
  //const AuctionRepositoryObject = await AuctionRepository.deploy(NFTBreedObject.address);
  
  console.log("NFTBreed Contract deployed to address:", NFTBreedObject.address);
  //console.log("AuctionRepository Contract deployed to address:", AuctionRepositoryObject.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

/*
    NFT : 0xf1235d98034576e5Af4342E7131924F210dEE2d9
    Auction : 0x9465F8dbd513372C0a7d24EA495B4b29B63A4341
 */