pragma solidity >=0.4.24 <0.6.0;
import "./interface/ISmartToken.sol";
import "./TokenHolder.sol";
/*
*用于升级智能合约功能，比如修复bugs或漏洞，一旦接受了代币拥有者权限，就可以操作代币的其他功能
*为了升级controller，拥有者关系必须转移到新的controller
*smart token被设置之后不能再改变。
*controller可以转移token所有权给一个新的controller，而不允许执行token的任何功能，如果是非信任解决方案。
*/

contract SmartTokenController is TokenHolder{
    ISmartToken public token; //智能代币
    constructor(ISmartToken _token) public validAddress(address(_token)){
        token = _token;
    }

    //确保controllerb不是代币的拥有者
    modifier active(){
        require(token.owner() == address(this),"控制器不是token拥有者");
        _;
    }
    //控制器不是token的拥有者
    modifier inactive(){
        require(token.owner() != address(this),"控制器是token拥有者");
        _;
    }

   //建立新拥有者,token合约拥有者才有权限
   function transferTokenOwnership(address _newOwner) public ownerOnly{
       token.transferOwnership(_newOwner);
   }

   //授权新拥有者token权限
   function acceptTokenOwnership() public ownerOnly{
       token.acceptOwnership();
   }

   //启停代币转账功能
   function disableTokenTransfers(bool _disable) public ownerOnly{
       token.disableTransfers(_disable);
   }

    //向指定地址_to发放指定数量_amount代币
    function issueTokens(address _to,uint256 _amount) public ownerOnly{
          token.issue(_to,_amount);
    }

    //从指定地址_from销毁指定数量_amount代币
    function destroyTokens(address _from,  uint256 _amount) public ownerOnly{
        token.destroy(_from,_amount);
    }

   //从_token中提取_amount数量代币给_to地址
   function withdrawFromToken(IERC20Token _token,address _to,uint256 _amount) public ownerOnly{
       ITokenHolder(token).withdrawTokens(_token,_to,_amount);
   }

}