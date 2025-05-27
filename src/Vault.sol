// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {Rational, RationalLib} from "./Rational.sol";

contract Vault {
    ERC20 public asset;

    mapping(address => Rational) internal shares;
    Rational internal totalShares;

    constructor(ERC20 _asset) {
        asset = _asset;
    }

    function deposit(uint128 amount) external {
        Rational _shares = _convertToShares(amount);

        shares[msg.sender] = shares[msg.sender] + _shares;
        totalShares = totalShares + _shares;

        asset.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint128 amount) external {
        Rational _shares = _convertToShares(amount);

        shares[msg.sender] = shares[msg.sender] - _shares;
        totalShares = totalShares - _shares;

        asset.transfer(msg.sender, amount);
    }

    function balanceOf(address account) external view returns (uint128) {
        Rational assets = shares[account] / totalShares * _totalAssets();
        return RationalLib.toUint128(assets);
    }

    function _convertToShares(uint128 amount) internal view returns (Rational) {
        Rational assets = RationalLib.fromUint128(amount);
        return totalShares == RationalLib.ZERO ? assets : assets / _totalAssets() * totalShares;
    }

    function _totalAssets() internal view returns (Rational) {
        return RationalLib.fromUint128(uint128(asset.balanceOf(address(this))));
    }
}
