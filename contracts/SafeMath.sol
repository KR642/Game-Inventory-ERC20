//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library safeArithmetic{
    function add(uint _x, uint _y) internal pure returns(uint){
        uint _z = _x + _y;
        assert(_z >= _x);
        return(_z);
    }

    function subtract(uint _x, uint _y) internal pure returns(uint){
        assert(_x >= _y);
        return( _x - _y);
    }
}
