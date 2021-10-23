// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    mapping (address => bool) private _owners;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AddOwner(address indexed newOwner, bool indexed result);
    event RemoveOwner(address indexed newOwner, bool indexed result);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        _owners[msgSender] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owners[_msgSender()], "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
   
    function addOwner(address _newOwner) public virtual onlyOwner {
        require(_newOwner != address(0), "Ownable: Owner is the zero address");
        _owners[_newOwner] = true;
        emit AddOwner(_newOwner, true);
    }
   
    function removeOwner(address _newOwner) public virtual onlyOwner {
        address msgSender = _msgSender();
        require(_newOwner != address(0), "Ownable: Owner is the zero address");
        require(_newOwner != msgSender, "You can't remove yourself");
        _owners[_newOwner] = false;
        emit RemoveOwner(_newOwner, false);
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
   
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
contract NFTBreed is ERC721URIStorage, Ownable {
   
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    struct Genome {
        uint256 attack;
        uint256 defense;
        uint256 speed;
        uint256 affection;
        uint256 instinct;
        uint256 brave;
        uint256 smart;
        uint256 health;
    }
    
    mapping(uint256 => Genome) private creatureGenome;
    address payable private fundAddress;
    uint256 private minBuy = 0;
    
    event NFTMinted(address owner, uint newItemId);
 
    constructor() ERC721("NFTBreed", "NFTBD") {}
 
    /*function mint(address _to, string calldata _uri) external onlyOwner returns (uint256) {
    
    _tokenIds.increment();
    uint256 _tokenId = _tokenIds.current();
    
    super._mint(_to, _tokenId);
    super._setTokenURI(_tokenId, _uri);
    
    return _tokenId;
    }*/
    
    function mintCreature(
        uint256 attack, uint256 defense, uint256 speed, uint256 affection,
        uint256 instinct, uint256 brave, uint256 smart, uint256 health,
        string memory tokenURI) external payable returns (uint256) {
            
        uint256 bnbAmountSent = msg.value;
        address recipient = _msgSender();
        
        require(bnbAmountSent > minBuy, "Insufficient amount");
            
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        
        require(createGenome(attack, defense, speed, affection, instinct, brave, smart, health, newItemId));
        mintNFT(recipient, tokenURI, newItemId);
        
        fundAddress.transfer(bnbAmountSent);
        
        emit NFTMinted(recipient, newItemId);
        
        return newItemId;
    }
 
    function mintNFT(address _recipient, string memory _tokenURI, uint256 _newItemId) private returns (bool) {
        super._mint(_recipient, _newItemId);
        super._setTokenURI(_newItemId, _tokenURI);
        return true;
    }
    
    function createGenome(
        uint256 _attack, uint256 _defense,
        uint256 _speed, uint256 _affection,
        uint256 _instinct, uint256 _brave,
        uint256 _smart, uint256 _health,
         uint256 _nftID) private returns(bool) {
             
        Genome memory newGenome;
        newGenome.attack = _attack;
        newGenome.defense = _defense;
        newGenome.speed = _speed;
        newGenome.affection = _affection;
        newGenome.instinct = _instinct;
        newGenome.brave = _brave;
        newGenome.smart = _smart;
        newGenome.health = _health;
        
        creatureGenome[_nftID] = newGenome;
        
        return true;
    }
    
    function setDetails(address payable _fundAddress, uint256 _minBuy) external onlyOwner() {
        fundAddress = _fundAddress;
        minBuy = _minBuy;
    }
    
    function setFundAddress(address payable _fundAddress) external onlyOwner() {
        fundAddress = _fundAddress;
    }
    
    function getFundAddress() external view onlyOwner() returns(address payable) {
        return fundAddress;
    }
    
    function setMinBuy(uint256 _minBuy) external onlyOwner() {
        minBuy = _minBuy;
    }
    
    function getMinBuy() external view onlyOwner() returns(uint256) {
        return minBuy;
    }
    
    function routerCustomToken(address _customAddress) external onlyOwner() {
        uint256 tokens = IERC20(_customAddress).balanceOf(address(this));
        require(tokens > 0, "Token must be greater than zero");
        IERC20(_customAddress).transfer(msg.sender, tokens);
    }
    
    function autoBuyBack(uint256 _value) external onlyOwner() {
        payable(owner()).transfer(_value); 
    }
    
    function getGenome(uint256 _nftID) external view returns(
        uint256 attack,
        uint256 defense,
        uint256 speed,
        uint256 affection,
        uint256 instinct,
        uint256 brave,
        uint256 smart,
        uint256 health
        ) {
            
        Genome memory genome = creatureGenome[_nftID];

        return (
            genome.attack,
            genome.defense,
            genome.speed,
            genome.affection,
            genome.instinct,
            genome.brave,
            genome.smart,
            genome.health
        );
    }

 
}