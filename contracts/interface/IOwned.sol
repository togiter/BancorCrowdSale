/*
*拥有者接口
*/
pragma solidity >=0.4.17 <0.6.0;
contract IOwned {
    //该函数并非抽象函数，编译器回自动生产一个外部getter函数
    function owner() public view returns(address) {owner;}

    //转移拥有者
    function transferOwnership(address _newOwner) public;

    //接受拥有者
    function acceptOwnership() public;
}