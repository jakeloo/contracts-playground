// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "../interfaces/IDataFeed.sol";

contract LeasableDataFeed is IDataFeed, Context, AccessControlEnumerable {
  bytes32 public constant TREASURER_ROLE = keccak256("TREASURER_ROLE");
  bytes32 public constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");

  uint256 public leasePricePerDay = 0.001 ether;

  mapping(address => uint256) private _leaseExpiration;
  mapping(uint256 => bytes32) private _data;

  constructor() {
    _setupRole(TREASURER_ROLE, _msgSender());
    _setupRole(PUBLISHER_ROLE, _msgSender());
  }

  function data(uint256 _key) external override view returns (bytes32) {
    require(block.timestamp < _leaseExpiration[_msgSender()], "does not have a valid lease");
    return _data[_key];
  }

  function publish(uint256 _key, bytes32 _value) onlyRole(PUBLISHER_ROLE) external {
    _data[_key] = _value;
  }

  function lease(address to, uint256 numberOfDays) payable external {
    require(msg.value == (numberOfDays * leasePricePerDay), "msg.value != total price");

    uint256 startAt = block.timestamp;
    uint256 expireAt = _leaseExpiration[to];

    // if expiration is in the future, we'll update the expiration instead
    if (expireAt > startAt) {
      _leaseExpiration[to] = expireAt + (numberOfDays * 1 days);
    } else {
      _leaseExpiration[to] = startAt + (numberOfDays * 1 days);
    }
  }

  function withdraw() onlyRole(TREASURER_ROLE) external {
    // get the amount of Ether stored in this contract
    uint amount = address(this).balance;
    (bool success, ) = _msgSender().call{value: amount}("");
    require(success, "Failed to send Ether");
  }
}
