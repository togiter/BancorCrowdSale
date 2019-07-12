pragma solidity >=0.4.24 <0.6.0;
import './Ownable.sol';
import './UrgencyPause.sol';
import '../libs/SafeMath.sol';

contract Crowdsale is Ownable,UrgencyPause {
    using SafeMath for uint256;
    IERC20 _token;

    uint32 constant DECIMALS = 8; //token's decimals
    //crowdsale start
    uint256 private _startTimestamp;
    uint256 private _etherPrice; //1 Ether = x.xxxxxCNY,with 8 decimals
    //audit ether price auditor
    mapping(address=>bool) private _etherPriceAuditors; //onlyOwner edit

    //target,current
    uint256 constant ETHER_CAP = 20000 ether;
    uint256 private _curEthers;
    uint256 private _curCNYs;
    uint256 private _curTokens;

    //stage
    uint256 constant STAGE_MAX = 60;
    uint256 private _curStage;//begin 0
    uint256 private _stageEtherCap; //stage target, (0-19:200,20-39:250,39-59:200)
    uint256 private _curStageEther; //currunt stage eth
    uint256 constant SEASON_MAX = 3;
    uint256 constant SECSON_STAGES = STAGE_MAX / SEASON_MAX;//20
    uint256 private _curSeason;

    //token price
    uint256 constant TOKEN_CNY_PRICE_START = 0.05*10**8;
    uint256 constant TOKEN_CNY_PRICE_STEP = 0.02*10**8;
    uint256 constant TOKEN_CNY_PRICE_TARGET = 0.5*10*8;//target price
    uint256 private _tokenCNYPrice;//=TOKEN_CNY_PRICE_START+_curStage*TOKEN_CNY_PRICE_STEP

    struct Investor{
       address account;
       uint256  stage;
       uint256 eths;  //wei amount
       uint256 cnys; //rmb
       uint256 tokens;  //token amount
    }
    //recording investor info
    mapping(uint256=>mapping(address=> Investor)) _investors;//stage=>(address=>investor)
    //total eth for stage
    mapping (uint256=>uint256) private _stageETHSold;
    //total CNY for stage
    mapping (uint256=>uint256) private _stageCNYSold;
    //issued tokens for stage
    mapping (uint256=>uint256) private _stageTokenIssued;

    //events
    event InsestorContributed(address investor,uint256 stage,uint256 invest,uint256 tokens);
    event AuditEtherPriceChanged(address indexed account,uint256 value);
    event AuditEtherPriceAuditorChanged(address indexed account,bool state);

    event TokenIssuedTransferred(address indexed to,uint256 indexed stageIndex,uint256 indexed tokens,uint256 etherPrice);
    event StageClosed(address indexed account,uint256 indexed stage);

    //modifier
    modifier onlyEtherPriceAuditor() {
        require(_etherPriceAuditors[msg.sender],"sender is not ether price auditor!");
        _;
    }

    modifier onlyOnSaling(){
        require(_startTimestamp > 0 && now > _startTimestamp,"crowd sale has not start yet!");
        require(_etherPrice > 0,"Audit ETH price must be greater than zero!");
        require(!paused(),"crowdsale is paused");
        require(_curStage < STAGE_MAX,"stage max!!");
        _;
    }

    //methods
    constructor(IERC20 token) public{
        _token = IERC20(token);
        _curStage = 0;
        _curSeason = 1;
        _etherPriceAuditors[msg.sender] = true;
        _stageEtherCap = stageEtherCap(_curStage);
    }
    //alter ether price CNY
    function setEtherPrice(uint256 value) public onlyEtherPriceAuditor {
        _etherPrice = value;
        emit AuditEtherPriceChanged(msg.sender,value);
    }

    //get the start timestamp
    function startTimestamp() public view returns(uint256) {
        return _startTimestamp;
    }

    //set start timestamp
    function setStartTimestamp(uint256 timestamp) public onlyOwner {
        require(now <= timestamp, "start timestamp must greater now!");
        _startTimestamp = timestamp;
    }

    //get ether price auditor state
    function etherPriceAuditor(address account) public view returns(bool){
        return _etherPriceAuditors[account];
    }

    //set ether price auditor state
    function setEtherPriceAuditor(address account,bool state) public onlyOwner {
       require(account != address(0),"invaild account!");
        _etherPriceAuditors[account] = state;
        emit AuditEtherPriceAuditorChanged(account,state);
    }

    //get the token price in CNY,by stage index
    function stageTokenCNYPrice(uint256 stageIndex) private view returns(uint256) {
        return TOKEN_CNY_PRICE_START.add(TOKEN_CNY_PRICE_STEP.mul(stageIndex));
    }

    //wei => CNY
    function wei2CNY(uint256 amount) private view returns(uint256) {
        return amount.mul(_etherPrice).div(1 ether);
    }

    //CNY => wei
    function CNY2wei(uint256 amount) private view returns(uint256){
        return amount.mul(1 ether).div(_etherPrice);
    }

    //CNY =>Token
    function CNY2Token(uint256 cnyAmount) private view returns(uint256) {
        return cnyAmount.mul(10**DECIMALS).div(_tokenCNYPrice);
    }

    //CNY => Token by stage
    function CNY2TokenByStage(uint256 cnyAmount,uint256 stageIndex) public view returns(uint256) {
        return cnyAmount.mul(10**DECIMALS).div(stageTokenCNYPrice(stageIndex));
    }

  

    //get cur season by stageIndex
    function seasonInStageIndex(uint256 stageIndex) public view returns(uint256) {
        uint256 stagesPerSeason = STAGE_MAX.div(SEASON_MAX);
        return stageIndex.div(stagesPerSeason);
    }

    //ether cap at stageIndex
    function stageEtherCap(uint256 stageIndex) private view returns(uint256) {
        uint256 seasonIndex = seasonInStageIndex(stageIndex);
        if(seasonIndex == 0){
            return 200*10**18; //wei  200 ether
        }else if(seasonIndex == 1){
            return 250*10**18; //wei  250 ether
        }else {
            return 200*10**18; //wei  200 ether
        }
    }

      //calculate stage CNY cap,by stage index
    function stageCNYCap(uint256 stageIndex) public view returns(uint256) {
        uint256 etherCap = stageEtherCap(stageIndex);
        return wei2CNY(etherCap);
    }

    //stage token cap
    function stageTokenCap(uint256 stageIndex) public view returns(uint256) {
        return CNY2TokenByStage(stageCNYCap(stageIndex),stageIndex);
    }

    //new stage
    function nextStage() private {
        _stageETHSold[_curStage] = _curStageEther;
        _stageCNYSold[_curStage] = wei2CNY(_curStageEther);
        _stageTokenIssued[_curStage] = CNY2TokenByStage(_stageCNYSold[_curStage],_curStage);
        _curStage = _curStage.add(1);//stage++
         //reset
        _curStageEther = 0;
        _stageEtherCap = 0;
        _stageEtherCap = stageEtherCap(_curStage);
    }

    //exchange cny=>token
    function exchangeTokensByCNY(uint256 amount) private returns(uint256) {
        uint256 tokens = CNY2Token(amount);
        require(transferTokensIssued(tokens),"transfer tokens failed!");
        return tokens;
    }


    function transferTokensIssued(uint256 tokens) private returns(bool) {
        require(_token.transfer(msg.sender,tokens),"tokens transfer faild!");
        emit TokenIssuedTransferred(msg.sender,_curStage,tokens,_etherPrice);
        return true;
    }

    function queryStateInfo() public view
        returns(uint256 curStage,uint256 curStageEther,uint256 curEths,uint256 curCNYs,uint256 curTokens,uint256 etherPrice,uint256 tokenCNYPrice) {
        curStage = _curStage;
        curStageEther = _curStageEther;
        curEths = _curEthers;
        curCNYs = _curCNYs;
        curTokens = _curTokens;
        etherPrice = _etherPrice;
        tokenCNYPrice = _tokenCNYPrice;
    }
    
    function () external payable {
         distributeETH();
    }

    function distributeETH() public payable onlyOnSaling {

        uint256 value = msg.value;
        uint256 cny = wei2CNY(value);
        uint tokens = CNY2TokenByStage(cny, _curStage);
        
        _curStageEther = _curStageEther.add(value);

        //sum eth,cny,tokens
        _curEthers = _curEthers.add(value);
        _curCNYs = _curCNYs.add(cny);
        _curTokens = _curTokens.add(tokens);
        //transfer tokens
        transferTokensIssued(tokens);

        if(_curStageEther >= _stageEtherCap){//stage++
            nextStage();
        }else{

         Investor storage investor = _investors[_curStage][msg.sender];
         if(investor.account != address(0)){ //append invest
            investor.eths = investor.eths.add(value);
            investor.cnys = investor.cnys.add(cny);
            investor.tokens = investor.tokens.add(tokens);
         }else{
            //new investor
           _investors[_curStage][msg.sender] = Investor({
                account:msg.sender,
                  stage:_curStage,
                   eths:value,
                   cnys:cny,
                  tokens:tokens
             });
         }
     }


    }




}