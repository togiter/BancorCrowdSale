pragma solidity >=0.4.24 <0.6.0;
/*
*紧急情况下暂停转账
*
*/
import "./Ownable.sol";
contract UrgencyPause is Ownable{
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);
    
    modifier notPaused(){
        require(!_paused,"the state is paused!");
        _;
    }
    constructor() public{
        _paused = false;
    }

    function paused() public view returns(bool) {
        return _paused;
    }

    function setPaused(bool state) public onlyOwner {
        if(_paused && !state){
            _paused = false;
            emit Unpaused(msg.sender);
        }else if(!_paused && state){
            _paused = true;
            emit Paused(msg.sender);
        }
    }


}
