// SPDX-License-Identifier: UNLICENSED

pragma solidity =0.8.27;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./openzeppelin/ERC20.sol";

contract ICEToken is ERC20, Ownable {

    /**
     * The address, responsible for doing air-drops.
     **/
    address private _airDropper;

    mapping(address account => uint256) private _balances;

    uint256 private _totalSupply;

    mapping(address => bool) public bots;

    bool public swapEnabled = false;
    bool public limitsInEffect = true;

    // Anti-bot and anti-whale mappings and variables
    mapping(address => uint256) private _holderLastTransferTimestamp; // to hold last Transfers temporarily during launch
    bool public transferDelayEnabled = true;

    /**
     * @dev Addresses, excluded from limits.
     **/
    mapping(address => bool) private _limitExclusions;

    /**
     * @dev The block number, when the trading was enabled for this contract.
     *
     * 0 means trading is not enabled.
     **/
    uint256 private _tradingEnabledBlock = 0;

    /**
     * Known Uniswap router addresses.
     **/
    mapping(address => bool) private _uniswapRouters;

    /**
     * Triggered, when the trading is enabled once again.
     **/
    error TradingAlreadyEnabled();

    /**
     * Triggered, when arguments mismatch.
     **/
    error Mismatch();

    /**
     * Triggered, when the zero address was specified.
     **/
    error ZeroAddress();

    /**
     * Triggered, when the zero token address was specified.
     **/
    error ERC20ZeroToken();

    /**
     * Triggered, when the owner tries to take-away this token, needed for liquidity.
     **/
    error ForeignTokenSelfTransfer();

    /**
     * Triggered, when the bot is detected;
     */
    error NoBots();

    /**
     * Triggered, when a zero-amount operation is requested.
     */
    error ZeroAmount();

    /**
     * Triggered, when the low-level call fails while withdrawing ETH from the contract address.
     **/
    error WithdrawStuckETH();

    /**
     * Triggered, when the caller is not the air-dropper.
     **/
    error NotAirDropper();

    /**
     * @dev Checks, whether the sender is the allowed air-dropper.
     */
    modifier onlyAirDropper() {
        if (_airDropper != msg.sender) {
            revert NotAirDropper();
        }
        _;
    }

    /**
     * Triggered, when an address is marked to be / not to be a Uniswap router.
     **/
    event SetUniswapRouter(
        address indexed theAddress,
        bool indexed flag
    );

    /**
     * Called, when trading is enabled.
     **/
    event EnableTrading();

    event RemovedLimits();

    event ExcludeFromLimits(address indexed account, bool isExcluded);

    event TransferForeignToken(
        address token,
        address to,
        uint256 amount
    );

    constructor() ERC20("Ice", "ICE") Ownable(msg.sender) {
        _airDropper = msg.sender;
        excludeFromLimits(msg.sender, true);
        excludeFromLimits(address(this), true);
        setKnownBNBUniswapRouters(true);
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Enables receiving Ether.
     **/
    fallback() external payable {}

    /**
     * @dev Enables receiving Ether.
     **/
    receive() external payable {}

    /**
     * @return The trading enabled block number.
     **/
    function getTradingEnabledBlock() public view returns (uint256) {
        return _tradingEnabledBlock;
    }

    /**
     * @dev Enables trading for this contract.
     **/
    function enableTrading() external onlyOwner {

        if (0 != _tradingEnabledBlock) {
            revert TradingAlreadyEnabled();
        }

        swapEnabled = true;
        _tradingEnabledBlock = block.number;

        emit EnableTrading();
    }

    // Remove limits after token is stable
    function removeLimits() external onlyOwner {
        limitsInEffect = false;
        transferDelayEnabled = false;
        emit RemovedLimits();
    }

    function manageBoughtEarly(address wallet, bool flag) external onlyOwner {
        bots[wallet] = flag;
    }

    function massManageBoughtEarly(address[] calldata wallets, bool flag) external onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            bots[wallets[i]] = flag;
        }
    }

    // Disable Transfer delay - cannot be re-enabled
    function disableTransferDelay() external onlyOwner {
        transferDelayEnabled = false;
    }

    // @dev Sets a new address allowed to air-drop tokens
    function setAirDropper(address newAirDropper) external onlyOwner {
        _airDropper = newAirDropper;
    }

    function getAirDropper() public view returns (address) {
        return _airDropper;
    }

    function renounceOwnership() public virtual override onlyOwner {

        super.renounceOwnership();

        // Reset the air-dropper
        _airDropper = address(0);
    }

    /**
     * @dev Distributes tokens the the given list of wallets.
     * @param recipients Addresses, to which the distribution should occur.
     * @param amounts Corresponding amounts to be distributed.
     **/
    function airdropToWallets(address[] calldata recipients, uint256[] calldata amounts) external onlyAirDropper {

        if (recipients.length != amounts.length) {
            revert Mismatch();
        }

        uint256 length = recipients.length;
        uint256 totalSupplyDelta;

        // Start of the loop
        assembly {

            // Temporary memory to save the recipient selector
            let ptr := mload(0x40)
            let ptr2 := add(ptr, 0x20)

            // Skip the 4-bytes function signature hash to load the first dynamic variable offset
            let recipientsDataOffset := calldataload(0x4)

            // Skip the 4-bytes function signature hash and the 32-bytes first dynamic variable offset to load
            // the second dynamic variable offset
            let amountsDataOffset := calldataload(0x24)

            // Loop counter
            for { let i := 0 } lt(i, length) { i := add(i, 1) } {

                // Load recipient and amount
                let offset := add(mul(i, 0x20), 0x24)
                let amount := calldataload(add(amountsDataOffset, offset))

                // Calculate the recipient slot
                mstore(ptr, calldataload(add(recipientsDataOffset, offset)))
                mstore(ptr2, _balances.slot)
                let recipientSlot := keccak256(ptr, 0x40)

                // Update stored values
                sstore(recipientSlot, add(sload(recipientSlot), amount))
                totalSupplyDelta := add(totalSupplyDelta, amount)
            }
        }

        // Update the total supply after the loop
        unchecked {
            _totalSupply += totalSupplyDelta;
        }
    }

    /**
     * @dev Excludes / includes the given address from / to limits.
     *
     * @param account The account to be included / excluded.
     * @param excluded Whether to exclude or include.
     **/
    function excludeFromLimits(address account, bool excluded) public onlyOwner {

        _limitExclusions[account] = excluded;

        emit ExcludeFromLimits(account, excluded);
    }

    function transferForeignToken(address _token, address _to) external onlyOwner {

        if (_token == address(0)) {
            revert ERC20ZeroToken();
        }

        if (_token == address(this)) {
            revert ForeignTokenSelfTransfer();
        }

        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        SafeERC20.safeTransfer(IERC20(_token), _to, _contractBalance);

        emit TransferForeignToken(_token, _to, _contractBalance);
    }

    /**
     * Withdraw ETH, which is stuck on this contract
     * or if someone sends it to the contract address.
     **/
    function withdrawStuckETH() external onlyOwner {

        uint256 amount = address(this).balance;
        if (0 == amount) {
            revert ZeroAmount();
        }

        bool success;
        (success,) = address(msg.sender).call{value: amount}("");
        if (!success) {
            revert WithdrawStuckETH();
        }
    }

    /**
     * Mark an address as a known Uniswap router.
     *
     * @param theAddress The address to be marked.
     * @param flag Whether this address is the Uniswap router.
     **/
    function setUniswapRouter(address theAddress, bool flag) public onlyOwner {

        // Check for zero addresses
        if (theAddress == address(0x0)) {
            revert ZeroAddress();
        }

        _uniswapRouters[theAddress] = flag;

        emit SetUniswapRouter(theAddress, flag);
    }

    /**
     * Mark all known BNB Chain Uniswap router addresses.
     *
     * @param flag Whether all these addresses should be treated as Uniswap routers.
     **/
    function setKnownBNBUniswapRouters(bool flag) public onlyOwner {

        // Uniswap V2 - not available from the official Uniswap on BNB

        // Uniswap V3 (as per https://docs.uniswap.org/contracts/v3/reference/deployments)
        // SwapRouter - not available from the official Uniswap on BNB
        // NonfungiblePositionManager:
        setUniswapRouter(0x7b8A01B39D58278b5DE7e48c8449c9f4F5170613, flag);
        // SwapRouter02:
        setUniswapRouter(0xB971eF87ede563556b2ED4b1C0b0019111Dd85d2, flag);

        // PancakeSwap
        // According to: https://docs.pancakeswap.finance/developers/smart-contracts/pancakeswap-exchange/v2-contracts/router-v2
        setUniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E, flag);
        // According to: https://docs.pancakeswap.finance/developers/smart-contracts/pancakeswap-exchange/v3-contracts
        setUniswapRouter(0x1b81D678ffb9C0263b24A97847620C99d213eB14, flag);
        setUniswapRouter(0x13f4EA83D0bd40E75C8222255bc855a974568Dd4, flag);

        // SushiSwap
        // According to: https://docs.sushi.com/docs/Products/Classic%20AMM/Deployment%20Addresses
        setUniswapRouter(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506, flag);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function __transfer(address from, address to, uint256 value) internal virtual {

        uint256 fromBalance = _balances[from];
        if (fromBalance < value) {
            revert ERC20InsufficientBalance(from, fromBalance, value);
        }

    unchecked {
        // Overflow not possible: value <= fromBalance <= totalSupply.
        _balances[from] = fromBalance - value;
    }

    unchecked {
        // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
        _balances[to] += value;
    }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Returns, whether the trading is currently enabled.
     *
     * @return Whether trading is enabled for this contract.
     */
    function _isTradingEnabled() private view returns (bool) {
        return 0 != _tradingEnabledBlock;
    }

    function _transfer(address from, address to, uint256 amount) internal {

        if (to == address(0)) {
            revert ERC20InvalidReceiver(to);
        }

        require(amount > 0, "amount must be greater than 0");

        if (!_isTradingEnabled() && _uniswapRouters[msg.sender]) {
            require(_limitExclusions[from] || _limitExclusions[to], "Trading is not active.");
        }

        if (bots[from] || bots[to]) {
            revert NoBots();
        }

        if (limitsInEffect) {
            if (from != owner() && to != owner() && to != address(0) && !_limitExclusions[from] && !_limitExclusions[to]) {

                // At launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.
                if (transferDelayEnabled) {
                    require(_holderLastTransferTimestamp[tx.origin] < block.number - 2 && _holderLastTransferTimestamp[to] < block.number - 2, "_transfer:: Transfer Delay enabled.  Try again later.");
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                    _holderLastTransferTimestamp[to] = block.number;
                }
            }
        }

        __transfer(from, to, amount);
    }
}
