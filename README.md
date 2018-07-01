# Elliptic Curve Operations in Solidity

Elliptic cureve point multiplication performed in projective coordinates.

In the specific contract the curve is alt-bn128 but it works for any curve.



## Run

* To run points addition simply run:

    function add(uint256 x0, uint256 y0,
                 uint256 x1, uint256 y1) public pure
        returns(uint256 x2, uint256 y2)

* To run double a point run:

    function twice(uint256 x0, uint256 y0) public pure
        returns(uint256 x1, uint256 y1)
  

* To multiply a point in some power of two scalar run:

    function multiplyPowerBase2(uint256 x0, uint256 y0, 
                                int exp) public pure
        returns(uint256 x1, uint256 y1)



### Notes

1. Currently one addition or doubling a point is ~1600 gas.
2. There are precompiled contracts for the same operations in the curve bn128. It is more gas-wised to use the precompiled contracts for multiplying a base 2 power with exponent that is large (i.e., larger than ~30).
3. It is better to return to affine coordinates (if necessary) only at the end of the computation (since it requires division, thus costs more gas).