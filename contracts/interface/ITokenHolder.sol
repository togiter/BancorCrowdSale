pragma solidity >=0.4.24 <0.6.0;
import "./IOwned.sol";
import "./IERC20Token.sol";
//token持有者接口
contract ITokenHolder is IOwned{
 /*
 *提现
 *_token token合约地址
 *_to 接受地址
 *_amount 体现金额
 */
 function withdrawTokens(IERC20Token _token,address _to,uint256 _amount) public;
}
