pragma solidity >=0.4.24 <0.6.0;
import "./ITokenHolder.sol";
import "./IERC20Token.sol";
contract ISmartToken is ITokenHolder,IERC20Token {
//禁用转账功能
function disableTransfers(bool _disable) public;
//向指定账号(_to)生成指定数量(_amount)的智能代币
function issue(address _to,uint256 _amount) public;
//从指定账号(_from)销毁指定数量(_amount)的智能代币
function destroy(address _from,uint256 _amount) public;
}