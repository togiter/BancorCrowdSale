pragma solidity >=0.4.24 <0.6.0;
import "./SmartTokenController.sol";
import "./libs/SafeMath.sol";

contract CrowdsaleController is SmartTokenController {
    using SafeMath for uint256;
    uint256 public constant DURATION = 10 days; //众筹时间
    uint256 public constant TOKEN_PRICE_N = 1;//初始化价格，分子 ？
    uint256 public constant TOKEN_PRICE_D = 100;//价格 分母
    uint256 public constant BTCS_ETHER_CAP = 50000 ether;//最大从bitcoin suisse众筹的以太坊数量
    uint256 public constant MAX_GAS_PRICE = 50000000000 wei; //众筹交易的最大gas price

    string public version = '0.1'; //版本
    uint256 public startTime = 0;   //众筹开始时间 s
    uint256 public endTime = 0;     //众筹结束时间
    uint256 public totalEtherCap = 10000 ether;//众筹目标，初始化一个临时值作为安全机制，直到真正达成目标
    uint256 public totalEtherContributed = 0;//目前为止获得的众筹数目
    //bytes32 public realEtherCapHash; //确保实际目标是在部署合约之前是预定义并且之后不能改变的。
    address public beneficiary = address(0); //用于接受众筹的地址
    // address public btcs = address(0); //bitcoin suisse交易所地址

    //触发众筹事件
    event Contribution(address indexed _contributor,uint256 _amount,uint256 _return);

    constructor(ISmartToken _token,uint256 _startTime,address _beneficiary,/*address _btcs,*/uint256 _totalEtherCap)public
    SmartTokenController(_token)
    validAddress(_beneficiary)
    // validAddress(_btcs)
   earlierThan(_startTime)
    greaterThanZero(uint256(_totalEtherCap))
    {
        startTime = _startTime;
        endTime = startTime+DURATION;
        beneficiary = _beneficiary;
        // btcs = _btcs;
        if(_totalEtherCap > 0){
             totalEtherCap = _totalEtherCap.mul(10**18);
        }
     //   realEtherCapHash = _realEtherCapHash;
    }

    //限制gas price
    modifier validGasPrice(){
        require(tx.gasprice <= MAX_GAS_PRICE,"gas 大于最大值");
        _;
    }

    //验证预设目标】
    // modifier validEtherCap(uint256 _cap,uint256 _key){
    //     require(computeRealCap(_cap,_key)==realEtherCapHash, "实际募资目标被修改");
    //     _;
    // }

    //确保当前事件早于给定时间
    modifier earlierThan(uint256 _time) {
        require(now < _time,"众筹开始时间不能小于当前时间");
        _;
    }

    //确保当前时间处于【startTime,endTime)内
    modifier between(uint256 _startTime,uint256 _endTime){
        require(now >= _startTime && now < _endTime,"已过众筹期间");
        _;
    }
    //确保sender是bitcoin suisse
    // modifier btcsOnly{
    //     assert(msg.sender == btcs);
    //     _;
    // }

    //确保募集目标尚未达成
    modifier etherCapNotReached(uint256 _contribution){
        require(totalEtherContributed.add(_contribution) <= totalEtherCap,"目标已达成，不能再投资了");
        _;
    }

    //确保btcs途径募集的eth尚未达成目标
    modifier btcsEtherCapNotReached(uint256 _ethContribution){
        assert(totalEtherContributed.add(_ethContribution) <= BTCS_ETHER_CAP);
        _;
    }

    //计算真是募集目标hash
    function computeRealCap(uint256 _cap,uint256 _key) public pure returns(bytes32){
        return keccak256(_cap,_key);
    }

    // function enableRealCap(uint256 _cap,uint256 _key) public ownerOnly active between(startTime,endTime) validEtherCap(_cap,_key){
    //     require(_cap < totalEtherCap, "目标已达成");
    //     totalEtherCap = _cap;
    // }

    //计算给定准备金和智能代币的倍率
    function computeReturn(uint256 _contribution) public pure returns(uint256){
        return _contribution.mul(TOKEN_PRICE_D).div(TOKEN_PRICE_N);
    }

    //处理众筹期间的eth
    function contributeETH() public payable between(startTime,endTime) returns(uint256 amount){
        return processContribution();
    }

    //通过bitcoin suisse 的众筹eth
    // function contributeBTCs() public payable btcsOnly btcsEtherCapNotReached(msg.value) earlierThan(startTime) returns(uint256 amount){
    //     return processContribution();
    // }

    //处理接受eth逻辑
    function processContribution() private active etherCapNotReached(msg.value) validGasPrice returns(uint256 amount){
        uint256 tokenAmount = computeReturn(msg.value); //获取对应eth得到的智能代币数量
        beneficiary.transfer(msg.value);
        totalEtherContributed = totalEtherContributed.add(msg.value);//募集量增加
        token.issue(msg.sender,tokenAmount); //代币给投资者
        token.issue(beneficiary,tokenAmount); //收益获得同样额度

        emit Contribution(msg.sender,msg.value,tokenAmount);
        return tokenAmount;
    }

    //fallback
    function() payable external{
        contributeETH();
    }
}