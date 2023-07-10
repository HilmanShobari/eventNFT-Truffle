const Migrations = artifacts.require("EventNFTNew");

// module.exports = function (deployer) {
//   deployer.deploy(Migrations, "0x000000000022D473030F116dDEE9F6B43aC78BA3"); //address uniswap permit2
// };

// Event
// module.exports = function (deployer) {
//   deployer.deploy(Migrations, {
//     eventName: "Nama Event",
//     eventLogo: "Logo",
//     eventLocation: "GBK",
//     dateEvents: [1679923200, 1679998800],
//     ticketNames: ["VIP", "Reguler"],
//     ticketAmounts: [100, 50],
//     ticketTransferables: [true, false],
//     ticketMaxPerWallets: 10,
//     saleNames: ["Pre Sale", "On Sale"],
//     saleDates: [1679874000, 1679954000],
//     ticketAmountsToSale: [
//       [30, 20],   // Pre sale
//       [70, 80] // On sale
//     ]
//   });
// };

module.exports = function (deployer) {
  deployer.deploy(Migrations, {
    eventName: "Qoin Event",
    eventLogo: "QOIN LOGO",
    eventLocation: "GBK",
    dateEvents: [1679923200, 1679998800],
    ticketTransferable: true,
    ticketMaxPerWallets: 10,
    ticketDatas: [{
      name: "VIP",
      amount: 50,
      tokenIdFrom: 0,
      tokenId: 0
    }, {
      name: "Reguler",
      amount: 100,
      tokenIdFrom: 0,
      tokenId: 0
    }],
    saleDatas: [{
      name: "Pre Sale",
      date: 1679874000,
      ticketName: ["VIP", "Reguler"],
      ticketAmount: [10, 20]
    }, {
      name: "On Sale",
      date: 1679954000,
      ticketName: ["VIP", "Reguler"],
      ticketAmount: [40, 80]
    }] 
  }, "https://eokreor.com/ticket");
};


// Event2
// module.exports = function (deployer) {
//   deployer.deploy(Migrations,
//     "Nama Event",
//     "Logo",
//     "GBK",
//     [1679923200, 1679998800],
//     ["VIP", "Reguler"],
//     [100, 50],
//     [true, false],
//     [2, 5],
//     ["Pre Sale", "On Sale"],
//     [1679874000, 1679954000],
//     [
//       [30,20],   //Pre sale
//       [70,80]
//     ]
//   );
// };

// 0,["VIP", "Reguler"], [2, 5],0
