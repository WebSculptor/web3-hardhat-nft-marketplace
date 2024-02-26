// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract VideoNFTMarketplace is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct VideoNFT {
        uint256 id;
        address creator;
        string videoUrl;
        uint256 price;
        bool forSale;
    }

    mapping(uint256 => VideoNFT) private _videoNFTs;
    mapping(address => bool) private _authorizedMinters;

    constructor() ERC721("VideoNFT", "VNFT") {}

    modifier onlyMinter() {
        require(
            _authorizedMinters[msg.sender],
            "Caller is not an authorized minter"
        );
        _;
    }

    function addMinter(address _minter) external {
        require(_minter != address(0), "Invalid minter address");
        _authorizedMinters[_minter] = true;
    }

    function removeMinter(address _minter) external {
        require(_minter != address(0), "Invalid minter address");
        _authorizedMinters[_minter] = false;
    }

    function mintNFT(
        string memory _videoUrl,
        uint256 _price
    ) external onlyMinter {
        _tokenIds.increment();
        uint256 newNFTId = _tokenIds.current();
        _mint(msg.sender, newNFTId);

        VideoNFT memory newNFT = VideoNFT({
            id: newNFTId,
            creator: msg.sender,
            videoUrl: _videoUrl,
            price: _price,
            forSale: false
        });

        _videoNFTs[newNFTId] = newNFT;
    }

    function buyNFT(uint256 _tokenId) external payable {
        VideoNFT storage nft = _videoNFTs[_tokenId];
        require(nft.forSale == true, "NFT is not for sale");
        require(msg.value >= nft.price, "Insufficient funds");

        address payable seller = payable(ownerOf(_tokenId));
        seller.transfer(msg.value);

        _transfer(seller, msg.sender, _tokenId);
        nft.forSale = false;
    }

    function sellNFT(uint256 _tokenId, uint256 _price) external {
        require(
            ownerOf(_tokenId) == msg.sender,
            "You are not the owner of this NFT"
        );

        VideoNFT storage nft = _videoNFTs[_tokenId];
        require(!nft.forSale, "NFT is already for sale");

        nft.price = _price;
        nft.forSale = true;
    }

    function getNFT(
        uint256 _tokenId
    ) external view returns (uint256, address, string memory, uint256, bool) {
        VideoNFT memory nft = _videoNFTs[_tokenId];
        return (nft.id, nft.creator, nft.videoUrl, nft.price, nft.forSale);
    }
}
