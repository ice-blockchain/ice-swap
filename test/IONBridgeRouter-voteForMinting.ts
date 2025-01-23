import {expect} from "chai";
import {ethers} from "hardhat";
import {ERC20Mock, IONBridgeRouter, IONSwap} from "../typechain-types";

describe("IONBridgeRouter - voteForMinting function", function () {
    let owner: any;
    let addr1: any;
    let iceV1: ERC20Mock;
    let ionSwap: IONSwap;
    let bridge: any; // Our custom TestBridge
    let ionBridgeRouter: IONBridgeRouter;
    const decimalsIceV1 = 18;
    const decimalsIceV2 = 9;

    beforeEach(async function () {
        [owner, addr1] = await ethers.getSigners();

        // Deploy mock ICE v1 and ICE v2 tokens
        const ERC20MockFactory = await ethers.getContractFactory("ERC20Mock");
        iceV1 = await ERC20MockFactory.deploy("ICE v1 Token", "ICEv1", decimalsIceV1);
        await iceV1.waitForDeployment();

        // Deploy the TestBridge contract
        const BridgeDebugger = await ethers.getContractFactory("BridgeDebugger");
        bridge = await BridgeDebugger.deploy("Wrapped ICE v2", "WICEv2", [owner.address]);
        await bridge.waitForDeployment();

        // Deploy the IONSwap contract
        const IONSwapFactory = await ethers.getContractFactory("IONSwap");
        ionSwap = await IONSwapFactory.deploy(
            owner.address,
            bridge.target,
            iceV1.target
        );
        await ionSwap.waitForDeployment();

        // Deploy the IONBridgeRouter contract
        const IONBridgeRouterFactory = await ethers.getContractFactory("IONBridgeRouter");
        ionBridgeRouter = await IONBridgeRouterFactory.deploy(
            iceV1.target,
            bridge.target,
            bridge.target,
            ionSwap.target
        );
        await ionBridgeRouter.waitForDeployment();

        // Mint ICE v1 tokens to addr1 for testing
        const iceV1Amount = ethers.parseUnits("1000000", decimalsIceV1);
        await iceV1.mint(addr1.address, iceV1Amount);

        // Mint ICE v1 and ICE v2 tokens to IONSwap contract for liquidity
        const iceV1AmountForSwap = ethers.parseUnits("2000000", decimalsIceV1);
        const iceV2AmountForSwap = ethers.parseUnits("2000000", decimalsIceV2);

        await iceV1.mint(ionSwap.target, iceV1AmountForSwap);
        await bridge.mintForDebugging(ionSwap.target, iceV2AmountForSwap);
    });

    describe("voteForMinting function", function () {
        it("should swap ICE v2 tokens to ICE v1 after minting", async function () {
            const swapAmount = ethers.parseUnits("1000", decimalsIceV2);

            // Prepare SwapData and Signatures
            const data = {
                receiver: addr1.address,
                amount: swapAmount,
                tx: {
                    address_: {workchain: 0, address_hash: ethers.ZeroHash},
                    tx_hash: ethers.ZeroHash,
                    lt: BigInt(0),
                },
            };

            const signatures: any[] = []; // For the test, we can leave signatures empty

            // Record initial balances
            const addr1IceV1BalanceBefore = await iceV1.balanceOf(addr1.address);
            const addr1IceV2BalanceBefore = await bridge.balanceOf(addr1.address);
            const ionBridgeRouterIceV2BalanceBefore = await bridge.balanceOf(ionBridgeRouter.target);
            const ionBridgeRouterIceV1BalanceBefore = await iceV1.balanceOf(ionBridgeRouter.target);

            // Call voteForMinting
            await bridge.connect(addr1).approve(ionBridgeRouter.target, swapAmount);
            await ionBridgeRouter.connect(addr1).voteForMinting(data, signatures);

            // Record balances after
            const addr1IceV1BalanceAfter = await iceV1.balanceOf(addr1.address);
            const addr1IceV2BalanceAfter = await bridge.balanceOf(addr1.address);
            const ionBridgeRouterIceV2BalanceAfter = await bridge.balanceOf(ionBridgeRouter.target);
            const ionBridgeRouterIceV1BalanceAfter = await iceV1.balanceOf(ionBridgeRouter.target);

            // Expected ICE v1 amount after swapping
            const iceV1Amount = await ionSwap.getOtherAmountOut(swapAmount);

            // Verify that addr1's ICE v1 balance increased by the expected amount
            expect(addr1IceV1BalanceAfter - addr1IceV1BalanceBefore).to.equal(iceV1Amount);

            // Verify that addr1's ICE v2 balance remains the same
            expect(addr1IceV2BalanceAfter).to.equal(addr1IceV2BalanceBefore);

            // Verify that the router's ICE v2 balance should be zero after swapping
            expect(ionBridgeRouterIceV2BalanceAfter).to.equal(0);

            // Verify that the router's ICE v1 balance should be zero after transferring to user
            expect(ionBridgeRouterIceV1BalanceAfter).to.equal(0);
        });

        it("should revert when data.receiver does not match msg.sender", async function () {
            const swapAmount = ethers.parseUnits("1000", decimalsIceV2);

            const data = {
                receiver: owner.address, // Mismatch receiver
                amount: swapAmount,
                tx: {
                    address_: {workchain: 0, address_hash: ethers.ZeroHash},
                    tx_hash: ethers.ZeroHash,
                    lt: BigInt(0),
                },
            };

            const signatures: any[] = [];

            await expect(
                ionBridgeRouter.connect(addr1).voteForMinting(data, signatures)
            ).to.be.revertedWithCustomError(ionBridgeRouter, "UnauthorizedReceiver");
        });
    });
});
