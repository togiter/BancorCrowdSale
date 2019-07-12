pragma solidity >=0.4.24 <0.6.0;
contract IERC20Token{
// these functions aren't abstract since the compiler emits automatically generated getter functions as external
function name() public view returns(string memory) {}
function symbol() public view returns(string memory) {}
function decimals() public view returns(uint256) {}
function totalSupply() public view returns (uint256) {}
function balanceOf(address _owner) public view returns (uint256) { _owner; }
function allowance(address _owner, address _spender) public view returns (uint256) { _owner; _spender; }

function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);

}