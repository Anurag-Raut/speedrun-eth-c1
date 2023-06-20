// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

   bool public openForWithdraw=false;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline ;
  
  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
      deadline = block.timestamp + 80 hours;
  }
 
  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
   mapping(address => uint256) public balances;
   event Stake(address staker,uint256 amount);
   function stake() public payable {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender,msg.value);
   }
    modifier notCompleted() {
        require(!exampleExternalContract.completed(),'already completed');
       
        _;
    }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

  function execute() public notCompleted {
      require(block.timestamp>=deadline, 'Can not execute before deadline');
      if(address(this).balance<threshold){

        openForWithdraw=true;
      }
      else{
          exampleExternalContract.complete{value: address(this).balance}();
      }
    


  }
  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public notCompleted {
    require(openForWithdraw,'Threshold reached');
    uint256 amount=balances[msg.sender];
    balances[msg.sender]=0;
    payable(msg.sender).transfer(amount);


  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
      if(block.timestamp>=deadline){
        return 0;
      }
      else{
        return (deadline-block.timestamp) ;
      }
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
        stake();
    }
}
