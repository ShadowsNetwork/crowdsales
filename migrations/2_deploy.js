const ProxyERC20 = artifacts.require("ProxyERC20");
const TokenState = artifacts.require("TokenState");
const DosERC20 = artifacts.require("DosERC20");
const SafeDecimalMath = artifacts.require("SafeDecimalMath");

module.exports = async function(deployer, network, accounts) {
  var account = accounts[0];

  await deployer.deploy(ProxyERC20, account);
  const proxy = await ProxyERC20.deployed();

  await deployer.deploy(TokenState, account, account);
  await TokenState.deployed();

  await deployer.deploy(SafeDecimalMath);
  await deployer.link(SafeDecimalMath, DosERC20);
  
  await deployer.deploy(DosERC20, ProxyERC20.address, TokenState.address, account);
  const dos = await DosERC20.deployed();
  
  await proxy.setTarget(dos.address);
  await dos.init();

  console.log("end......");
};
