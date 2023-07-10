// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Event is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address public manager;
    string public eventName;
    string public eventLogo;
    string public eventLocation;

    struct Ticket {
        string name;
        uint amount;
        bool transferable;
        uint maxPerWallet;
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

    struct EventData {
        string eventName;
        string eventLogo;
        string eventLocation;
        uint[] dateEvents;
        string[] ticketNames;
        uint[] ticketAmounts;
        bool[] ticketTransferables;
        uint[] ticketMaxPerWallets;
        string[] saleNames;
        uint[] saleDates;
        uint[][] ticketAmountsToSale;
    }

    constructor(EventData memory eventData) ERC721(eventData.eventName, eventData.eventLogo) {
        eventName = eventData.eventName;
        eventLogo = eventData.eventLogo;
        eventLocation = eventData.eventLocation;
        manager = msg.sender;

        for (uint i = 0; i < eventData.dateEvents.length; i++) {
            DailyEvent storage dailyEventData = dailyEvents.push();
            dailyEventData.dateEvent = eventData.dateEvents[i];

            for (uint j = 0; j < eventData.ticketNames.length; j++) {
                Ticket memory ticketData = Ticket(
                    eventData.ticketNames[j],
                    eventData.ticketAmounts[j],
                    eventData.ticketTransferables[j],
                    eventData.ticketMaxPerWallets[j]
                );
                dailyEventData.tickets.push(ticketData);
                dailyEventData.ticketTotal += eventData.ticketAmounts[j];
            }

            for (uint j = 0; j < eventData.saleNames.length; j++) {
                Sale memory saleData = Sale(
                    eventData.saleNames[j],
                    eventData.saleDates[j],
                    eventData.ticketNames,
                    eventData.ticketAmountsToSale[j]
                );
                dailyEventData.sales.push(saleData);
            }

            dailyEventData.ticketAvailable = dailyEventData.ticketTotal;
            dailyEventData.ticketMinted = 0;
            dailyEventData.completedDailyEvent = false;
        }
    }

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    function buyTicket(uint dayIndex, string[] memory ticketNameToBuy, uint[] memory ticketAmountToBuy, uint saleIndex) public {
        DailyEvent storage dailyEventData = dailyEvents[dayIndex];
        // require(block.timestamp > dailyEventData.sales[saleIndex].date, "Ticket War is Not Opened");
        // require(block.timestamp < dailyEventData.dateEvent, "Event is Already Started");
        
        for (uint i = 0; i < ticketNameToBuy.length; i++) {
            Ticket storage ticketData = dailyEventData.tickets[i];  
            require(keccak256(bytes(ticketData.name)) == keccak256(bytes(ticketNameToBuy[i])), string(abi.encodePacked(ticketNameToBuy[i], ": This Ticket is Not Exist")));
            require(ticketData.amount >= ticketAmountToBuy[i], string(abi.encodePacked(ticketData.name, ": Ticket is Not Available To Buy")));
            require(ticketData.maxPerWallet >= ticketAmountToBuy[i], string(abi.encodePacked(ticketData.name, ": You Have Exceeded Max Amount of This Ticket")));

            Sale storage saleData = dailyEventData.sales[saleIndex];
            require(saleData.ticketAmount[i] >= ticketAmountToBuy[i], string(abi.encodePacked(ticketData.name, ": Ticket is Not Available To Buy")));
            
            saleData.ticketAmount[i] -=  ticketAmountToBuy[i];
            dailyEventData.ticketAvailable -= ticketAmountToBuy[i];
            dailyEventData.ticketMinted += ticketAmountToBuy[i];
        }

        // uint256 newItemId = _tokenIds.current();
        // _mint(msg.sender, newItemId);
        // _setTokenURI(newItemId, "ipfs://wkewkej");

        // _tokenIds.increment();
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
