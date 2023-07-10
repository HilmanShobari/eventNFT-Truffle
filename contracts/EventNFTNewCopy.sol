// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract EventNFTNewCopy is Ownable, ERC721URIStorage {
    address public manager;
    string public eventName;
    string public eventLogo;
    string public eventLocation;
    uint public ticketMaxPerWallet;
    uint public allTicketMinted = 0;
    string public baseTokenURI;
    bool public ticketTransferable;

    mapping (address => uint) userTicketAmount;

    struct Ticket {
        string name;
        uint amount;
    }

    struct Sale {
        string name;
        uint date;
        string[] ticketName;
        uint[] ticketAmount;
    }

    struct DailyEvent {
        uint dateEvent;
        Ticket[] tickets;
        Sale[] sales;
        uint ticketTotal;
        uint ticketAvailable;
        uint ticketMinted;
        bool completedDailyEvent;
    }

    DailyEvent[] public dailyEvents;
    Ticket[] public tickets;
    Sale[] public sales;

    struct EventData {
        string eventName;
        string eventLogo;
        string eventLocation;
        uint[] dateEvents;
        bool ticketTransferable;
        uint ticketMaxPerWallets;
        Ticket[] ticketDatas;
        Sale[] saleDatas;
    }

    constructor(EventData memory eventData, string memory baseUri_) ERC721(eventData.eventName, eventData.eventLogo) {
        eventName = eventData.eventName;
        eventLogo = eventData.eventLogo;
        eventLocation = eventData.eventLocation;
        ticketTransferable = eventData.ticketTransferable;
        ticketMaxPerWallet = eventData.ticketMaxPerWallets;
        manager = msg.sender;
        setBaseURI(baseUri_);

        for (uint i = 0; i < eventData.dateEvents.length; i++) {
            DailyEvent storage dailyEventData = dailyEvents.push();
            dailyEventData.dateEvent = eventData.dateEvents[i];

            for (uint j = 0; j < eventData.ticketDatas.length; j++) {
                Ticket memory ticketData = Ticket(
                    eventData.ticketDatas[j].name,
                    eventData.ticketDatas[j].amount
                );
                dailyEventData.tickets.push(ticketData);
                dailyEventData.ticketTotal += eventData.ticketDatas[j].amount;
            }

            for (uint j = 0; j < eventData.saleDatas.length; j++) {
                Sale memory saleData = Sale(
                    eventData.saleDatas[j].name,
                    eventData.saleDatas[j].date,
                    eventData.saleDatas[j].ticketName,
                    eventData.saleDatas[j].ticketAmount
                );
                dailyEventData.sales.push(saleData);
            }

            dailyEventData.ticketAvailable = dailyEventData.ticketTotal;
            dailyEventData.ticketMinted = 0;
            dailyEventData.completedDailyEvent = false;
        }
    }

    function setBaseURI(string memory baseTokenURI_) public onlyOwner {
        baseTokenURI = baseTokenURI_;
    }

    function _mintSingleNFT() private {
        _safeMint(msg.sender, allTicketMinted + 1);
        allTicketMinted += 1;
    }

    function buyTicket(uint dayIndex, string[] memory ticketNameToBuy, uint[] memory ticketAmountToBuy, uint saleIndex) public {
        DailyEvent storage dailyEventData = dailyEvents[dayIndex];

        uint ticketTotal;
        for (uint i = 0; i < ticketAmountToBuy.length; i++) {
            ticketTotal += ticketAmountToBuy[i];
        }

        require(ticketMaxPerWallet >= ticketTotal, string(abi.encodePacked("You Have Exceeded Max Amount of Ticket")));
        userTicketAmount[msg.sender] = ticketTotal;
        
        for (uint i = 0; i < ticketNameToBuy.length; i++) {
            Ticket storage ticketData = dailyEventData.tickets[i];  
            require(keccak256(bytes(ticketData.name)) == keccak256(bytes(ticketNameToBuy[i])), string(abi.encodePacked(ticketNameToBuy[i], ": This Ticket is Not Exist")));
            require(ticketData.amount >= ticketAmountToBuy[i], string(abi.encodePacked(ticketData.name, ": Ticket is Not Available To Buy")));

            Sale storage saleData = dailyEventData.sales[saleIndex];
            require(saleData.ticketAmount[i] >= ticketAmountToBuy[i], string(abi.encodePacked(ticketData.name, ": Ticket is Not Available To Buy")));
            
            saleData.ticketAmount[i] -=  ticketAmountToBuy[i];
            dailyEventData.ticketAvailable -= ticketAmountToBuy[i];
            dailyEventData.ticketMinted += ticketAmountToBuy[i];
        }

        for (uint i = 0 ; i < ticketTotal; i++) {
            _mintSingleNFT();
        }
        
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId, uint batchSize) internal view override {
        require(ticketTransferable == true, "Ticket is Not Transferable");
    }

    function getStructDetail(uint index) public view returns (uint, Ticket[] memory, Sale[] memory, uint, uint, uint, bool) {
        DailyEvent storage dailyEventData = dailyEvents[index];
        return (
            dailyEventData.dateEvent,
            dailyEventData.tickets,
            dailyEventData.sales,
            dailyEventData.ticketTotal,
            dailyEventData.ticketAvailable,
            dailyEventData.ticketMinted,
            dailyEventData.completedDailyEvent
        );
    }

    function getContractDetail() public view returns (address, string memory, string memory, string memory, bool, uint, uint, string memory) {
        return (
            manager,
            eventName,
            eventLogo,
            eventLocation,
            ticketTransferable,
            ticketMaxPerWallet,
            allTicketMinted,
            baseTokenURI
        );
    }

}
