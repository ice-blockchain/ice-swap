import React, {useEffect, useState} from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import Application from './Application';
import NoMobile from "./no-mobile";

// Main Application wrapper with mobile detection
const ApplicationWrapper = ({children}) => {
    const [isMobile, setIsMobile] = useState(false);

    useEffect(() => {
        // Function to check if device is mobile
        const checkMobile = () => {
            setIsMobile(window.innerWidth <= 768); // Considers devices <= 768px as mobile
        };

        // Check on initial load
        checkMobile();

        // Add event listener for window resize
        window.addEventListener('resize', checkMobile);

        // Cleanup
        return () => window.removeEventListener('resize', checkMobile);
    }, []);

    // Show NoMobile component if on mobile device
    // if (isMobile) {
    //     return <NoMobile/>;
    // }

    const childrenWithProps = React.Children.map(children, child => {
        // Checking isValidElement is the safe way and avoids a
        // typescript error too.
        if (React.isValidElement(child)) {
            return React.cloneElement(child, { isMobile });
        }
        return child;
    });

    // Show main application on desktop
    return childrenWithProps;
};

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
    <React.StrictMode>
        <ApplicationWrapper>
            <Application />
        </ApplicationWrapper>
    </React.StrictMode>
);
