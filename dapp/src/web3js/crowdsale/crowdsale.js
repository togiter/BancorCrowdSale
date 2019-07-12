import {hexToHash,hashToHex,strToBytes,bytesToStr,uint8ArrayToStr} from '../../utils/convert'
import DApp from '@/startweb3.js';
let BigInt = require('big-number');
const web3 = DApp.web3;
const crowdContract = DApp.crowdContract;
const sender = {from:DApp.account}

/*
*计算给定准备金以太坊得到的智能代币数量
*contribution 众筹以太坊
*/
export function web3ComputeReturn(contribution,callback){
    crowdContract.methods.computeReturn(contribution).call(sender).then(result=>{
        console.log(contribution,"eth = ",result.toString(10),"tokens");
    });
}

/*
*获取token合约权限
*/
export function web3AcceptTokenOwnership(){
    crowdContract.events.OwnerUpdate().on('data',result=>{
        console.log('ownershipResult',result);
    });
    crowdContract.methods.acceptTokenOwnership().send(sender).then(ret=>{
        console.log(ret);
    });
}

/*
*发送以太坊给众筹项目
*
*/
export function web3ContributeETH(amount,callback){
    let account = DApp.account;
    console.log('投资者',account);
    crowdContract.methods.contributeETH().send({from:account,value:amount}).then(result=>{
        console.log("smartToken",result);
    });
}