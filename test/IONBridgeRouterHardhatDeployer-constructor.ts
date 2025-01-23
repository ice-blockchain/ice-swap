import { expect } from "chai";
import { ethers } from "hardhat";
import { Bridge, IONBridgeRouterHardhatDeployer } from "../typechain-types";

describe("IONBridgeRouter Deployment Test", function () {
    it("Should deploy Bridge and IONBridgeRouterHardhatDeployer contracts correctly", async function () {
        // Get signers
        const [owner] = await ethers.getSigners();

        // Deploy the Bridge contract
        const BridgeFactory = await ethers.getContractFactory("Bridge", owner);

        // The Bridge constructor takes the following parameters:
        // constructor(string memory name_, string memory symbol_, address[] memory initialSet)
        // Provide the token name, symbol, and an array of initial oracle addresses

        const name = "Wrapped ION";
        const symbol = "WION";
        const initialSet = [owner.address]; // Initial set of oracles

        const bridge: Bridge = await BridgeFactory.deploy(name, symbol, initialSet);
        await bridge.waitForDeployment();

        // Now, deploy the IONBridgeRouterHardhatDeployer, passing the Bridge address
        const IONBridgeRouterHardhatDeployerFactory = await ethers.getContractFactory(
            "IONBridgeRouterHardhatDeployer",
            owner
        );

        const deployer: IONBridgeRouterHardhatDeployer = await IONBridgeRouterHardhatDeployerFactory.deploy(
            bridge.target
        );
        await deployer.waitForDeployment();

        // Retrieve the addresses of the deployed contracts from the deployer
        const iceTokenAddress = await deployer.getICEToken();
        const ionSwapAddress = await deployer.getIONSwap();
        const ionBridgeRouterAddress = await deployer.getIONBridgeRouter();

        // Assert that the deployed addresses are valid (non-zero)
        expect(iceTokenAddress).to.properAddress;
        expect(ionSwapAddress).to.properAddress;
        expect(ionBridgeRouterAddress).to.properAddress;
    });
});
