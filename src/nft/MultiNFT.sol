// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @notice wrap erc721 to a non-transferrable nft; requires multisig to unwrap.
 *
 * @dev approvals can be converted to use signature to support gasless :)
 */
contract MultiNFT is ERC721 {
  error NotEnoughApprovals();
  error NonTransferrable();

  struct AssetInfo {
    address assetContract;
    uint256 tokenId;
    address[] signers;
  }

  /* token id => asset */
  mapping(uint256 => AssetInfo) public assets;
  /* token id => signers => approvals */
  mapping(uint256 => mapping(address => bool)) public approvals;

  uint256 private nextTokenId;

  constructor() ERC721("MultiNFT", "MNFT") {}

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    AssetInfo memory info = assets[tokenId];
    return ERC721(info.assetContract).tokenURI(info.tokenId);
  }

  function wrap(AssetInfo memory info) external {
    IERC721(info.assetContract).transferFrom(msg.sender, address(this), info.tokenId);

    assets[nextTokenId] = info;
    _mint(msg.sender, nextTokenId);
    nextTokenId += 1;
  }

  function unwrap(uint256 tokenId) external {
    require(_exists(tokenId), "not exists");
    require(ownerOf(tokenId) == msg.sender, "not owner");

    AssetInfo memory info = assets[tokenId];

    for (uint256 i = 0; i < info.signers.length; i++) {
      address signer = info.signers[i];
      if (!approvals[tokenId][signer]) {
        revert NotEnoughApprovals();
      }
    }

    _burn(tokenId);

    delete assets[tokenId];

    IERC721(info.assetContract).transferFrom(address(this), msg.sender, info.tokenId);
  }

  function submitApproval(uint256 tokenId) external {
    approvals[tokenId][msg.sender] = true;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override {
    // support minting and burning
    if (from != address(0) && to != address(0)) {
        revert NonTransferrable();
    }
  }
}
