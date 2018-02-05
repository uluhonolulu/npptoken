// require('babel-register');
// require('babel-polyfill');

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
      gas: 4000000,
      gasPrice: 200,
      from: "0x852c1e19114b1ff775c59a61b345cc839f3307fd"
    },
    rinkeby_local: {
      network_id: 4,
      host: '127.0.0.1',
      port: 8545,
      gas: 4000000,
      gasPrice: 100000000000,
      from: "0x00cedc57125847fbf50c5e9b46716e3d0969ca1c"
    }
  }
};
