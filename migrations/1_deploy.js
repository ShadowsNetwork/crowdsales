const DOSToken = artifacts.require("DOSToken")
const DOSCrowdsale = artifacts.require("DOSCrowdsale")

module.exports = async function (deployer, network, accounts) {
  var account0 = accounts[0]
  var account1 = accounts[1]
  if (network === 'ropsten') {
    account0 = '0x78E9D058bDA5F497dfb8E7715e30BdDd67d32D4b'
    account1 = '0xF3B35249Fd03Df13D3c9Be1c3Fc74D7C333d87a0' //bd-wallet-core
  }

  await deployer.deploy(DOSToken, '100000000000000000000000000')
  const dos = await DOSToken.deployed()

  //1 eth = 1000 DOS
  await deployer.deploy(DOSCrowdsale, 1000, account1, dos.address, account0)
  const sale = await DOSCrowdsale.deployed()

  await dos.approve(sale.address, '100000000000000000000000000')
}