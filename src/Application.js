import React, {useEffect, useRef, useState} from 'react';
import Web3Modal from "web3modal";
import {Contract, ethers} from 'ethers';
import dotenv from 'dotenv';
import './Application.css';
import IceLogo from './ice-logo.svg';
import V1 from './v1.svg';
import V2 from './v2.svg';
import VerticalLine1 from './vertical-line-1.svg';
import DescriptionIcon from './description-icon.svg';
import IceOpenNetworkLogo from './ice-open-network-logo.svg';
import {ReactComponent as MemeIcon} from './meme-markers.svg';
import {ReactComponent as BridgeIcon} from './bridge-icon.svg';
import {ReactComponent as PlusIcon} from './plus-icon.svg';
import {ReactComponent as WalletIcon} from './wallet-icon.svg';
import {ReactComponent as DropIcon} from './drop-icon.svg';
import {ReactComponent as DisconnectIcon} from './disconnect-icon.svg';
import {ReactComponent as CompletedIcon} from './completed-icon.svg';
import {ReactComponent as PendingIcon} from './pending-icon.svg';
import {ReactComponent as FailedIcon} from './failed-icon.svg';
import {ReactComponent as BinanceIcon} from './binance-icon.svg';
import ThousandsNumberInput from "./thousands-number-input";
import DotsCycler from "./dots-cycler";

dotenv.config();

function capitalize(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

// Define the ABI for ICEToken (ERC20 standard) and IONSwap contracts
const ICETokenABI = [
    // Include the `approve` and `balanceOf` functions from ERC20 standard
    "function approve(address spender, uint256 amount) external returns (bool)",
    "function balanceOf(address account) external view returns (uint256)",
];

const IONSwapABI = [
    // Include the `swapTokens` function
    "function swapTokens(uint256 amount) external",
];

function Application({isMobile}) {

    const [iceAmount, setIceAmount] = useState('');
    const [isConnected, setIsConnected] = useState(false);
    const [isLoaded, setIsLoaded] = useState(false);
    const [accountAddress, setAccountAddress] = useState('');
    const [transactionHash, setTransactionHash] = useState(''); // State to hold the transaction hash
    const [swapStatus, setSwapStatus] = useState([]); // State to hold the swap steps and their statuses
    const [isSwapping, setIsSwapping] = useState(false); // State to indicate if swapping is in progress
    const [isDisconnectMenuVisible, setIsDisconnectMenuVisible] = useState(false); // State for disconnect menu visibility
    const [hasEnoughICE, setHasEnoughICE] = useState(true);
    const amountInputRef = useRef(null);
    const [isAmountInputVisible, setIsAmountInputVisible] = useState(false);
    const resultingAmountInputRef = useRef(null);
    const [isResultingAmountInputVisible, setIsResultingAmountInputVisible] = useState(false);
    const [alertTimeout, setAlertTimeout] = useState(0);

    // Use useRef to hold the Web3Modal instance, provider, and menu ref
    const web3ModalRef = useRef(null);
    const providerRef = useRef(null);
    const menuRef = useRef(null);

    // Determine if the app is running on testnet based on the REACT_APP_TESTNET flag
    const isTestnet = process.env.REACT_APP_TESTNET === '1';

    // Initialize Web3Modal on component mount
    useEffect(() => {
        web3ModalRef.current = new Web3Modal({
            cacheProvider: true, // Enable caching to remember connection
        });

        // Check if MetaMask is already authorized
        const checkMetaMaskAuthorization = async () => {
            if (window.ethereum && web3ModalRef.current.cachedProvider) {
                try {
                    // This won't trigger a prompt, it just checks current authorization
                    const accounts = await window.ethereum.request({method: 'eth_accounts'});
                    if (accounts.length > 0) {
                        // MetaMask is authorized, safe to auto-connect
                        await connectWallet();
                    }
                } catch (error) {
                    console.log("Not authorized by MetaMask");
                }
            }
            setIsLoaded(true);
        };

        checkMetaMaskAuthorization().then();
    }, []);

    useEffect(() => {
        setIsResultingAmountInputVisible(iceAmount !== undefined && iceAmount.trim() !== '' && Number(iceAmount.replace(/,/g, '')) > 0);
    }, [iceAmount]);

    const calculateHasEnoughICE = async (value) => {

        if (!accountAddress || !providerRef.current) {
            return;
        }

        const ethersProvider = new ethers.BrowserProvider(providerRef.current);
        const iceTokenContract = new Contract(process.env.REACT_APP_ICE_TOKEN_CONTRACT_ADDRESS, ICETokenABI, ethersProvider);

        // Get the balance of the current account
        const balance = await iceTokenContract.balanceOf(accountAddress);

        // Remove commas from the entered value and default to '0' if empty
        const cleanedValue = value.replace(/,/g, '') || '0';

        // Convert the entered value to a BigInt (assuming ICE token has 18 decimals)
        const valueInWei = ethers.parseUnits(cleanedValue, 18);

        return valueInWei <= balance;
    };

    const handleIceAmountChange = (value) => {
        calculateHasEnoughICE(value).then(setHasEnoughICE);
        setIceAmount(value);
    };

    const setMaxIceAmount = async () => {
        if (!accountAddress || !providerRef.current) {
            return;
        }

        const ethersProvider = new ethers.BrowserProvider(providerRef.current);
        const iceTokenContract = new Contract(process.env.REACT_APP_ICE_TOKEN_CONTRACT_ADDRESS, ICETokenABI, ethersProvider);

        // Get the balance of the current account
        const balance = await iceTokenContract.balanceOf(accountAddress);

        // Convert the balance from Wei to decimal string
        const balanceInEtherString = ethers.formatUnits(balance, 18);

        let balanceFixed = Math.floor(Number(balanceInEtherString));
        balanceFixed = `${balanceFixed}`;
        setIceAmount(balanceFixed);
        calculateHasEnoughICE(balanceFixed).then(setHasEnoughICE);
    };

    const isSwapValid = () => {

        // Return false if not connected or already swapping
        if (!isConnected || isSwapping) {
            return false;
        }

        // Check if amount is empty or zero
        if (!iceAmount || iceAmount.trim() === '') {
            return false;
        }

        // Convert amount string (removing commas) to number and validate
        const numericAmount = Number(iceAmount.replace(/,/g, ''));
        if (isNaN(numericAmount) || numericAmount <= 0) {
            return false;
        }

        return hasEnoughICE;
    };

    const handleSwap = async () => {

        const amount = iceAmount.replace(',', '');

        if (!amount || isNaN(Number(amount)) || Number(amount) <= 0) {
            alert("Please enter a valid amount of ICE to swap.");
            return;
        }

        // Clear the previous alert timeout
        if (alertTimeout) {
            clearTimeout(alertTimeout);
            setAlertTimeout(0);
        }

        // Initialize swap steps
        const initialSwapStatus = [
            {name: 'Approving ICE tokens', status: 'pending'},
            {name: 'Swapping ICE for ION', status: 'pending'},
            {name: 'Transaction submitted', status: 'pending'},
            {name: 'View on BscScan', status: 'binance'},
        ];
        setTransactionHash(undefined);
        setSwapStatus(initialSwapStatus);
        setIsSwapping(true);

        try {
            const ethersProvider = new ethers.BrowserProvider(providerRef.current);
            const signer = await ethersProvider.getSigner();

            // Define the contract addresses from environment variables
            const ICETokenAddress = process.env.REACT_APP_ICE_TOKEN_CONTRACT_ADDRESS;
            const IONSwapAddress = process.env.REACT_APP_ION_SWAP_CONTRACT_ADDRESS;

            if (!ICETokenAddress || !IONSwapAddress) {
                console.error("Contract addresses are not defined in environment variables.");
                return;
            }

            // Create contract instances
            const iceTokenContract = new Contract(ICETokenAddress, ICETokenABI, signer);
            const swapContract = new Contract(IONSwapAddress, IONSwapABI, signer);

            // Amount to swap, converted to Wei (assuming ICE token has 18 decimals)
            const amountToSwap = ethers.parseUnits(amount, 18);

            // Step 1: Approve the IONSwap contract to spend ICE tokens on behalf of the user
            updateSwapStatus('Approving ICE tokens', 'in-progress');
            const approveTx = await iceTokenContract.approve(IONSwapAddress, amountToSwap);
            // Wait for the transaction to be mined
            await approveTx.wait();
            updateSwapStatus('Approving ICE tokens', 'completed');

            // Step 2: Call the swapTokens method on the IONSwap contract
            updateSwapStatus('Swapping ICE for ION', 'in-progress');
            const swapTx = await swapContract.swapTokens(amountToSwap);
            updateSwapStatus('Swapping ICE for ION', 'completed');

            // Wait for the transaction to be mined
            updateSwapStatus('Transaction submitted', 'in-progress');
            await swapTx.wait();
            updateSwapStatus('Transaction submitted', 'completed');

            // Save the transaction hash
            setTransactionHash(swapTx.hash);

            // Inform the user
            // alert(`Successfully swapped ${amount} ICE for ION.\nTransaction Hash: ${swapTx.hash}`);

            // Clear the input
            setIceAmount('');

            updateSwapStatus('View on BscScan', 'binance');
        } catch (error) {

            console.error(error);

            const reportError = (message) => {

                // Reset swap statuses on error
                setSwapStatus([
                    {name: capitalize(message), status: 'failed'},
                ]);

                updateSwapStatus(capitalize(message), 'failed');
            }

            if ("ACTION_REJECTED" === error.code) {
                reportError("Transaction cancelled");
            } else if (-1 < error.shortMessage.indexOf("revert")) {
                reportError("Swap would revert");
            } else {
                reportError(error.shortMessage)
            }
        } finally {
            setIsSwapping(false);
        }
    };

    // Function to update the swap status of a step
    const updateSwapStatus = (stepName, status) => {
        setSwapStatus(prevStatus => {
            return prevStatus.map(step => {
                if (step.name === stepName) {
                    return {...step, status};
                }
                return step;
            });
        });

        // v.1.0
        // Set timeout to remove the `completed` notification after 11 seconds
        // if (status === 'completed' || status === 'failed') {
        //     setTimeout(() => {
        //         setSwapStatus(prevStatus => prevStatus.filter(step => step.name !== stepName));
        //     }, 11000);
        // }

        // v.2.0
        // At the end, hide all notifications after the time-out
        if (status === 'binance' || status === 'failed') {
            if (alertTimeout) {
                clearTimeout(alertTimeout);
                setAlertTimeout(0);
            }

            const timeout = setTimeout(() => {
                setSwapStatus([]);
            }, 30000);
            setAlertTimeout(timeout);
        }
    };

    const connectWallet = async () => {

        // Check if MetaMask or another provider is available
        if (!window.ethereum) {
            alert("Please install MetaMask to connect your wallet.");
            return;
        }

        try {
            const provider = await web3ModalRef.current.connect();
            providerRef.current = provider; // Save the provider for later use
            setIsConnected(true);

            // Get accounts and set the account address
            const accounts = await provider.request({method: 'eth_accounts'});
            if (accounts.length > 0) {
                setAccountAddress(accounts[0]);
            }

            provider.on("accountsChanged", (accounts) => {
                if (accounts.length === 0) {
                    // User disconnected their wallet
                    setIsConnected(false);
                    setAccountAddress('');
                } else {
                    setAccountAddress(accounts[0]);
                }
                // Hide the disconnect menu when account changes
                setIsDisconnectMenuVisible(false);
            });

            provider.on("disconnect", () => {
                setIsConnected(false);
                setAccountAddress('');
                setIsDisconnectMenuVisible(false);
            });
        } catch (error) {
            console.error(error);
        }
    };

    const onInputClicked = async (event) => {
        setIsAmountInputVisible(true);
        setTimeout(() => {
            amountInputRef.current?.focus();
        }, 250);
    };

    const showDisconnectMenu = () => {
        setIsDisconnectMenuVisible(!isDisconnectMenuVisible);
    };

    const disconnectWallet = async () => {
        // Clear cached provider to forget the connection
        await web3ModalRef.current.clearCachedProvider();
        if (providerRef.current && providerRef.current.disconnect) {
            await providerRef.current.disconnect();
        }
        providerRef.current = null;
        setIsConnected(false);
        setAccountAddress('');
        setIsDisconnectMenuVisible(false);
    };

    // Close the disconnect menu when clicking outside
    useEffect(() => {
        const handleClickOutside = (event) => {
            if (menuRef.current && !menuRef.current.contains(event.target)) {
                setIsDisconnectMenuVisible(false);
            }
        };
        // Bind the event listener
        document.addEventListener("mousedown", handleClickOutside);
        return () => {
            // Unbind the event listener on clean up
            document.removeEventListener("mousedown", handleClickOutside);
        };
    }, [menuRef]);

    // Helper function to shorten the address
    const shortenAddress = (address) => {
        if (!address) return '';
        return `${address.slice(0, 5)}...${address.slice(-5)}`;
    };

    function openBridge() {
        document.location = process.env.REACT_APP_BRIDGE_URI;
    }


    // Define a helper function to render notification messages
    const renderNotifications = () => {
        if (swapStatus.length === 0) return null;

        return swapStatus.map((step, index) => {
            // Skip rendering if status is 'binance' and no transactionHash
            if ((step.status === 'binance' && !transactionHash) || step.status === 'pending') {
                return null;
            }

            return (
                <div key={index} className={`notification step-${step.status}`}>
                    <div>
                        {step.status === 'completed' && <CompletedIcon className="notification-status-icon"/>}
                        {(step.status === 'in-progress') &&
                            <PendingIcon className="notification-status-icon"/>}
                        {step.status === 'failed' && <FailedIcon className="notification-status-icon"/>}
                        {step.status === 'binance' && transactionHash &&
                            <BinanceIcon className="notification-status-icon"/>}
                        {step.status !== 'binance' && step.status !== 'pending' && step.name}
                        {step.status === 'in-progress' && <DotsCycler/>}
                        {step.status === 'binance' && transactionHash && <a
                            href={`${isTestnet ? 'https://testnet.bscscan.com' : 'https://bscscan.com'}/tx/${transactionHash}`}
                            target="_blank"
                            rel="noopener noreferrer"
                        >{step.name}</a>}
                    </div>
                </div>
            )
        });
    };

    return (
        <div className={`Application ${isTestnet ? "testnet" : ""}`}>

            {isTestnet ? (
                <div className="testnetWarning">TESTNET</div>
            ) : (
                <div/>
            )}

            {!isMobile && <div className="notifications-area">
                {renderNotifications()}
            </div>}

            <div className="menu">

                <img src={IceOpenNetworkLogo} alt="Ice Open Network"/>

                <div className="tabs">
                    <button className="swap-tab">
                        <MemeIcon className="meme-icon-blue"/>
                        Swap
                    </button>

                    <button className="bridge-tab" onClick={openBridge}>
                        <BridgeIcon className="bridge-icon-gray"/>
                        Bridge
                    </button>
                </div>

                {isLoaded ? (
                    <div className="connect-wallet-container" ref={menuRef}>
                        {isConnected ? (
                            <>
                                <button className="connect-wallet-button" onClick={showDisconnectMenu}>
                                    <WalletIcon width={24} height={24}/>
                                    {shortenAddress(accountAddress)}
                                    <DropIcon className="drop-icon" width={24} height={24}/>
                                </button>

                                {isDisconnectMenuVisible && (
                                    <button className="disconnect-wallet-button" onClick={disconnectWallet}>
                                        <DisconnectIcon/>
                                        Disconnect
                                    </button>
                                )}
                            </>
                        ) : (
                            <button className="connect-wallet-button" onClick={connectWallet}>
                                <PlusIcon/>
                                Connect wallet
                            </button>
                        )}
                    </div>
                ) : (
                    <div/>
                )}
            </div>

            <div className="swap-form">
                <h1>ICE Swap</h1>
                <div className={`form-group form-group-1 ${!hasEnoughICE ? 'insufficient-balance' : ''}`}>
                    <div className="input-field" onClick={onInputClicked}>
                        <div className="token-container">
                            <img src={IceLogo} className="token" alt="ICE"/>
                            <img src={V1} className="v1" alt="v1"/>
                        </div>
                        <img src={VerticalLine1} className="vertical-line-1" alt=""/>
                        <div>
                            <span className={`normal ${isAmountInputVisible ? "" : "initial"}`}>Enter ICE amount</span>
                            <span className='alert'>Insufficient ICE balance</span>
                            <ThousandsNumberInput
                                ref={amountInputRef}
                                initialValue={iceAmount}
                                onChange={handleIceAmountChange}
                                disabled={isSwapping}
                                visible={isAmountInputVisible}
                            />
                        </div>
                        <span className="max" onClick={setMaxIceAmount}>MAX</span>
                    </div>
                </div>
                <div className="form-group form-group-2">
                    <div className="input-field">
                        <div className="token-container">
                            <img src={IceLogo} className="token" alt="ICE"/>
                            <img src={V2} className="v2" alt="v2"/>
                        </div>
                        <img src={VerticalLine1} className="vertical-line-1" alt=""/>
                        <div>
                            <span
                                className={`normal ${isResultingAmountInputVisible ? "" : "initial"}`}>You receive ICE</span>
                            <ThousandsNumberInput
                                ref={resultingAmountInputRef}
                                initialValue={iceAmount}
                                readOnly={true}
                                suffix=" ICE"
                                visible={isResultingAmountInputVisible}
                            />
                        </div>
                    </div>
                </div>
                <button className="swap-button" onClick={handleSwap} disabled={!isSwapValid()}>
                    <MemeIcon className="meme-icon-white"/>
                    {isSwapping ? 'Swapping...' : 'Swap'}
                </button>
                {isMobile && <div className="notifications-area">
                    {renderNotifications()}
                </div>}
            </div>

            <a href="https://ice.io/swap-tutorial" target="_blank" rel="noopener noreferrer">
                <div className="description-form">
                    <img src={DescriptionIcon} alt="Help"/>
                    <div>
                        <h2>How does it work?</h2>
                        <span>Follow our simple guide on how to swap ICE from the old Binance Smart Chain contract to the new one.</span>
                    </div>
                </div>
            </a>
        </div>
    );
}

export default Application;
