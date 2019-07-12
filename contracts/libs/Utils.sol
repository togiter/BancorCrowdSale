pragma solidity >=0.4.24 <0.6.0;
contract Utils{
    constructor() public{}

    //验证amount>0
    modifier greaterThanZero(uint256 _amount){
        require(_amount > 0,"参数必须大于0");
        _;
    }

    //验证地址不能为空
    modifier validAddress(address _address){
        require(_address != address(0),"地址不能为空");
        _;
    }

    //验证非本合约地址
    modifier notThis(address _address){
        require(_address != address(this),"不能为本合约地址");
        _;
    }

}