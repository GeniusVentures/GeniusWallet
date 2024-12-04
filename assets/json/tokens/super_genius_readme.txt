This list will come from github to populate for the "super genius" network.


Will look like this ---

struct NFT {
    string name;            // Token/MFT Name
    string symbol;          // Token/MFT Symbol
    string uri;             // Token/NFT uri for metadata
    uint256 exchangeRate;   // only for withdrawing to GNUS
    uint256 maxSupply;      // maximum supply of NFTs
    address creator;        // the creator of the token
    uint128 childCurIndex;  // the current childNFT count created
    bool nftCreated;        // if there is a mapping/token created
}



TODO:
Don't need for now...

We need to build a bridgeOut for "super genius" network to bridge out the tokens from super genius





FOR NOW BRIDGE OUT FROM A WALLET INTO SUPER GENIUS ...

What super genius networks can we bridge to?




-----------------
Need SDK Changes for this--
call balanceOf like normal 
-but can also pass tokenId to get children token balances

----------------------------






-- 

change the swap to be a bridge only for now.


1. On Genius token only add a bridge button, 

// Need SDK changes to get balances.. need lists / icons for these from Ken
2. populate children tokens as well...
3. if rpc URL is empty call the sdk.




change the network...

- dest network
any network..





ADD BRIDGING FROM TESTNET TO TESTNET ONLY
poly testnet to supergenius testnet

eth testnet  to supergenius testnet





poly to supergenius
bridgeOut(amount, destChainId, tokenId)

any destChainId
tokenId = 0, for now.




ADD Binance, Base

Testnets as well.





  {
    "name": "Super Genius",
    "symbol": "gnus",
    "chainId": 50070933806,
    "rpcUrl": "",
    "iconPath": "assets/images/crypto/sgnus.png"
  },
  {
    "name": "Super Genius - Test",
    "symbol": "gnus_test",
    "chainId": 15305752297694,
    "rpcUrl": "",
    "iconPath": "assets/images/crypto/sgnus.png"
  }