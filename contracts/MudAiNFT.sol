// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import 'erc721a/contracts/extensions/ERC721AQueryable.sol';
import 'erc721a/contracts/ERC721A.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract MudAiNFT is ERC721AQueryable, Ownable, ReentrancyGuard {

  using Strings for uint256;

  bytes32 public merkleRoot;
  mapping(address => bool) public whitelistClaimed;

  string public baseURI;
  string public baseExtension = '.json';
  string public notRevealedUri;
  
  uint256 public whitelistSaleCost = 0.06 ether;
  uint256 public publicSaleCost = 0.08 ether;
  uint256 public maxSupply = 3333;
  uint256 public maxMintPerTx = 3;
  uint256 public maxMintPerAddress = 3;
//TODO:check true or false
  bool public paused = false;
  bool public onlyWhitelisted = true;
  bool public revealed = false;

  constructor(
    string memory _tokenName,
    string memory _tokenSymbol,
    string memory _notRevealedUri
  ) ERC721A(_tokenName, _tokenSymbol) {
    setNotRevealedUri(_notRevealedUri);
  }

  modifier mintCompliance(uint256 _mintAmount) {
    //TODO:Check if if statement is ignored when owner
    if(msg.sender != owner()){
      uint256 ownerMintedCount = balanceOf(msg.sender);
      require(ownerMintedCount + _mintAmount <= maxMintPerAddress, "Max NFT per address exceeded!");
    }
    require(_mintAmount > 0 && _mintAmount <= maxMintPerTx, 'Invalid mint amount!');
    require(totalSupply() + _mintAmount <= maxSupply, 'Max supply exceeded!');
    _;
  }

  modifier mintPriceCompliance(uint256 _mintAmount) {
    uint256 cost = onlyWhitelisted ? whitelistSaleCost : publicSaleCost;
    require(msg.value >= cost * _mintAmount, 'Insufficient funds!');
    _;
  }

  function whitelistMint(uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
    require(!paused, 'The contract is paused!');
    require(onlyWhitelisted, 'The whitelist sale is not enabled!');
    // require(!whitelistClaimed[_msgSender()], 'Address already claimed!');
    bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
    require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'Invalid proof!');

    //TODO:フロント完成後最後確認
    // whitelistClaimed[_msgSender()] = true;
    _safeMint(_msgSender(), _mintAmount);
  }

  function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
    require(!paused, 'The contract is paused!');
    require(!onlyWhitelisted, 'Public sale is currently not going on!');

    _safeMint(_msgSender(), _mintAmount);
  }
  
  function mintForAddress(uint256 _mintAmount, address _receiver) public mintCompliance(_mintAmount) onlyOwner {
    _safeMint(_receiver, _mintAmount);
  }

  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');

    if (revealed == false) {
      return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), baseExtension))
        : '';
  }

  function setRevealed(bool _state) public onlyOwner {
    revealed = _state;
  }

  function setWhitelistSaleCost(uint256 _cost) public onlyOwner {
    whitelistSaleCost = _cost;
  }

  function setPublicSaleCost(uint256 _cost) public onlyOwner {
    publicSaleCost = _cost;
  }

  function setMaxMintPerTx(uint256 _maxMintPerTx) public onlyOwner {
    maxMintPerTx = _maxMintPerTx;
  }

  function setMaxMintPerAddress(uint256 _limit) public onlyOwner {
    maxMintPerAddress = _limit;
  }

  function setNotRevealedUri(string memory _notRevealedUri) public onlyOwner {
    notRevealedUri = _notRevealedUri;
  }

  function setBaseTokenURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _baseExtension) public onlyOwner {
    baseExtension = _baseExtension;
  }

  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }

  function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
    merkleRoot = _merkleRoot;
  }

  function setOnlyWhitelisted(bool _state) public onlyOwner {
    onlyWhitelisted = _state;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function withdraw() public onlyOwner nonReentrant {
    (bool os, ) = payable(owner()).call{value: address(this).balance}('');
    require(os);
  }
}