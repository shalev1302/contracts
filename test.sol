    // SPDX-License-Identifier: Barr
    pragma solidity^0.8.4;
    contract purpayInvest{
        address public owner;
        address public seller;
        address public host; 
    
        //Transaction
        address[] transactionFrom;
        uint256[] transactionAmount;
        string[] transactionProduct;
        uint256[] transactionTime;
        uint256[] transactionEthValue;
        bool[] transactionRefund;
        //Withdraw
        string[] withdrawMethods;
        uint256[] withdrawAmounts;
        uint256[] withdrawTimes;

        mapping(address => uint) public balances;


        constructor(address _owner,address _host,address _seller) payable {
            host=_host;
            owner=_owner;
            seller=_seller;
        }

        function chackOwnerBalance() public view returns(uint256){
            return(balances[owner]);
            
        }
        
        function chackSellerBalance() public view returns(uint256){
            return(balances[seller]);
            
        }
        function chackHostBalance() public view returns(uint256){
            return(balances[host]);
            
        }
        function refund(uint id) public payable{
        if(msg.sender==seller&&transactionRefund[id]==false)
        {
            
            payable(transactionFrom[id]).transfer(transactionAmount[id]);
            transactionRefund[id]=true;
            balances[seller]-=transactionAmount[id];
        }
            else revert("you are not the seller");
            
        }

        
        function transfer(string memory product,uint256 EthValue) public payable  {

            transactionFrom.push(msg.sender);
            transactionAmount.push(msg.value);
            transactionProduct.push(product);
            transactionTime.push(block.timestamp);
            transactionEthValue.push(EthValue);
            transactionRefund.push(false);
            uint256 _fee=(msg.value/100)*1;
            balances[seller]+=msg.value-_fee;
            balances[host]+=_fee;
            
        }
        
        function withdrawBalance(string memory method) public payable{
            uint256 value=balances[msg.sender];
            if(msg.sender==seller)
            {
                withdrawAmounts.push(balances[seller]);
                withdrawMethods.push(method);
                withdrawTimes.push(block.timestamp);
            }

            payable(msg.sender).transfer(balances[msg.sender]);
            balances[msg.sender]-=value;
            
        
        }

        
        function getTransactionsCount() public view returns(uint256 )
        {
            return transactionFrom.length;
        }
        function getTransaction(uint256 index) public view returns(address,string memory,uint256,uint256,uint256){
            require(index<=getTransactionsCount(),"transaction doesn't exist ");
            return (transactionFrom[index],transactionProduct[index],transactionAmount[index],transactionTime[index],transactionEthValue[index]);
        }

        function getWithdrawsCount() public view returns(uint256 )
        {
            return withdrawMethods.length;
        }
        function getWithdraw(uint256 index) public view returns(string memory,uint256,uint256 ){
            require(index<=getTransactionsCount(),"withdraw doesn't exist ");
            
            return (withdrawMethods[index],withdrawAmounts[index],withdrawTimes[index]);
        }
        function getWithdrawNew()public view returns( string  [] memory , uint256  [] memory , uint256  [] memory){

        
            return (withdrawMethods,withdrawAmounts,withdrawTimes) ;
        }
        
        function getTransactionNew()public view returns( address  [] memory , uint256  [] memory , string  [] memory,  uint256  [] memory,  uint256  [] memory, bool[] memory){

        
            return (transactionFrom,transactionAmount,transactionProduct,transactionTime,transactionEthValue,transactionRefund) ;
        }
        
    }
