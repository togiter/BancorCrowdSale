pragma solidity >=0.4.24 <0.6.0;
import "./libs/Utils.sol";
import "./interface/ITokenHolder.sol";
import "./Owned.sol";
/*
    We consider every contract to be a 'token holder' since it's currently not possible
    for a contract to deny receiving tokens.

    The TokenHolder's contract sole purpose is to provide a safety mechanism that allows
    the owner to send tokens that were sent to the contract by mistake back to their sender.

    Note that we use the non standard ERC-20 interface which has no return value for transfer
    in order to support both non standard as well as standard token contracts.
    see https://github.com/ethereum/solidity/issues/4116
*/
contract TokenHolder is ITokenHolder, Owned, Utils {
    /**
        @dev constructor
    */
    constructor() public {
    }

    /**
        @dev withdraws tokens held by the contract and sends them to an account
        can only be called by the owner

        @param _token   ERC20 token contract address
        @param _to      account to receive the new amount
        @param _amount  amount to withdraw
    */
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(address(_token))
        validAddress(_to)
        notThis(_to)
    {
        require(_token.transfer(_to, _amount),"提现失败!");
    }
}
