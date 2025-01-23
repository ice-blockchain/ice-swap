import {expect} from "chai";
import {ethers} from "hardhat";
import {Signer} from "ethers";
import {ERC20Mock, IONSwap} from "../typechain-types";

describe("IONSwap Contract", function () {
    let ionSwap: IONSwap;
    let owner: Signer;
    let addr1: Signer;
    let addr2: Signer;
    let pooledToken: ERC20Mock;
    let otherToken: ERC20Mock;
    let decimalsPooledToken: number = 9;
    let decimalsOtherToken: number = 18;

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();

        // Deploy mock tokens for testing
        const ERC20Mock = await ethers.getContractFactory("ERC20Mock");

        // Deploy pooledToken (e.g., ICE v2)
        pooledToken = await ERC20Mock.deploy(
            "Pooled Token",
            "PTKN",
            decimalsPooledToken
        );
        await pooledToken.waitForDeployment();

        // Deploy otherToken (e.g., ICE v1)
        otherToken = await ERC20Mock.deploy(
            "Other Token",
            "OTKN",
            decimalsOtherToken
        );
        await otherToken.waitForDeployment();

        // Deploy the IONSwap contract
        const IONSwap = await ethers.getContractFactory("IONSwap");
        ionSwap = await IONSwap.deploy(
            await owner.getAddress(),
            pooledToken.target,
            otherToken.target
        );
        await ionSwap.waitForDeployment();

        // Mint tokens to owner for liquidity
        const pooledTokenAmount = ethers.parseUnits("1000000", decimalsPooledToken);
        const otherTokenAmount = ethers.parseUnits("1000000", decimalsOtherToken);

        await pooledToken.mint(ionSwap.target, pooledTokenAmount);
        await otherToken.mint(ionSwap.target, otherTokenAmount);

        // Mint tokens to addr1 and addr2 for testing
        await pooledToken.mint(await addr1.getAddress(), pooledTokenAmount);
        await otherToken.mint(await addr1.getAddress(), otherTokenAmount);
    });

    // ... existing tests ...

    describe("Withdraw Liquidity", function () {
        it("Should allow owner to withdraw tokens successfully", async function () {
            const withdrawAmount = ethers.parseUnits("1000", decimalsOtherToken);

            // Initial balance of contract
            const contractBalanceBefore = await otherToken.balanceOf(ionSwap.target);
            expect(contractBalanceBefore).to.be.gte(withdrawAmount);

            // Initial balance of owner
            const ownerAddress = await owner.getAddress();
            const ownerBalanceBefore = await otherToken.balanceOf(ownerAddress);

            // Owner withdraws liquidity
            await ionSwap.connect(owner).withdrawLiquidity(otherToken.target, ownerAddress, withdrawAmount);

            // Check owner's balance increased
            const ownerBalanceAfter = await otherToken.balanceOf(ownerAddress);
            expect(ownerBalanceAfter).to.equal(ownerBalanceBefore + withdrawAmount);

            // Check contract's balance decreased
            const contractBalanceAfter = await otherToken.balanceOf(ionSwap.target);
            expect(contractBalanceAfter).to.equal(contractBalanceBefore - withdrawAmount);
        });

        it("Should emit TokensWithdrawn event on successful withdrawal", async function () {
            const withdrawAmount = ethers.parseUnits("1000", decimalsOtherToken);
            const ownerAddress = await owner.getAddress();

            await expect(
                ionSwap.connect(owner).withdrawLiquidity(otherToken.target, ownerAddress, withdrawAmount)
            )
                .to.emit(ionSwap, "TokensWithdrawn")
                .withArgs(otherToken.target, ownerAddress, withdrawAmount);
        });

        it("Should fail if non-owner tries to withdraw liquidity", async function () {
            const withdrawAmount = ethers.parseUnits("1000", decimalsOtherToken);
            const addr1Address = await addr1.getAddress();
            await expect(
                ionSwap.connect(addr1).withdrawLiquidity(otherToken.target, addr1Address, withdrawAmount)
            )
                .to.be.revertedWithCustomError(ionSwap, "OwnableUnauthorizedAccount")
                .withArgs(addr1Address);
        });

        it("Should fail if withdraw amount is zero", async function () {
            const ownerAddress = await owner.getAddress();

            await expect(
                ionSwap.connect(owner).withdrawLiquidity(otherToken.target, ownerAddress, 0n)
            )
                .to.be.revertedWithCustomError(ionSwap, "WithdrawAmountZero");
        });

        it("Should fail if contract has insufficient token balance", async function () {
            // Withdraw more than the contract's balance
            const contractBalance = await otherToken.balanceOf(ionSwap.target);
            const withdrawAmount = contractBalance + 1n;

            const ownerAddress = await owner.getAddress();

            await expect(
                ionSwap.connect(owner).withdrawLiquidity(otherToken.target, ownerAddress, withdrawAmount)
            )
                .to.be.revertedWithCustomError(ionSwap, "InsufficientTokenBalance");
        });

        it("Should get correct call data from withdrawLiquidityGetData", async function () {
            const withdrawAmount = ethers.parseUnits("1000", decimalsOtherToken);
            const ownerAddress = await owner.getAddress();

            // Get the call data from the contract
            const callData = await ionSwap.withdrawLiquidityGetData(otherToken.target, ownerAddress, withdrawAmount);

            // Expected call data (manually encoded)
            const iface = new ethers.Interface(["function withdrawLiquidity(address _token, address _receiver, uint256 _amount)"]);
            const expectedCallData = iface.encodeFunctionData("withdrawLiquidity", [otherToken.target, ownerAddress, withdrawAmount]);

            expect(callData).to.equal(expectedCallData);
        });
    });
});
