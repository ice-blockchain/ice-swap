import {expect} from "chai";
import {ethers} from "hardhat";
import {ContractFactory} from "ethers";

describe("IONBridgeRouter Constructor", function () {
    let IONBridgeRouterFactory: ContractFactory;
    let MockERC20Factory: ContractFactory;
    let IONSwapFactory: ContractFactory;
    let owner: any;
    let addr1: any;
    let iceV1: any;
    let iceV2: any;
    let ionSwap: any;
    let bridgeAddress: string;

    before(async function () {
        [owner, addr1] = await ethers.getSigners();
        IONBridgeRouterFactory = await ethers.getContractFactory("IONBridgeRouter");
        MockERC20Factory = await ethers.getContractFactory("ERC20Mock");
        IONSwapFactory = await ethers.getContractFactory("IONSwap");

        // Deploy a mock bridge contract (could be any address for testing purposes)
        bridgeAddress = ethers.Wallet.createRandom().address;

        // Deploy mock ICE v1 and ICE v2 ERC20 tokens
        iceV1 = await MockERC20Factory.deploy("ICE V1", "ICEV1", 18);
        await iceV1.waitForDeployment();

        iceV2 = await MockERC20Factory.deploy("ICE V2", "ICEV2", 9);
        await iceV2.waitForDeployment();

        // Deploy IONSwap contract
        ionSwap = await IONSwapFactory.deploy(
            iceV2.target,
            iceV1.target
        );
        await ionSwap.waitForDeployment();
    });

    it("Should deploy successfully with valid addresses", async function () {
        const ionBridgeRouter = await IONBridgeRouterFactory.deploy(
            iceV1.target,
            iceV2.target,
            bridgeAddress,
            ionSwap.target
        );
        await ionBridgeRouter.waitForDeployment();
    });

    it("Should revert when ICE v1 address is zero", async function () {
        await expect(
            IONBridgeRouterFactory.deploy(
                ethers.ZeroAddress,
                iceV2.target,
                bridgeAddress,
                ionSwap.target
            )
        ).to.be.revertedWith("Invalid ICE v1 token address");
    });

    it("Should revert when ICE v2 address is zero", async function () {
        await expect(
            IONBridgeRouterFactory.deploy(
                iceV1.target,
                ethers.ZeroAddress,
                bridgeAddress,
                ionSwap.target
            )
        ).to.be.revertedWith("Invalid ICE v2 token address");
    });

    it("Should revert when bridge address is zero", async function () {
        await expect(
            IONBridgeRouterFactory.deploy(
                iceV1.target,
                iceV2.target,
                ethers.ZeroAddress,
                ionSwap.target
            )
        ).to.be.revertedWith("Invalid Bridge contract address");
    });

    it("Should revert when IONSwap address is zero", async function () {
        await expect(
            IONBridgeRouterFactory.deploy(
                iceV1.target,
                iceV2.target,
                bridgeAddress,
                ethers.ZeroAddress
            )
        ).to.be.revertedWith("Invalid IONSwap contract address");
    });
});
