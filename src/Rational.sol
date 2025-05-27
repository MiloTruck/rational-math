// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct Rational {
    uint256 numerator;
    uint256 denominator;
}

library RationalMath {
    function add(Rational memory x, Rational memory y) internal pure returns (Rational memory) {
        if (x.numerator == 0) return y;
        if (y.numerator == 0) return x;

        // (a / b) + (c / d) = (ad + cb) / bd
        uint256 numerator = x.numerator * y.denominator + y.numerator * x.denominator;
        uint256 denominator = x.denominator * y.denominator;

        return from(numerator, denominator);
    }

    function sub(Rational memory x, Rational memory y) internal pure returns (Rational memory) {
        if (y.numerator == 0) return x;
        require(x.numerator != 0, "Underflow");

        // (a / b) - (c / d) = (ad - cb) / bd
        // a / b >= c / d implies ad >= cb, so the subtraction will never underflow when x >= y
        uint256 numerator = x.numerator * y.denominator - y.numerator * x.denominator;
        uint256 denominator = x.denominator * y.denominator;

        return from(numerator, denominator);
    }

    function mul(Rational memory x, Rational memory y) internal pure returns (Rational memory) {
        if (x.numerator == 0 || y.numerator == 0) return Rational(0, 1);

        // (a / b) * (c / d) = ac / bd
        uint256 numerator = x.numerator * y.numerator;
        uint256 denominator = x.denominator * y.denominator;

        return from(numerator, denominator);
    }

    function div(Rational memory x, Rational memory y) internal pure returns (Rational memory) {
        if (x.numerator == 0) return Rational(0, 1);
        require(y.numerator != 0, "Division by zero");

        // (a / b) / (c / d) = ad / bc
        uint256 numerator = x.numerator * y.denominator;
        uint256 denominator = x.denominator * y.numerator;

        return from(numerator, denominator);
    }

    function from(uint256 x, uint256 y) internal pure returns (Rational memory) {
        uint256 d = gcd(x, y);
        return Rational(x / d, y / d);
    }

    function fromU256(uint256 x) internal pure returns (Rational memory) {
        return Rational(x, 1);
    }

    function toU256(Rational memory x) internal pure returns (uint256) {
        return x.numerator / x.denominator;
    }

    function gcd(uint256 x, uint256 y) private pure returns (uint256) {
        while (y != 0) {
            uint256 t = y;
            y = x % y;
            x = t;
        }
        return x;
    }
}
