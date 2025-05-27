// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {Rational, RationalLib} from "src/Rational.sol";

contract Vault {
    ERC20 public asset;

    mapping(address => Rational) public shares;
    Rational public totalShares;

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

contract Asset is ERC20 {
    constructor() ERC20("Asset", "ASSET", 18) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract VaultTest is Test {
    Asset asset;
    Vault vault;

    address ALICE = makeAddr("alice");
    address BOB = makeAddr("bob");

    function setUp() public {
        asset = new Asset();
        vault = new Vault(asset);

        asset.mint(ALICE, 1000e18);
        asset.mint(BOB, 1000e18);
    }

    function test_inflationAttack() public {
        // Alice deposits 1 wei and donates 100e18 assets
        vm.startPrank(ALICE);
        asset.approve(address(vault), 1);
        vault.deposit(1);
        asset.transfer(address(vault), 100e18);
        vm.stopPrank();

        // Bob deposits 50e18 assets
        vm.startPrank(BOB);
        asset.approve(address(vault), 50e18);
        vault.deposit(50e18);
        vm.stopPrank();

        // Everyone has the correct amount of assets
        assertEq(vault.balanceOf(ALICE), 100e18 + 1);
        assertEq(vault.balanceOf(BOB), 50e18);
    }
}
