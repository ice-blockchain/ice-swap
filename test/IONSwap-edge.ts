import {expect} from "chai";
import {ethers} from "hardhat";
import {ContractFactory, Signer} from "ethers";

describe("IONSwap Contract - Error Cases", function () {
    let IONSwapFactory: ContractFactory;
    let ERC20MockFactory: ContractFactory;
    let owner: Signer;
    let addr1: Signer;

    beforeEach(async function () {
        [owner, addr1] = await ethers.getSigners();
        // Get contract factories
        IONSwapFactory = await ethers.getContractFactory("IONSwap");
        ERC20MockFactory = await ethers.getContractFactory("ERC20Mock");
    });

    describe("Constructor", function () {
        it("Should revert with InvalidTokenAddress when pooledToken is address(0)", async function () {
            // Deploy mock otherToken
            const otherTokenDecimals = 18;
            const otherToken = await ERC20MockFactory.deploy(
                "Other Token",
                "OTKN",
                otherTokenDecimals
            );
            await otherToken.waitForDeployment();

            const zeroAddress = ethers.ZeroAddress;

            // Attempt to deploy IONSwap with pooledToken as zero address
            await expect(
                IONSwapFactory.deploy(
                    await owner.getAddress(),
                    zeroAddress,
                    otherToken.target
                )
            ).to.be.revertedWithCustomError(
                IONSwapFactory,
                "InvalidPooledTokenAddress"
            );
        });

        it("Should revert with InvalidTokenAddress when otherToken is address(0)", async function () {
            // Deploy mock pooledToken
            const pooledTokenDecimals = 9;
            const pooledToken = await ERC20MockFactory.deploy(
                "Pooled Token",
                "PTKN",
                pooledTokenDecimals
            );
            await pooledToken.waitForDeployment();

            const zeroAddress = ethers.ZeroAddress;

            // Attempt to deploy IONSwap with otherToken as zero address
            await expect(
                IONSwapFactory.deploy(
                    await owner.getAddress(),
                    pooledToken.target,
                    zeroAddress
                )
            ).to.be.revertedWithCustomError(
                IONSwapFactory,
                "InvalidOtherTokenAddress"
            );
        });

        it("Should revert with TokensMustBeDifferent when pooledToken and otherToken are the same", async function () {
            // Deploy mock token
            const tokenDecimals = 9;
            const token = await ERC20MockFactory.deploy(
                "Token",
                "TKN",
                tokenDecimals
            );
            await token.waitForDeployment();

            // Attempt to deploy IONSwap with same token for both pooledToken and otherToken
            await expect(
                IONSwapFactory.deploy(
                    await owner.getAddress(),
                    token.target,
                    token.target
                )
            ).to.be.revertedWithCustomError(
                IONSwapFactory,
                "TokensMustBeDifferent"
            );
        });
    });

    describe("swapTokens", function () {
        let ionSwap: any;
        let ownerAddress: string;
        let otherToken: any;
        let pooledToken: any;
        let decimalsPooledToken = 9;
        let decimalsOtherToken = 18;

        beforeEach(async function () {
            ownerAddress = await owner.getAddress();

            // Deploy mock tokens
            pooledToken = await ERC20MockFactory.deploy(
                "Pooled Token",
                "PTKN",
                decimalsPooledToken
            );
            await pooledToken.waitForDeployment();

            otherToken = await ERC20MockFactory.deploy(
                "Other Token",
                "OTKN",
                decimalsOtherToken
            );
            await otherToken.waitForDeployment();

            // Deploy IONSwap contract
            ionSwap = await IONSwapFactory.deploy(
                ownerAddress,
                pooledToken.target,
                otherToken.target
            );
            await ionSwap.waitForDeployment();

            // Mint tokens to the contract for liquidity
            const pooledTokenAmount = ethers.parseUnits("1000000", decimalsPooledToken);
            const otherTokenAmount = ethers.parseUnits("1000000", decimalsOtherToken);

            await pooledToken.mint(ionSwap.target, pooledTokenAmount);
            await otherToken.mint(ionSwap.target, otherTokenAmount);

            // Mint tokens to addr1
            await pooledToken.mint(await addr1.getAddress(), pooledTokenAmount);
            await otherToken.mint(await addr1.getAddress(), otherTokenAmount);
        });

        it("Should revert with OutputAmountZero when swap amount is too small for swapTokens", async function () {
            const swapAmount = 1n; // small amount, likely to produce zero output

            // Approve ionSwap contract to spend otherToken
            await otherToken.connect(addr1).approve(ionSwap.target, swapAmount);

            await expect(
                ionSwap.connect(addr1).swapTokens(swapAmount)
            ).to.be.revertedWithCustomError(ionSwap, "OutputAmountZero");
        });
    });

    describe("swapTokensBack", function () {
        let ionSwap: any;
        let ownerAddress: string;
        let otherToken: any;
        let pooledToken: any;
        let decimalsPooledToken = 18;
        let decimalsOtherToken = 9;

        beforeEach(async function () {
            ownerAddress = await owner.getAddress();

            // Deploy mock tokens
            pooledToken = await ERC20MockFactory.deploy(
                "Pooled Token",
                "PTKN",
                decimalsPooledToken
            );
            await pooledToken.waitForDeployment();

            otherToken = await ERC20MockFactory.deploy(
                "Other Token",
                "OTKN",
                decimalsOtherToken
            );
            await otherToken.waitForDeployment();

            // Deploy IONSwap contract
            ionSwap = await IONSwapFactory.deploy(
                ownerAddress,
                pooledToken.target,
                otherToken.target
            );
            await ionSwap.waitForDeployment();

            // Mint tokens to the contract for liquidity
            const pooledTokenAmount = ethers.parseUnits("1000000", decimalsPooledToken);
            const otherTokenAmount = ethers.parseUnits("1000000", decimalsOtherToken);

            await pooledToken.mint(ionSwap.target, pooledTokenAmount);
            await otherToken.mint(ionSwap.target, otherTokenAmount);

            // Mint tokens to addr1
            await pooledToken.mint(await addr1.getAddress(), pooledTokenAmount);
            await otherToken.mint(await addr1.getAddress(), otherTokenAmount);
        });

        it("Should revert with OutputAmountZero when swap amount is too small for swapTokensBack", async function () {
            const swapAmount = 1n; // small amount, likely to produce zero output

            // Approve ionSwap contract to spend pooledToken
            await pooledToken.connect(addr1).approve(ionSwap.target, swapAmount);

            await expect(
                ionSwap.connect(addr1).swapTokensBack(swapAmount)
            ).to.be.revertedWithCustomError(ionSwap, "OutputAmountZero");
        });
    });
});
