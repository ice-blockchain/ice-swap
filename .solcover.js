module.exports = {
    mocha: {
        grep: "@skip-on-coverage",
        invert: true
    },
    skipFiles: [
        'bridge/Bridge.sol',
        'bridge/BridgeDebugger.sol',
        'bridge/BridgeInterface.sol',
        'bridge/ERC20.sol',
        'bridge/IERC20.sol',
        'bridge/IonUtils.sol',
        'bridge/SignatureChecker.sol',
        'bridge/WrappedION.sol',
        'token/openzeppelin/ERC20',
        'token/ICEToken'
    ],
    modifierWhitelist: ['nonReentrant'],
};
