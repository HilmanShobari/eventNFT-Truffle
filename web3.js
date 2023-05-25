import Web3 from "web3";
 
let web3;
 
if (typeof window !== "undefined" && typeof window.ethereum !== "undefined") {
  // We are in the browser and metamask is running.
  window.ethereum.request({ method: "eth_requestAccounts" });
  web3 = new Web3(window.ethereum);
} else {
  // We are on the server *OR* the user is not running metamask
  const provider = new Web3.providers.HttpProvider(
    "https://polygon-mumbai.g.alchemy.com/v2/vcvZrzGeIs5WzICRvEj3IqaKiVrINq96"
    // "https://sepolia.infura.io/v3/e66c6786fc4e4498b85dad63f994340c"
    // "https://goerli.infura.io/v3/e66c6786fc4e4498b85dad63f994340c"
  );
  web3 = new Web3(provider);
}
 
export default web3;