const VestingVault = artifacts.require("VestingVault")
const Crowdsale = artifacts.require("Crowdsale")
const DOSToken = artifacts.require("DOSToken")

module.exports = async function (deployer, network, accounts) {
  var account0 = accounts[0]
  var account1 = accounts[1]
  if (network === 'ropsten') {
    account0 = '0x78E9D058bDA5F497dfb8E7715e30BdDd67d32D4b'
    account1 = '0xF3B35249Fd03Df13D3c9Be1c3Fc74D7C333d87a0' //bd-wallet-core
  }

  await deployer.deploy(VestingVault)
  const vestingVault = await VestingVault.deployed()

  await deployer.deploy(Crowdsale, 1000, account1, vestingVault.address)
  await Crowdsale.deployed()

  await deployer.deploy(DOSToken,"100000000000000000000000000")
}