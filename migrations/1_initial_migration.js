const Migrations = artifacts.require("Migrations");

module.exports = function (deployer) {
  deployer.deploy(Migrations, ['0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1', '0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1']);
  
};
