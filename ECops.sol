pragma solidity ^0.4.0;

// Own implementation
contract ECops {
    
    
    uint256 constant n = 0x30644E72E131A029B85045B68181585D97816A916871CA8D3C208C16D87CFD47;
                         
    uint256 constant a = 0;
    uint256 constant b = 3;
    

    
    // Returns the inverse in the field of modulo n 
    function inverse(uint256 num) public pure
        returns(uint256 invNum)
    {
        uint256 t = 0;
        uint256 newT = 1;
        uint256 r = n;
        uint256 newR = num;
        uint256 q;
        while (newR != 0) {
            q = r / newR;

            (t, newT) = (newT, addmod(t , (n - mulmod(q, newT,n)) , n));
            (r, newR) = (newR, r - q * newR );
        }

        invNum = t;
    }
    
    
    // Transform from affine to projective coordinates
    function toProjectivePoint(uint256 x0, uint256 y0) public view
        returns(uint256 x1, uint256 y1, uint256 z1)
    {
        z1 = addmod(0, 1, n);
        x1 = mulmod(x0, z1, n);
        y1 = mulmod(y0, z1, n);
    }
    
    
    // Transform from projective to affine coordinates
    function toAffinePoint(uint256 x0, uint256 y0, uint256 z0) public pure
        returns(uint256 x1, uint256 y1)
    {
        uint256 z0Inv;
        z0Inv = inverse(z0);
        x1 = mulmod(x0, z0Inv, n);
        y1 = mulmod(y0, z0Inv, n);
    }


    // Returns the zero curve in proj coordinates
    function zeroProj() public pure 
        returns(uint256 x, uint256 y, uint256 z)
    {
        return (0,0,1);
    }


    // Checks if the curve is the zero curve
    function isZero(uint256 x0, uint256 y0) public pure
        returns(bool isZero)
    {
        if(x0 == 0 && y0 == 0) {
            return true;
        }
        return false;
    }
    

    // Double an eliptic curve point
    // https://www.nayuki.io/page/elliptic-curve-point-addition-in-projective-coordinates
    function twiceProj(uint256 x0, uint256 y0, uint256 z0) public pure
        returns(uint256 x1, uint256 y1, uint256 z1)
    {
        uint256 t;
        uint256 u;
        uint256 v;
        uint256 w;

        if(isZero(x0, y0)){
            return zeroProj();
        }

        u = mulmod(y0, z0, n);
        u = mulmod(u, 2, n);

        v = mulmod(u, x0, n);
        v = mulmod(v, y0, n);
        v = mulmod(v, 2, n);

        x0 = mulmod(x0, x0, n);
        t = mulmod(x0, 3, n);
        // comment in this section iff a = 0 (to save gas)
        z0 = mulmod(z0, z0, n);
        z0 = mulmod(z0, a, n);
        t = addmod(t, z0, n);
        // comment up to here if a = 0

        w = mulmod(t, t, n);
        x0 = mulmod(2, v, n);
        w = addmod(w, n-x0, n);

        x0 = addmod(v, n-w, n);
        x0 = mulmod(t, x0, n);
        y0 = mulmod(y0, u, n);
        y0 = mulmod(y0, y0, n);
        y0 = mulmod(2, y0, n);
        y1 = addmod(x0, n-y0, n);

        x1 = mulmod(u, w, n);

        z1 = mulmod(u, u, n);
        z1 = mulmod(z1, u, n);



    }



    // Add eliptic curve points
    // https://www.nayuki.io/page/elliptic-curve-point-addition-in-projective-coordinates
    function addProj(uint256 x0, uint256 y0, uint256 z0,
                     uint256 x1, uint256 y1, uint256 z1) public pure
        returns(uint256 x2, uint256 y2, uint256 z2)
    {
        uint256 t0;
        uint256 t1;
        uint256 u0;
        uint256 u1;
        uint256 t;

        if (isZero(x0, y0)){
            return (x1, y1, z1);
        } 
        else if (isZero(x1, y1)){
            return (x0, y0, z0);
        }
        
        t0 = mulmod(y0, z1, n);
        t1 = mulmod(y1, z0, n);
        
        u0 = mulmod(x0, z1, n);
        u1 = mulmod(x1, z0, n);
        
        if (u0 == u1) {
            if (t0 == t1) {
                return twiceProj(x0, y0, z0);
            }
            else {
                return zeroProj();
            }
        }
        
        (x2, y2, z2) = addProj2(mulmod(z0, z1, n), u0, u1, t1, t0);
    }
    
    
    // help function to split addProj so it won't have too many local variables
    function addProj2(uint256 v, uint256 u0, uint256 u1, uint256 t1, uint256 t0) private pure
        returns(uint256 x2, uint256 y2, uint256 z2)
    {
        uint256 u;
        uint256 u2;
        uint256 u3;
        uint256 w;
        uint256 t;

        t = addmod(t0, n-t1, n);
        u = addmod(u0, n-u1, n);
        u2 = mulmod(u, u, n);

        w = mulmod(t, t, n);
        w = mulmod(w, v, n);
        u1 = addmod(u1, u0, n);
        u1 = mulmod(u1, u2, n);
        w = addmod(w, n-u1, n);
        
        x2 = mulmod(u, w, n);

        u3 = mulmod(u2, u, n);
        u0 = mulmod(u0, u2, n);
        u0 = addmod(u0, n-w, n);
        t = mulmod(t, u0, n);
        t0 = mulmod(t0, u3, n);

        y2 = addmod(t, n-t0, n);

        z2 = mulmod(u3, v, n);
    }
    

    // Add two eliptic curve points (affine coordinates)
    function add(uint256 x0, uint256 y0,
                 uint256 x1, uint256 y1) public pure
        returns(uint256 x2, uint256 y2)
    {
        uint256 z0;

        (x0, y0, z0) = addProj(x0, y0, 1, x1, y1, 1);
        return toAffinePoint(x0, y0, z0);
    }


    // Double an eliptic curve point (affine coordinates)
    function twice(uint256 x0, uint256 y0) public pure
        returns(uint256 x1, uint256 y1)
    {
        uint256 z0;

        (x0, y0, z0) = twiceProj(x0, y0, 1);
        return toAffinePoint(x0, y0, z0);
    }


    // Multiple an eliptic curve point in a 2 power base (i.e., (2^exp)*P))
    function multiplyPowerBase2(uint256 x0, uint256 y0, 
                                int exp) public pure
        returns(uint256 x1, uint256 y1)
    {
        uint256 tempX = x0;
        uint256 tempY = y0;
        uint256 tempZ = 1;

        for(int i = 0; i < exp; i++) {
            (tempX, tempY, tempZ) = twiceProj(tempX, tempY, tempZ);
        }
        return toAffinePoint(tempX, tempY, tempZ);
    }
    
}