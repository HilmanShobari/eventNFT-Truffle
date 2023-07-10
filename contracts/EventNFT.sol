// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract EventNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address public manager;
    string public eventName;
    string public eventLogo;
    string public eventLocation;
    uint public ticketMaxPerWallet;
    uint public allTicketMinted = 0;
    string public baseTokenURI;

    mapping (address => uint) userTicketAmount;

    struct Ticket {
        string name;
        uint amount;
        bool transferable;
    }

    struct Sale {
        string name;
        uint date;
        string[] ticketName;
        uint[] ticketAmount;
    }

    struct DailyEvent {
        uint dateEvent;
        string dateEventName;
        Ticket[] tickets;
        Sale[] sales;
        uint ticketTotal;
        uint ticketAvailable;
        uint ticketMinted;
        bool completedDailyEvent;
    }

    DailyEvent[] public dailyEvents;

    struct SaleData {
        string name;
        uint date;
        uint[] ticketAmount;
    }

    struct EventData {
        string eventName;
        string eventLogo;
        string eventLocation;
        uint[] dateEvents;
        string[] ticketNames;
        uint[] ticketAmounts;
        bool[] ticketTransferables;
        uint ticketMaxPerWallets;
        SaleData[] saleDatas;
        // string[] saleNames;
        // uint[] saleDates;
        // uint[][] ticketAmountsToSale;
    }

    constructor(EventData memory eventData, string memory baseUri_) ERC721(eventData.eventName, eventData.eventLogo) {
        eventName = eventData.eventName;
        eventLogo = eventData.eventLogo;
        eventLocation = eventData.eventLocation;
        ticketMaxPerWallet = eventData.ticketMaxPerWallets;
        manager = msg.sender;
        setBaseURI(baseUri_);

        for (uint i = 0; i < eventData.dateEvents.length; i++) {
            DailyEvent storage dailyEventData = dailyEvents.push();
            dailyEventData.dateEvent = eventData.dateEvents[i];

            for (uint j = 0; j < eventData.ticketNames.length; j++) {
                Ticket memory ticketData = Ticket(
                    eventData.ticketNames[j],
                    eventData.ticketAmounts[j],
                    eventData.ticketTransferables[j]
                );
                dailyEventData.tickets.push(ticketData);
                dailyEventData.ticketTotal += eventData.ticketAmounts[j];
            }

            for (uint j = 0; j < eventData.saleDatas.length; j++) {
                Sale memory saleData = Sale(
                    eventData.saleDatas[j].name,
                    eventData.saleDatas[j].date,
                    eventData.ticketNames,
                    eventData.saleDatas[j].ticketAmount
                );
                dailyEventData.sales.push(saleData);
            }

            // for (uint j = 0; j < eventData.saleNames.length; j++) {
            //     Sale memory saleData = Sale(
            //         eventData.saleNames[j],
            //         eventData.saleDates[j],
            //         eventData.ticketNames,
            //         eventData.ticketAmountsToSale[j]
            //     );
            //     dailyEventData.sales.push(saleData);
            // }

            dailyEventData.ticketAvailable = dailyEventData.ticketTotal;
            dailyEventData.ticketMinted = 0;
            dailyEventData.completedDailyEvent = false;
        }
    }

    modifier onlyManager() {
        require(msg.sender == manager, "You are Not The Manager Of This Event");
        _;
    }

    function setBaseURI(string memory baseTokenURI_) public onlyManager {
        baseTokenURI = baseTokenURI_;
    }

    function _mintSingleNFT() private {
        // if (_tokenIds.current() == 0) {
        //     _tokenIds.increment();
        // }
        // uint newItemId = _tokenIds.current();
        // _setTokenURI(newItemId, "ipfs://wkewkej");
        _safeMint(msg.sender, allTicketMinted + 1);
        allTicketMinted += 1;
    }

    function buyTicket(uint dayIndex, string[] memory ticketNameToBuy, uint[] memory ticketAmountToBuy, uint saleIndex) public {
        DailyEvent storage dailyEventData = dailyEvents[dayIndex];
        // require(block.timestamp > dailyEventData.sales[saleIndex].date, "Ticket War is Not Opened");
        // require(block.timestamp < dailyEventData.dateEvent, "Event is Already Started");

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
            // require(ticketData.maxPerWallet >= ticketAmountToBuy[i], string(abi.encodePacked(ticketData.name, ": You Have Exceeded Max Amount of This Ticket")));

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

    function getContractDetail() public view returns (address, string memory, string memory, string memory) {
        return (
            manager,
            eventName,
            eventLogo,
            eventLocation
        );
    }

}
