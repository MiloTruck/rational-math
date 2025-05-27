// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {Rational, RationalMath} from "./Rational.sol";

contract Vault {
    using RationalMath for Rational;

    ERC20 public asset;

    mapping(address => Rational) internal shares;
    Rational internal totalShares;

    constructor(ERC20 _asset) {
        asset = _asset;
    }

    function deposit(uint256 amount) external {
        Rational memory _shares = _convertToShares(amount);

        shares[msg.sender] = shares[msg.sender].add(_shares);
        totalShares = totalShares.add(_shares);

        asset.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) external {
        Rational memory _shares = _convertToShares(amount);

        shares[msg.sender] = shares[msg.sender].sub(_shares);
        totalShares = totalShares.sub(_shares);

        asset.transfer(msg.sender, amount);
    }

    function balanceOf(address account) external view returns (uint256) {
        Rational memory totalAssets = RationalMath.fromU256(asset.balanceOf(address(this)));
        Rational memory assets = shares[account].div(totalShares).mul(totalAssets);

        return assets.toU256();
    }

    function _convertToShares(uint256 amount) internal view returns (Rational memory) {
        if (totalShares.numerator == 0) {
            return RationalMath.fromU256(amount);
        }

        Rational memory assets = RationalMath.fromU256(amount);
        Rational memory totalAssets = RationalMath.fromU256(asset.balanceOf(address(this)));
        Rational memory _shares = assets.div(totalAssets).mul(totalShares);

        return _shares;
    }
}
