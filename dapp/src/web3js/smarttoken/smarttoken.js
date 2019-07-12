import DApp from '@/startweb3.js';
let BigInt = require('big-number');
const web3 = DApp.web3;
const tokenContract = DApp.tokenContract;
const sender = {from:DApp.account}

/*
*授权token合约转让
*
*/
export function web3TransferOwnership(newOwner,callback){
   // tokenContract.events.
   tokenContract.methods.transferOwnership(DApp.crowdContract.address).send(sender).then(result=>{
       console.log('r',result);
   });
}


/*
*token合约转让
*
*/
export function web3AcceptOwnership(callback){
    // tokenContract.events.
    tokenContract.methods.acceptOwnership().send({from:DApp.crowdContract.address}).then(result=>{
        console.log('r',result);
    });
 }

 /*
 *余额
 */
export function web3Balance(addr){
     // tokenContract.events.
     tokenContract.methods.balanceOf(addr).call(sender).then(result=>{
        console.log('r',result.toString(10));
    });
}



