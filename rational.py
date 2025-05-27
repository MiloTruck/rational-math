import sys
from fractions import Fraction

if __name__ == "__main__":
    if len(sys.argv) != 6:
        sys.exit(f"Usage: {sys.argv[0]} operation a b c d")

    # Get rationals
    x = Fraction(int(sys.argv[2]), int(sys.argv[3]))
    y = Fraction(int(sys.argv[4]), int(sys.argv[5]))

    # Get operation
    operation = sys.argv[1]

    # Compute result
    if operation == "add": 
        z = x + y
    elif operation == "sub":
        z = x - y
    elif operation == "mul":
        z = x * y
    elif operation == "div":
        z = x / y

    # Print z as a abi-encoded (uint256, uint256)
    print(z.numerator.to_bytes(32, byteorder="big").hex(), end="")
    print(z.denominator.to_bytes(32, byteorder="big").hex(), end="")