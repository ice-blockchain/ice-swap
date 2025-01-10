import React, { useState, useEffect } from 'react';

const DotsCycler = () => {
    const dotSequence = ['.', '..', '...'];
    const [currentIndex, setCurrentIndex] = useState(0);

    useEffect(() => {
        const intervalId = setInterval(() => {
            setCurrentIndex((prevIndex) => (prevIndex + 1) % dotSequence.length);
        }, 500); // adjust this to speed up or slow down the cycling

        return () => clearInterval(intervalId);
    }, [dotSequence.length]);

    return (
        <span>{dotSequence[currentIndex]}</span>
    );
};

export default DotsCycler;
