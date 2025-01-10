import IceOpenNetworkLogo from './ice-open-network-logo.svg';
import NoMobileImage from './no-mobile.svg';

// NoMobile component which is shown on mobile devices
const NoMobile = () => {
    return (
        <div className="no-mobile">
            <div className="menu">
                <img src={IceOpenNetworkLogo} alt="Ice Open Network"/>
            </div>
            <div className="content">
                <div className="notification">
                    <img src={NoMobileImage} alt="Only desktop version supported"/>
                    <div className="text">
                        <h1>The ICE Swap is available only on desktop devices</h1>
                        <span>To access, please visit this page on your desktop browser.</span>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default NoMobile;
