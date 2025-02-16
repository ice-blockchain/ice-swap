import {expect} from "chai";
import {ethers} from "hardhat";
import {ERC20Mock, IONSwap} from "../typechain-types";
import {Signer} from "ethers";

describe("IONSwap Contract - receive and fallback", function () {
    let ionSwap: IONSwap;
    let pooledToken: ERC20Mock;
    let otherToken: ERC20Mock;
    let owner: Signer;
    let addr1: Signer;
    let pooledTokenDecimals = 9;
    let otherTokenDecimals = 18;

    beforeEach(async function () {
        [owner, addr1] = await ethers.getSigners();

        // Deploy mock tokens for testing
        const ERC20MockFactory = await ethers.getContractFactory("ERC20Mock");

        pooledToken = await ERC20MockFactory.deploy("Pooled Token", "PTKN", pooledTokenDecimals);
        await pooledToken.waitForDeployment();

        otherToken = await ERC20MockFactory.deploy("Other Token", "OTKN", otherTokenDecimals);
        await otherToken.waitForDeployment();

        // Deploy the IONSwap contract
        const IONSwapFactory = await ethers.getContractFactory("IONSwap");
        ionSwap = await IONSwapFactory.deploy(
            pooledToken.target,
            otherToken.target
        );
        await ionSwap.waitForDeployment();
    });

    it("Should revert when sending Ether via receive()", async function () {
        // Try to send Ether to the contract without any data (this will trigger receive())
        const tx = owner.sendTransaction({
            to: ionSwap.target,
            value: ethers.parseEther("1.0") // Sending 1 ETH
        });

        await expect(tx)
            .to.be.revertedWithCustomError(ionSwap, "EtherNotAccepted");
    });

    it("Should revert when calling non-existent function via fallback()", async function () {
        // Try to call a non-existent function (this will trigger fallback())
        const nonExistentFunctionSignature = "0x12345678";
        const tx = owner.sendTransaction({
            to: ionSwap.target,
            data: nonExistentFunctionSignature // Some random data
        });

        await expect(tx)
            .to.be.revertedWithCustomError(ionSwap, "EtherNotAccepted");
    });
});
