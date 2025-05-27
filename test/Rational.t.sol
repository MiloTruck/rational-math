// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {LibString} from "lib/solmate/src/utils/LibString.sol";
import {Rational, RationalLib, fromRational, toRational, gcd, cmp, eq, lt, gt, neq, lte, gte} from "src/Rational.sol";

contract RationalTest is Test {
    using LibString for uint256;

    function test_add(uint256 a, uint256 b, uint256 c, uint256 d) public {
        // Bounds
        a = bound(a, 0, type(uint128).max);
        b = bound(b, 1, type(uint128).max);
        c = bound(c, 0, type(uint128).max);
        d = bound(d, 1, type(uint128).max);

        // Skip if ad + cb > uint256.max
        if (c != 0 && a * d > type(uint256).max / (c * b)) return;

        // Skip if numerator or denominator overflows uint128
        if (resultOverflowsUint128(a * d + c * b, b * d)) return;

        // Compute z = x + y
        Rational x = toRational(a, b);
        Rational y = toRational(c, d);
        Rational z = x + y;

        // Check result is equal to python implementation
        (uint256 numerator_1, uint256 denominator_1) = fromRational(z);
        (uint256 numerator_2, uint256 denominator_2) = ffi_result("add", a, b, c, d);
        assertEq(numerator_1, numerator_2);
        assertEq(denominator_1, denominator_2);
    }

    function test_sub(uint256 a, uint256 b, uint256 c, uint256 d) public {
        // Bounds
        a = bound(a, 0, type(uint128).max);
        b = bound(b, 1, type(uint128).max);
        c = bound(c, 0, type(uint128).max);
        d = bound(d, 1, type(uint128).max);

        // Ensure a / b >= c / d
        if (a * d < c * b) return;

        // Skip if numerator or denominator overflows uint128
        if (resultOverflowsUint128(a * d - c * b, b * d)) return;

        // Compute z = x - y
        Rational x = toRational(a, b);
        Rational y = toRational(c, d);
        Rational z = x - y;

        // Check result is equal to python implementation
        (uint256 numerator_1, uint256 denominator_1) = fromRational(z);
        (uint256 numerator_2, uint256 denominator_2) = ffi_result("sub", a, b, c, d);
        assertEq(numerator_1, numerator_2);
        assertEq(denominator_1, denominator_2);
    }

    function test_mul(uint256 a, uint256 b, uint256 c, uint256 d) public {
        // Bounds
        a = bound(a, 0, type(uint128).max);
        b = bound(b, 1, type(uint128).max);
        c = bound(c, 0, type(uint128).max);
        d = bound(d, 1, type(uint128).max);

        // Skip if numerator or denominator overflows uint128
        if (resultOverflowsUint128(a * c, b * d)) return;

        // Compute z = x * y
        Rational x = toRational(a, b);
        Rational y = toRational(c, d);
        Rational z = x * y;

        // Check result is equal to python implementation
        (uint256 numerator_1, uint256 denominator_1) = fromRational(z);
        (uint256 numerator_2, uint256 denominator_2) = ffi_result("mul", a, b, c, d);
        assertEq(numerator_1, numerator_2);
        assertEq(denominator_1, denominator_2);
    }

    function test_div(uint256 a, uint256 b, uint256 c, uint256 d) public {
        // Bounds
        a = bound(a, 0, type(uint128).max);
        b = bound(b, 1, type(uint128).max);
        c = bound(c, 1, type(uint128).max);
        d = bound(d, 1, type(uint128).max);

        // Skip if numerator or denominator overflows uint128
        if (resultOverflowsUint128(a * d, b * c)) return;

        // Compute z = x / y
        Rational x = toRational(a, b);
        Rational y = toRational(c, d);
        Rational z = x / y;

        // Check result is equal to python implementation
        (uint256 numerator_1, uint256 denominator_1) = fromRational(z);
        (uint256 numerator_2, uint256 denominator_2) = ffi_result("div", a, b, c, d);
        assertEq(numerator_1, numerator_2);
        assertEq(denominator_1, denominator_2);
    }

    function resultOverflowsUint128(uint256 numerator, uint256 denominator) internal pure returns (bool) {
        if (numerator > 0) {
            uint256 d = gcd(numerator, denominator);
            numerator /= d;
            denominator /= d;
        }

        return numerator > type(uint128).max || denominator > type(uint128).max;
    }

    function ffi_result(string memory op, uint256 a, uint256 b, uint256 c, uint256 d)
        internal
        returns (uint256, uint256)
    {
        string[] memory inputs = new string[](7);
        inputs[0] = "python";
        inputs[1] = "rational.py";
        inputs[2] = op;
        inputs[3] = a.toString();
        inputs[4] = b.toString();
        inputs[5] = c.toString();
        inputs[6] = d.toString();
        bytes memory data = vm.ffi(inputs);

        return abi.decode(data, (uint256, uint256));
    }

    function test_eq(uint256 a, uint256 b, uint256 c, uint256 d) public {
        // Bounds
        a = bound(a, 0, type(uint128).max);
        b = bound(b, 1, type(uint128).max);
        c = bound(c, 0, type(uint128).max);
        d = bound(d, 1, type(uint128).max);

        // Skip if numerator or denominator overflows uint128
        if (resultOverflowsUint128(a * d, b * c)) return;

        // Compute z = x cmp y
        Rational x = toRational(a, b);
        Rational y = toRational(c, d);
        uint256 z = eq(x, y) ? 1 : 0;

        // Check result is equal to python implementation
        (uint256 res,) = ffi_result("eq", a, b, c, d);
        assertEq(res, z);
    }

    
    function test_lt(uint256 a, uint256 b, uint256 c, uint256 d) public {
        // Bounds
        a = bound(a, 0, type(uint128).max);
        b = bound(b, 1, type(uint128).max);
        c = bound(c, 0, type(uint128).max);
        d = bound(d, 1, type(uint128).max);

        // Skip if numerator or denominator overflows uint128
        if (resultOverflowsUint128(a * d, b * c)) return;

        // Compute z = x cmp y
        Rational x = toRational(a, b);
        Rational y = toRational(c, d);
        uint256 z = lt(x, y) ? 1 : 0;

        // Check result is equal to python implementation
        (uint256 res,) = ffi_result("lt", a, b, c, d);
        assertEq(res, z);
    }

    
    function test_gt(uint256 a, uint256 b, uint256 c, uint256 d) public {
        // Bounds
        a = bound(a, 0, type(uint128).max);
        b = bound(b, 1, type(uint128).max);
        c = bound(c, 0, type(uint128).max);
        d = bound(d, 1, type(uint128).max);

        // Skip if numerator or denominator overflows uint128
        if (resultOverflowsUint128(a * d, b * c)) return;

        // Compute z = x cmp y
        Rational x = toRational(a, b);
        Rational y = toRational(c, d);
        uint256 z = gt(x, y) ? 1 : 0;

        // Check result is equal to python implementation
        (uint256 res,) = ffi_result("gt", a, b, c, d);
        assertEq(res, z);
    }

    
    function test_neq(uint256 a, uint256 b, uint256 c, uint256 d) public {
        // Bounds
        a = bound(a, 0, type(uint128).max);
        b = bound(b, 1, type(uint128).max);
        c = bound(c, 0, type(uint128).max);
        d = bound(d, 1, type(uint128).max);

        // Skip if numerator or denominator overflows uint128
        if (resultOverflowsUint128(a * d, b * c)) return;

        // Compute z = x cmp y
        Rational x = toRational(a, b);
        Rational y = toRational(c, d);
        uint256 z = neq(x, y) ? 1 : 0;

        // Check result is equal to python implementation
        (uint256 res,) = ffi_result("neq", a, b, c, d);
        assertEq(res, z);
    }

    
    function test_lte(uint256 a, uint256 b, uint256 c, uint256 d) public {
        // Bounds
        a = bound(a, 0, type(uint128).max);
        b = bound(b, 1, type(uint128).max);
        c = bound(c, 0, type(uint128).max);
        d = bound(d, 1, type(uint128).max);

        // Skip if numerator or denominator overflows uint128
        if (resultOverflowsUint128(a * d, b * c)) return;

        // Compute z = x cmp y
        Rational x = toRational(a, b);
        Rational y = toRational(c, d);
        uint256 z = lte(x, y) ? 1 : 0;

        // Check result is equal to python implementation
        (uint256 res,) = ffi_result("lte", a, b, c, d);
        assertEq(res, z);
    }

    
    function test_gte(uint256 a, uint256 b, uint256 c, uint256 d) public {
        // Bounds
        a = bound(a, 0, type(uint128).max);
        b = bound(b, 1, type(uint128).max);
        c = bound(c, 0, type(uint128).max);
        d = bound(d, 1, type(uint128).max);

        // Skip if numerator or denominator overflows uint128
        if (resultOverflowsUint128(a * d, b * c)) return;

        // Compute z = x cmp y
        Rational x = toRational(a, b);
        Rational y = toRational(c, d);
        uint256 z = gte(x, y) ? 1 : 0;

        // Check result is equal to python implementation
        (uint256 res,) = ffi_result("gte", a, b, c, d);
        assertEq(res, z);
    }
}
