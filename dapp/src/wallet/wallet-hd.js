const bip39 = require('bip39');
const HDKey = require('ethereumjs-wallet/hdkey');
const ethUtil = require('ethereumjs-util');
const ethWallet = require('ethereumjs-wallet');

//以太坊钱包路径
const ETHEREUM_PATH = "m/44'/60'/0'/0/0";
const BASE_PATH = "m/44'"; //bip44

const Wallet = {
  //助记词,备份，恢复钱包
  mnemoinc:null,
  //主节点hdKey，相当于钱包本身,分层确定性钱包主节点
  master:null,
  //keystore保存加密后的密钥,+密码恢复钱包
  keystore:null,
  //保存账号map(key：hdKey,指定了区块链类型的hdKey对象),btc=0,eth=60...
  walletsMap:{},
  coins:{},

  //添加币种
  addCoins:function(name,path){

  },

  /**从助记词+密码恢复钱包
   *mnemoinc 导入的助记词
   * pwd密码
   * 返回钱包主节点master
   */
  restoreWithMnemonic:function(mnemoinc,pwd){
    //取回种子
    // let seed = bip39.mnemonicToSeedSync(mnemoinc,pwd);
    this.mnemoinc = mnemoinc;
    this.master = this.generateMaster(pwd);
    return this.getWalletInfo(this.master,pwd);
  },
  //私钥+密码恢复钱包
  restoreWithPrivkey(privKey,pwd){
    let keyBuffer = Buffer.from(privKey,'hex');
    let keyWallet = ethWallet.fromPrivateKey(keyBuffer);
    return this.getWalletInfo(keyWallet,pwd);
  },

  //从keystore里面恢复钱包
  restoreWithKeystore(keystore,pwd){
    let rWallet = ethWallet.fromV3(keystore,pwd);
    return this.getWalletInfo(rWallet,pwd);
  },

  //生成助记词
  generateMnemonic:function (bits) {
    if(!bits || bits.length <= 0){
      bits = 128; //默认128位
    }
    //生成指定位数的助记词
    const mnemoinc = bip39.generateMnemonic(bits);
    console.log("mnemoinc:",mnemoinc);
    return mnemoinc;
  },
  //生成主密钥节点
  generateMaster:function(pwd){
    if(!this.mnemoinc){
      this.mnemoinc = this.generateMnemonic();
    }
    //由助记词生成种子
    const seed = bip39.mnemonicToSeedSync(this.mnemoinc,pwd);
    const master = HDKey.fromMasterSeed(seed);
    this.master = master;
    console.log('master',master);
    return master;
  },
  //生成钱包 ,BIP44 的内容相比 BIP32 就简单很多，里面规定了子节点派生路径的范式：
  //path==>  m / purpose' / coin_type' / account' / chain / address_index
  /*

  每个段的含义分别是：

· CKD: m: 使用 CKDpriv, M 则表示使用 CKDPub
· Purpose: 44' , hardened, 遵循哪个规范, 44 意味着 BIP44
· Coin: 60', hardened, 60 指代以太坊, 完整的链代码（https://github.com/satoshilabs/slips/blob/master/slip-0044.md）
· Account: 0' , hardened, 账户编号
· Chain: 0 , 对于非比特币路径都是 0
· Index: 0, 具体的账户节点
   */
  generateWallet:function (name,path,pwd) {
    if(this.walletsMap && this.walletsMap.name){
      console.log(name,' is existed!')
      return null;
    }
    let node = this.master.derivePath(path);
    let wallet = node.getWallet();
    let walletInfo = this.getWalletInfo(wallet,pwd);
    this.walletsMap.name = walletInfo;
  },
  //获取钱包信息
  getWalletInfo(wallet,pwd){
    let addr = ethUtil.bufferToHex(ethUtil.publicToAddress(wallet.getPublicKey(),true));
    let privKey = wallet.getPrivateKey().toString('hex');
    let keystore = wallet.toV3String(pwd);
    console.log('pathWallet',wallet,'\naddr:',addr,'\nprivKey:',privKey,'keystore',keystore);
    let wal = {
      wallet:wallet,
      address:addr,
      privKey:privKey,
      keystore:keystore
    }
    return wal;
  }
}

// Object.defineProperty(Wallet.prototype,'mnemoinc',{get:function () {
//     return this.mnemoinc;
//   }});
//
// Object.defineProperty(Wallet.prototype,'master',{get:function () {
//     return this.master;
//   }});
//
// Object.defineProperty(Wallet.prototype,'keystore',{get:function () {
//     return this.keystore;
//   }});
// Object.defineProperty(Wallet.prototype,'walletsMap',{get:function () {
//     return this.walletsMap;
//   }});


window.wallet = Wallet;
