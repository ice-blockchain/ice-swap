import {HardhatUserConfig} from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            { version: "0.8.27" },
            { version: "0.7.4" },
        ],
    }
};

export default config;
