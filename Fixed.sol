// SPDX-License-Identifier: Barr
pragma solidity^0.8.4;
import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract purpayFixed{
    bool deployed=false;
    address public owner;
    address public host; 
    struct Transaction {
        address from;
        uint256 ammount;
        string product;
        string time;
        uint EthValue;    
    }
    struct Withdraw {
        string method;
        uint256 ammount;
        string time;
    }
    mapping(address => uint) public balances;
    mapping(address => Transaction[]) public transactions;
    mapping(address => Withdraw[]) public withdraws;
    address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D ;
    IUniswapV2Router02 public uniswapRouter;
    address private multiDaiKovan = 0x2973e69b20563bcc66dC63Bde153072c33eF37fe ;
    constructor() payable {
        deployed=true;
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
        host=0x6B55CFF320E8E1c44D21760D68E02dB41017CB11;
        owner=msg.sender;
    }

    function chackOwnerBalance() public view returns(uint256){
        return(balances[owner]);
        
    }
    function refund(uint id) public payable{
       Transaction memory transaction=transactions[msg.sender][id];
        ERC20(0xFE724a829fdF12F7012365dB98730EEe33742ea2).transfer(transaction.from,transaction.ammount);
        balances[owner]-= transaction.ammount;
    }
    function chackHostBalance() public view returns(uint256){
        return(balances[host]);
        
    }

    function transfer(string memory product,string memory time, uint256 EthValue) public payable  {
        Transaction memory trans = Transaction(msg.sender, msg.value,product, time,EthValue );
        uint deadline = block.timestamp + 15; 
        uint256 _fee=(msg.value/100)*1;

      
        balances[owner]+=uniswapRouter.swapExactETHForTokens{ value: msg.value-_fee }(0, getPathForETHtoDAI(), address(this), deadline)[1];
        balances[host]+=_fee;
        transactions[owner].push(trans);
    }
    
    function withdrawBalance(string memory method,string memory time) public payable{
    
        uint256 value=balances[msg.sender];
        Withdraw memory with = Withdraw(method, balances[owner], time );
        //TODO:SWAP TO ETH AND WITHDRAW ETH
        ERC20(0xFE724a829fdF12F7012365dB98730EEe33742ea2).transfer(msg.sender, balances[msg.sender]);

        balances[msg.sender]-=value;
        withdraws[owner].push(with);
    }

    
    function getTransactionsCount() public view returns(uint256 )
    {
        
        Transaction[] memory trans=transactions[msg.sender];

        return trans.length;
    }
    function getTransaction(uint256 index) public view returns(address,string memory,uint256,string memory,uint256){
        require(index<=getTransactionsCount(),"transaction doesn't exist ");
        return (transactions[msg.sender][index].from,transactions[msg.sender][index].product,transactions[msg.sender][index].ammount,transactions[msg.sender][index].time,transactions[msg.sender][index].EthValue);
    }

    function getWithdrawsCount() public view returns(uint256 )
    {
        
        Withdraw[] memory with=withdraws[msg.sender];

        return with.length;
    }
    function getWithdraw(uint256 index) public view returns(string memory,uint256,string memory){
        require(index<=getTransactionsCount(),"withdraw doesn't exist ");
        return (withdraws[msg.sender][index].method,withdraws[msg.sender][index].ammount,withdraws[msg.sender][index].time);
    }
  
   

  
  function getEstimatedETHforDAI(uint daiAmount) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsIn(daiAmount, getPathForETHtoDAI());
  }

  function getPathForETHtoDAI() private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = multiDaiKovan;
    
    return path;
  }
    
}
