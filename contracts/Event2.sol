// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Event2 is ERC721URIStorage {
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

    constructor (
        string memory newEventName,
        string memory newEventLogo,
        string memory newEventLocation,
        uint[] memory newDateEvent,
        string[] memory newTicketName,
        uint[] memory newTicketAmount,
        bool[] memory newTicketTransferable,
        uint[] memory newTicketMaxPerWallet,
        string[] memory newSaleName,
        uint[] memory newSaleDate,
        uint[][] memory newTicketAmountToSale
    ) ERC721(newEventName, newEventLogo) {
        eventName = newEventName;
        eventLogo = newEventLogo;
        eventLocation = newEventLocation;
        manager = msg.sender;

        for (uint i = 0; i < newDateEvent.length; i++) {
            DailyEvent storage dailyEventData = dailyEvents.push();
            dailyEventData.dateEvent = newDateEvent[i];

            for (uint j = 0; j < newTicketName.length; j++) {
                Ticket storage ticketData = dailyEventData.tickets.push();
                ticketData.name = newTicketName[j];
                ticketData.amount = newTicketAmount[j];
                ticketData.transferable = newTicketTransferable[j];
                ticketData.maxPerWallet = newTicketMaxPerWallet[j];
                dailyEventData.ticketTotal += newTicketAmount[j];
            }

            for (uint j = 0; j < newSaleName.length; j++) {
                Sale storage saleData = dailyEventData.sales.push();
                saleData.name = newSaleName[j];
                saleData.date = newSaleDate[j];

                saleData.ticketName = new string[](newTicketName.length);
                saleData.ticketAmount = new uint[](newTicketName.length);
                for (uint k = 0; k < newSaleName.length; k++) {
                    saleData.ticketName[k] = newTicketName[k];
                    saleData.ticketAmount[k] = newTicketAmountToSale[j][k];
                }
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
