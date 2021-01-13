const VestingVault = artifacts.require("VestingVault")
const Crowdsale = artifacts.require("Crowdsale")
const DOSToken = artifacts.require("DOSToken")

const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');

contract("Crowdsale", async accounts => {
    it("should put 10000 MetaCoin in the first account", async () => {
        const vestingVault = await VestingVault.deployed()
        const crowdsale = await Crowdsale.deployed()
        const dos = await DOSToken.deployed()
        assert.equal(await crowdsale.getVestingVault(), vestingVault.address);

        //init
        vestingVault.setAssociateContract(crowdsale.address)
        vestingVault.setTokenWallet(accounts[0])
        vestingVault.setToken(dos.address)

        //approve
        dos.approve(vestingVault.address, "1000000000000000000000000")

        //buy token
        const sendTx = await crowdsale.send(web3.utils.toWei('1', "ether"))
        expectEvent(sendTx, 'TokensPurchased', {
            beneficiary: accounts[0],
            amount: new BN("1000000000000000000000"),
        });
        assert.equal((await vestingVault.getGrantAmount(accounts[0])).toString(), "1000000000000000000000")

        //claim
        await expectRevert(
            vestingVault.claimVestedTokens(),
            'claim has not yet started',
        );

        //calculate
        var vested = await vestingVault.calculateGrantClaim(accounts[0])
        assert.equal(vested[0], 0);
        assert.equal(vested[1], 0);

        const currentTime = Math.floor(Date.now() / 1000);
        await vestingVault.setClaimBeginTime(currentTime + 86400);//future
        var vested = await vestingVault.calculateGrantClaim(accounts[0])
        assert.equal(vested[0], 0);
        assert.equal(vested[1], 0);

        await vestingVault.setClaimBeginTime(currentTime);//current
        var vested = await vestingVault.calculateGrantClaim(accounts[0])
        assert.equal(vested[0], 1); //1 days
        assert.equal(vested[1].toString(), "100000000000000000000"); //100 tokens

        await vestingVault.setClaimBeginTime(currentTime - 86401);//yesterday
        var vested = await vestingVault.calculateGrantClaim(accounts[0])
        assert.equal(vested[0], 2); //2 days
        assert.equal(vested[1].toString(), "200000000000000000000"); //200 tokens

        await vestingVault.setClaimBeginTime(currentTime - 86400 * 11);//end
        var vested = await vestingVault.calculateGrantClaim(accounts[0])
        assert.equal(vested[0], 10); //12 days but return 10 days
        assert.equal(vested[1].toString(), "1000000000000000000000"); //1000 tokens

        await vestingVault.claimVestedTokens();
    })
})