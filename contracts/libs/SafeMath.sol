pragma solidity >=0.4.24 <0.6.0;
/*
*用于防止基本数学运算的溢出保护
*/
library SafeMath{
    /*
    *两个值相加
    *
    */
    function add(uint256 _x,uint256 _y) internal pure returns(uint256) {
        uint256 z = _x + _y;
        require(z >= _x,"总和不应该小于加数");
        return z;
    }

    /*
    *两个数相减
    */
    function sub(uint256 _x,uint256 _y) internal pure returns(uint256) {
        require(_x >= _y,"减数不应该小于被减数");
        uint256 z = _x - _y;
        return z;
    }

    /*
    *两个数相乘
    */
    function mul(uint256 _x,uint256 _y) internal pure returns(uint256){
        if(_x == 0){//gas 优化
            return 0;
        }
        uint256 z = _x * _y;
        require(z / _x == _y,"检查溢出失败");
        return z;
    }

    /*
    *两个数相除
    * _x 除数
    *_y 被除数
    */
    function div(uint256 _x,uint256 _y) internal pure returns(uint256) {
        require(_y > 0,"被除数要大于0");
        uint256 c = _x / _y;
        return c;
    }

     /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}