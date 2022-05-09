// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./LotteryCore.sol";


/**
  * @title Lottery Generator Smart Contract.
  * @author Batis 
  * @notice This SmartContract is responsible for Lottery Generation.
  * @dev Lottery Generator SmartContract - Parent of Core Lottery
*/
contract LotteryGenerator is Ownable {

    // uint constant TICKET_PRICE = 10 * 1e15; // finney (0.01 Ether)

    enum LType {
        Hourly,
        Daily,
        Weekly,
        Monthly
    }

    address[] public lotteries;
    struct lottery{
        uint index;
        address creator;
        uint totalBalance;
        address winnerAddress; 
        LType lotteryType;
    }
    mapping(address => lottery) lotteryStructs;

    address[] public LotteryWinnersArray;
    struct LotteryWinnerStr{
        uint playersId;
        uint winnerCount;
    }
    mapping (address => LotteryWinnerStr) public LotteryWinnersMap;

    address[] public WeeklyWinnersArray;
    struct WeeklyWinnerStr{
        uint playersId;
        uint winnerCount;
    }
    mapping (address => WeeklyWinnerStr) public WeeklyWinnersMap;

    // event
    event LotteryCreated(address newLottery);

  /* ToDo : Add & Complete Fallback routine */
    fallback() external payable {
    }
    receive() external payable {
    }

    function balanceInPot() public view returns(uint){
        return address(this).balance;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getWinners() public view returns(address[] memory) {
        return LotteryWinnersArray;
    }

    function setlotteryStructs(address _lotteryAddress, uint _totalBalance, address _winnerAddress, uint8 _lotteryType) external returns (bool) {
        lotteryStructs[_lotteryAddress].totalBalance = _totalBalance;
        lotteryStructs[_lotteryAddress].winnerAddress = _winnerAddress;
        lotteryStructs[_lotteryAddress].lotteryType = LType(_lotteryType);
        return true;
    }

    function setlotteryWinnersArrayMap(address _lotteryAddress, address _winnerAddress) external returns (uint) {
        LotteryWinnersArray.push(_winnerAddress);
        LotteryWinnersMap[_winnerAddress].playersId = LotteryWinnersArray.length;  // -1
        LotteryWinnersMap[_winnerAddress].winnerCount++;
        return LotteryWinnersArray.length ;  // -1
    }

    function setWeeklyWinnersArrayMap(address _lotteryAddress, address _winnerAddress) external returns (uint) {
        WeeklyWinnersArray.push(_winnerAddress);
        WeeklyWinnersMap[_winnerAddress].playersId = WeeklyWinnersArray.length;  // -1
        WeeklyWinnersMap[_winnerAddress].winnerCount++;
        return WeeklyWinnersArray.length ;  // -1
    }

    function clearlotteryWinnersArrayMap(address _lotteryAddress) external returns (bool) {
        address _lotteryWinAddress;
        for (uint256 index = 0; index < LotteryWinnersArray.length - 1; index++) {
            _lotteryWinAddress = LotteryWinnersArray[index];
            // if (LotteryWinnersMap[_lotteryWinAddress].playersId > 0) {
            //     LotteryWinnersMap[_lotteryWinAddress].playersId = 0;
            //     LotteryWinnersMap[_lotteryWinAddress].winnerCount = 0;
            // }
            delete LotteryWinnersMap[_lotteryWinAddress];
        }
        delete LotteryWinnersArray;
        return true;
    }

    function clearWeeklyWinnersArrayMap(address _lotteryAddress) external returns (bool) {
        address _lotteryWinAddress;
        for (uint256 index = 0; index < WeeklyWinnersArray.length - 1; index++) {
            _lotteryWinAddress = WeeklyWinnersArray[index];
            // if (WeeklyWinnersMap[_lotteryWinAddress].playersId > 0) {
            //     WeeklyWinnersMap[_lotteryWinAddress].playersId = 0;
            //     WeeklyWinnersMap[_lotteryWinAddress].winnerCount = 0;
            // }
            delete WeeklyWinnersMap[_lotteryWinAddress];
        }
        delete WeeklyWinnersArray;
        return true;
    }


    function createLottery(address _VRF) public onlyOwner {

        // require(bytes(name).length > 0);
        address newLottery = address(new LotteryCore(_VRF));
        lotteries.push(newLottery);
        lotteryStructs[newLottery].index = lotteries.length - 1;
        lotteryStructs[newLottery].creator = msg.sender;
        lotteryStructs[newLottery].totalBalance = 0;
        lotteryStructs[newLottery].winnerAddress = address(0);

        emit LotteryCreated( newLottery );
    }

    // function getLotteries() public view returns(address[]) {
    //     return lotteries;
    // }

    function deleteLottery(address lotteryAddress) public  onlyOwner {
        require(msg.sender == lotteryStructs[lotteryAddress].creator);
        uint indexToDelete = lotteryStructs[lotteryAddress].index;
        address lastAddress = lotteries[lotteries.length - 1];
        lotteries[indexToDelete] = lastAddress;
        // lotteries.length --;
    }

    // Events
    // event LotteryCreated(
    //     address lotteryAddress
    // );
}



