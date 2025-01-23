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

    describe("Deployment", function () {
        it("Should set the correct token addresses", async function () {
            expect(await ionSwap.pooledToken()).to.equal(pooledToken.target);
            expect(await ionSwap.otherToken()).to.equal(otherToken.target);
        });

        it("Should set the correct exchange rates", async function () {
            const pooledTokenRate = await ionSwap.pooledTokenRate();
            const otherTokenRate = await ionSwap.otherTokenRate();

            // In Ethers v6, these calls return 'bigint'
            // So we can compare them to BigInt(10) ** BigInt(decimals)
            expect(pooledTokenRate).to.equal(BigInt(10) ** BigInt(decimalsPooledToken));
            expect(otherTokenRate).to.equal(BigInt(10) ** BigInt(decimalsOtherToken));
        });
    });

    describe("swapTokens (Forward Swap)", function () {
        it("Should swap otherToken for pooledToken correctly", async function () {
            // parseUnits returns a bigint in Ethers v6
            const swapAmount = ethers.parseUnits("1000", decimalsOtherToken);

            // Approve ionSwap contract to spend otherToken
            await otherToken.connect(addr1).approve(ionSwap.target, swapAmount);

            // Get initial balances (also bigint)
            const initialPooledTokenBalance = await pooledToken.balanceOf(await addr1.getAddress());

            // Perform the swap
            await ionSwap.connect(addr1).swapTokens(swapAmount);

            // Calculate expected pooledToken received
            // big exponent = (10^decimals)
            const forwardRate = BigInt(10) ** BigInt(decimalsPooledToken);
            const reverseRate = BigInt(10) ** BigInt(decimalsOtherToken);
            const expectedPooledTokenAmount =
                (swapAmount * forwardRate) / reverseRate;

            // Get final balances
            const finalPooledTokenBalance = await pooledToken.balanceOf(await addr1.getAddress());

            expect(finalPooledTokenBalance - initialPooledTokenBalance)
                .to.equal(expectedPooledTokenAmount);
        });

        it("Should fail if swap amount is zero", async function () {
            await expect(ionSwap.connect(addr1).swapTokens(0n))
                .to.be.revertedWithCustomError(ionSwap, "SwapAmountZero");
        });

        it("Should fail if output amount is zero due to small input", async function () {
            const swapAmount = 1n; // Smaller than decimals can handle

            // Approve ionSwap contract to spend otherToken
            await otherToken.connect(addr1).approve(ionSwap.target, swapAmount);

            const result = ionSwap.connect(addr1).swapTokens(swapAmount);
            await expect(result).to.be.revertedWithCustomError(ionSwap, "OutputAmountZero()");
        });

        it("Should fail if pooledToken balance is insufficient", async function () {
            // Large amount
            const swapAmount = ethers.parseUnits("1000000000", decimalsOtherToken);

            // Approve ionSwap contract to spend otherToken
            await otherToken.connect(addr1).approve(ionSwap.target, swapAmount);

            await expect(ionSwap.connect(addr1).swapTokens(swapAmount))
                .to.be.revertedWithCustomError(ionSwap, "InsufficientPooledTokenBalance");
        });
    });

    describe("swapTokensBack (Reverse Swap)", function () {
        it("Should swap pooledToken back to otherToken correctly", async function () {
            const swapAmount = ethers.parseUnits("1000", decimalsPooledToken);

            // Approve ionSwap contract to spend pooledToken
            await pooledToken.connect(addr1).approve(ionSwap.target, swapAmount);

            // Get initial balances
            const initialOtherTokenBalance = await otherToken.balanceOf(await addr1.getAddress());

            // Perform the swap back
            await ionSwap.connect(addr1).swapTokensBack(swapAmount);

            // Calculate expected otherToken received
            const forwardRate = BigInt(10) ** BigInt(decimalsPooledToken);
            const reverseRate = BigInt(10) ** BigInt(decimalsOtherToken);

            const expectedOtherTokenAmount =
                (swapAmount * reverseRate) / forwardRate;

            // Get final balances
            const finalOtherTokenBalance = await otherToken.balanceOf(await addr1.getAddress());

            expect(finalOtherTokenBalance - initialOtherTokenBalance)
                .to.equal(expectedOtherTokenAmount);
        });

        it("Should fail if swap back amount is zero", async function () {
            await expect(ionSwap.connect(addr1).swapTokensBack(0n))
                .to.be.revertedWithCustomError(ionSwap, "SwapAmountZero");
        });

        // Optional: If we want to test reverse swap with zero output,
        // we'd need a much larger decimal difference
        it("Should not fail with minimum input amount for reverse swap", async function () {
            const swapAmount = 1n; // 1 wei of the 9-decimal token

            // Approve ionSwap contract to spend pooledToken (9 decimals)
            await pooledToken.connect(addr1).approve(ionSwap.target, swapAmount);

            // This should actually succeed
            await expect(ionSwap.connect(addr1).swapTokensBack(swapAmount))
                .to.not.be.reverted;
        });

        it("Should fail if otherToken balance is insufficient", async function () {
            const swapAmount = ethers.parseUnits("1000000000", decimalsPooledToken);

            // Approve ionSwap contract to spend pooledToken
            await pooledToken.connect(addr1).approve(ionSwap.target, swapAmount);

            await expect(ionSwap.connect(addr1).swapTokensBack(swapAmount))
                .to.be.revertedWithCustomError(ionSwap, "InsufficientOtherTokenBalance");
        });
    });

    describe("Edge Cases", function () {
        it("Should fail if user has insufficient otherToken balance", async function () {
            const swapAmount = ethers.parseUnits("1000", decimalsOtherToken);

            // Transfer all otherToken from addr1 to addr2
            const addr1Balance = await otherToken.balanceOf(await addr1.getAddress());
            await otherToken.connect(addr1).transfer(await addr2.getAddress(), addr1Balance);

            // Approve ionSwap contract to spend otherToken
            await otherToken.connect(addr1).approve(ionSwap.target, swapAmount);

            const result = ionSwap.connect(addr1).swapTokens(swapAmount);
            await expect(result).to.be.revertedWithCustomError(otherToken, 'ERC20InsufficientBalance');
        });

        it("Should fail if user has not approved otherToken", async function () {
            const swapAmount = ethers.parseUnits("1000", decimalsOtherToken);
            const result = ionSwap.connect(addr1).swapTokens(swapAmount);
            await expect(result).to.be.revertedWithCustomError(pooledToken, 'ERC20InsufficientAllowance');
        });

        it("Should fail if user has insufficient pooledToken balance when swapping back", async function () {
            const swapAmount = ethers.parseUnits("1000000", decimalsPooledToken);

            // Transfer all pooledToken from addr1 to addr2
            const addr1Balance = await pooledToken.balanceOf(await addr1.getAddress());
            await pooledToken.connect(addr1).transfer(await addr2.getAddress(), addr1Balance);

            // Approve ionSwap contract to spend pooledToken
            await pooledToken.connect(addr1).approve(ionSwap.target, swapAmount);
            const result = ionSwap.connect(addr1).swapTokensBack(swapAmount);
            await expect(result).to.be.revertedWithCustomError(pooledToken, 'ERC20InsufficientBalance');
        });

        it("Should fail if user has not approved pooledToken when swapping back", async function () {
            const swapAmount = ethers.parseUnits("1000", decimalsPooledToken);
            const result = ionSwap.connect(addr1).swapTokensBack(swapAmount);
            await expect(result).to.be.revertedWithCustomError(pooledToken, 'ERC20InsufficientAllowance');
        });
    });
});
