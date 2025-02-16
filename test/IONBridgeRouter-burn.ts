import {expect} from "chai";
import {ethers} from "hardhat";
import {BridgeDebugger, ERC20Mock, IONBridgeRouter, IONSwap} from "../typechain-types";

const ION_ADDRESS_HASH = "0x1825c553bc67ed4daffe789c921ffec7e3005ef88ce3b58f4e5a73af6dcd08d4";

describe("IONBridgeRouter - burn function", function () {
    let owner: any;
    let addr1: any;
    let iceV1: ERC20Mock;
    let ionSwap: IONSwap;
    let bridge: BridgeDebugger;
    let ionBridgeRouter: IONBridgeRouter;

    beforeEach(async function () {
        [owner, addr1] = await ethers.getSigners();

        // Deploy mock ICE v1 and ICE v2 tokens
        const ERC20Mock = await ethers.getContractFactory("ERC20Mock");
        iceV1 = await ERC20Mock.deploy("ICE v1 Token", "ICEv1", 18);
        await iceV1.waitForDeployment();

        // Deploy the BridgeDebugger contract
        const BridgeDebuggerFactory = await ethers.getContractFactory("BridgeDebugger");
        bridge = await BridgeDebuggerFactory.deploy("Wrapped ICE v2", "WICEv2", [owner.address]);
        await bridge.waitForDeployment();

        // Deploy IONSwap contract
        const IONSwapFactory = await ethers.getContractFactory("IONSwap");
        ionSwap = await IONSwapFactory.deploy(
            bridge.target, // pooledToken
            iceV1.target  // otherToken
        );
        await ionSwap.waitForDeployment();

        // Pre-fund IONSwap & Bridge with ICE v2 tokens
        const iceV2AmountForSwap = ethers.parseUnits("1000000", 9);
        await bridge.mintForDebugging(ionSwap.target, iceV2AmountForSwap);

        // Deploy IONBridgeRouter contract
        const IONBridgeRouterFactory = await ethers.getContractFactory("IONBridgeRouter");
        ionBridgeRouter = await IONBridgeRouterFactory.deploy(
            iceV1.target,
            bridge.target,
            bridge.target,
            ionSwap.target
        );
        await ionBridgeRouter.waitForDeployment();

        // Mint ICE v1 tokens to addr1 for testing
        const iceV1Amount = ethers.parseUnits("1000", 18); // 1000 ICE v1
        await iceV1.mint(addr1.address, iceV1Amount);
    });

    describe("burn function", function () {
        it("should burn ICE v1 tokens and bridge them", async function () {
            const amount = ethers.parseUnits("100", 18); // Burn 100 ICE v1 tokens

            // Construct an IONAddress
            const ionAddress = {
                workchain: 0,
                address_hash: ION_ADDRESS_HASH,
            };


            // Record initial balances
            const addr1IceV1BalanceBefore = await iceV1.balanceOf(addr1.address);
            const addr1IceV2BalanceBefore = await bridge.balanceOf(addr1.address);
            const ionBridgeRouterIceV1BalanceBefore = await iceV1.balanceOf(ionBridgeRouter.target);
            const ionBridgeRouterIceV2BalanceBefore = await bridge.balanceOf(ionBridgeRouter.target);
            const ionSwapIceV1BalanceBefore = await iceV1.balanceOf(ionSwap.target);
            const ionSwapIceV2BalanceBefore = await bridge.balanceOf(ionSwap.target);
            const bridgeIceV2BalanceBefore = await bridge.balanceOf(bridge.target);

            // Calculate the expected ICE v2 amount after swapping
            const iceV2Amount = await ionSwap.getPooledAmountOut(amount);

            // Call burn function
            await iceV1.connect(addr1).approve(ionBridgeRouter.target, amount);
            await ionBridgeRouter.connect(addr1).burn(amount, ionAddress);

            // Record balances after burn
            const addr1IceV1BalanceAfter = await iceV1.balanceOf(addr1.address);
            const addr1IceV2BalanceAfter = await bridge.balanceOf(addr1.address);
            const ionBridgeRouterIceV1BalanceAfter = await iceV1.balanceOf(ionBridgeRouter.target);
            const ionBridgeRouterIceV2BalanceAfter = await bridge.balanceOf(ionBridgeRouter.target);
            const ionSwapIceV1BalanceAfter = await iceV1.balanceOf(ionSwap.target);
            const ionSwapIceV2BalanceAfter = await bridge.balanceOf(ionSwap.target);
            const bridgeIceV2BalanceAfter = await bridge.balanceOf(bridge.target);

            // Check balances
            // addr1's ICE v1 balance decreased by amount
            expect(addr1IceV1BalanceAfter).to.equal(addr1IceV1BalanceBefore - amount);
            // addr1's ICE v2 balance remains the same
            expect(addr1IceV2BalanceAfter).to.equal(addr1IceV2BalanceBefore);
            // IONBridgeRouter's ICE v1 balance should be zero after burn
            expect(ionBridgeRouterIceV1BalanceAfter).to.equal(0n);
            // IONBridgeRouter's ICE v2 balance should be zero after burn
            expect(ionBridgeRouterIceV2BalanceAfter).to.equal(0n);
            // IONSwap's ICE v1 balance increased by amount
            expect(ionSwapIceV1BalanceAfter).to.equal(ionSwapIceV1BalanceBefore + amount);
            // IONSwap's ICE v2 balance decreased by iceV2Amount
            expect(ionSwapIceV2BalanceAfter).to.equal(ionSwapIceV2BalanceBefore - iceV2Amount);
            // Bridge's ICE v2 balance increased by iceV2Amount (burned in the bridge)
            expect(bridgeIceV2BalanceAfter).to.equal(bridgeIceV2BalanceBefore);

            // Since the bridge contract burns the tokens, its ICE v2 balance should remain the same
            // Verify events or other state changes as needed
        });

        it("should revert when amount is zero", async function () {
            const amount = 0n;
            const ionAddress = {
                workchain: 0,
                address_hash: ION_ADDRESS_HASH,
            };

            await expect(
                ionBridgeRouter.connect(addr1).burn(amount, ionAddress)
            ).to.be.revertedWithCustomError(ionBridgeRouter, "InvalidAmount");
        });

        it("should revert when user has not approved ICE v1 tokens", async function () {
            const amount = ethers.parseUnits("100", 18);
            const ionAddress = {
                workchain: 0,
                address_hash: ION_ADDRESS_HASH,
            };
            // Do not approve ICE v1 tokens

            await expect(
                ionBridgeRouter.connect(addr1).burn(amount, ionAddress)
            ).to.be.revertedWithCustomError(iceV1, "ERC20InsufficientAllowance")
                .withArgs(
                    ionBridgeRouter.target,
                    0n,
                    amount
                );
        });

        it("should revert when user has insufficient ICE v1 balance", async function () {
            const amount = ethers.parseUnits("2000", 18); // User has only 1000 ICE v1
            const ionAddress = {
                workchain: 0,
                address_hash: ION_ADDRESS_HASH,
            };

            // User approves the amount
            await iceV1.connect(addr1).approve(ionBridgeRouter.target, amount);

            await expect(
                ionBridgeRouter.connect(addr1).burn(amount, ionAddress)
            ).to.be.revertedWithCustomError(iceV1, "ERC20InsufficientBalance")
                .withArgs(
                    addr1.address,
                    await iceV1.balanceOf(addr1.address), // Should be 1000 * 1e18
                    amount
                );
        });
    });
});
