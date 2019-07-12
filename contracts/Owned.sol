pragma solidity >=0.4.24 <0.6.0;
import "./interface/IOwned.sol";
contract Owned is IOwned{
address public owner;//拥有者
address public newOwner; //新拥有者

//拥有者更新事件
event OwnerUpdate(address _prevOwner,address _newOwner);

//构造函数
constructor() public{
    owner = msg.sender;
}
//只允许拥有者执行
modifier ownerOnly{
    require(msg.sender == owner,"只有拥有者才能执行");
    _;
}

//授权新拥有者(管理员)
function transferOwnership(address _newOwner) public ownerOnly {
    require(_newOwner != owner,"新拥有者不应等于原拥有者");
    newOwner = _newOwner;
}

//接受确认拥有者权限
function acceptOwnership() public {
    require(msg.sender == newOwner,"新拥有者才能执行");
    emit OwnerUpdate(owner,newOwner);
    owner = newOwner;
    newOwner = address(0);
}
}