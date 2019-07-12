const bip39 = require('bip39');
const HDKey = require('ethereumjs-wallet/hdkey');
const ethUtil = require('ethereumjs-util');
const ethWallet = require('ethereumjs-wallet');

//钱包基本路径bip44
const BASE_PATH = "m/44'";
const Wallet = {
    mnemoinc:null, //助记词
    seed:null,      //种子
    master:null,    //主节点
    coins:{},       //币种钱包

    
};

