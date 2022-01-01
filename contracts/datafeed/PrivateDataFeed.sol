// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./IDataFeed.sol";

contract PrivateDataFeed is IDataFeed, Context, AccessControlEnumerable {
  bytes32 public constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");
  bytes32 public constant SUBSCRIBER_ROLE = keccak256("SUBSCRIBER_ROLE");

  mapping(uint256 => bytes32) private _data;

  constructor() {
    _setupRole(SUBSCRIBER_ROLE, _msgSender());
    _setupRole(PUBLISHER_ROLE, _msgSender());
  }

  function data(uint256 _key) onlyRole(SUBSCRIBER_ROLE) external view override returns (bytes32) {
    return _data[_key];
  }

  function publish(uint256 _key, bytes32 _value) onlyRole(PUBLISHER_ROLE) external {
    _data[_key] = _value;
  }
}
