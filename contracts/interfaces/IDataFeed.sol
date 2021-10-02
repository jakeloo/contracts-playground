// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IDataFeed {
  function data(uint256 key) external view returns (bytes32 value);
}
