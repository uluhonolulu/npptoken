module.exports = {
  networks: {
    // development: {
    //   host: "localhost",
    //   port: 8545,
    //   network_id: "*" // Match any network id
    // },
    live: {
      host: "localhost",
      port: 8545,
      network_id: 1,
      from: "0xa419263605acf191f4423a7cd38d133b04beab1c",
      //gas: 2000000,
      gasPrice: 2000000000
    },
    rinkeby: {
      network_id: 4,
      host: '10.21.0.94',
      port: 8545,
      gas: 4000000
    }
  }
};
