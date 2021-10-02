// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "../interfaces/IDataFeed.sol";

contract PublicDataFeed is IDataFeed, Context, AccessControlEnumerable {
  bytes32 public constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");

  mapping(uint256 => bytes32) public override data;

  constructor() {
    _setupRole(PUBLISHER_ROLE, _msgSender());
  }

  function publish(uint256 _key, bytes32 _value) onlyRole(PUBLISHER_ROLE) external {
    data[_key] = _value;
  }
}
