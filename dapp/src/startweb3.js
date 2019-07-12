import Web3 from "web3";
import crowdContractJson from "../../build/contracts/CrowdsaleController.json";
import tokenContractJson from "../../build/contracts/SmartToken.json";

const HTTP_PROVIDER = 'http://127.0.0.1:8545';

const DApp = {
  web3: null,
  account: null,
  crowdContract:null,    //众筹合约
  tokenContract:null,           //token合约
  meta: null,

  start: async function() {
    const { web3 } = this;
    try {
      // get contract instance
      this.crowdContract = await this.newContract(crowdContractJson);
      this.tokenContract = await this.newContract(tokenContractJson);
      const accounts = await web3.eth.getAccounts();
      console.log("众筹合约:",this.crowdContract,"\ntoken合约",this.tokenContract);
      this.account = accounts[0];
     console.log('accounts',accounts);
    } catch (error) {
      console.error("Could not connect to contract or chain.");
    }
  },
  newContract: async function(cJson){
  const web3  = this.web3;
  const netId = await web3.eth.net.getId();
  const depNetwork = cJson.networks[netId];
  const contract = await new web3.eth.Contract(cJson.abi,depNetwork.address);
  console.log('abi',cJson.abi);
  //console.log('contract.motheds',contract.methods);
  return contract;
}
};




window.DApp = DApp;

window.addEventListener("load", function() {
  if (window.ethereum) {
    // use MetaMask's provider
    DApp.web3 = new Web3(window.ethereum);
    window.ethereum.enable(); // get permission to access accounts

  } else {
    console.warn(
      "No web3 detected. Falling back to "+HTTP_PROVIDER+". You should remove this fallback when you deploy live",
    );
    let web3 = new Web3(HTTP_PROVIDER);
    web3.setProvider(HTTP_PROVIDER);
    if(web3==null || web3 === 'undefined'){
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
        web3 = new Web3(
             new Web3.providers.HttpProvider(HTTP_PROVIDER),
        );
    }
    DApp.web3 = web3;
  }

  DApp.start();
});

export default DApp;
