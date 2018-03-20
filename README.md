**NPP Token**
This is a standard ERC20 token, with an additional method for transferring ownership and the remaining tokens

##CrowdSale
This is the contract than manages all ICO related activities

The idea is that during the ICO we don't involve smart contracts; what we do is collect the addresses of investors and their token amounts.

After the ICO, we ask investors to confirm their addresses by sending us 0.0ETH, and then call the *distribute* method to send them tokens.
