const VestingVault = artifacts.require("VestingVault")
const Crowdsale = artifacts.require("Crowdsale")

contract("Crowdsale", async accounts => {
    it("should put 10000 MetaCoin in the first account", async () => {
        const vv = await VestingVault.deployed()
        const crowdsale = await Crowdsale.deployed()
        assert.equal(await crowdsale.getVestingVault(), vv.address);
    })
})