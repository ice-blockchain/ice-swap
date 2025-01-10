import {forwardRef, useEffect, useImperativeHandle, useRef, useState} from "react";

const ThousandsNumberInput = forwardRef(({
                                             initialValue = "0",
                                             readOnly = false,
                                             disabled = false,
                                             suffix = '',
                                             onChange,
                                             className = '',
                                             visible = false
                                         }, ref) => {
    const [value, setValue] = useState(initialValue);
    const inputRef = useRef(null);

    // Expose focus method to parent
    useImperativeHandle(ref, () => ({
        focus: () => {
            if (inputRef.current && !readOnly && !disabled) {
                inputRef.current.focus();
            }
        }
    }));

    const addCommas = (num) =>
        num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");

    const removeNonNumeric = (num) =>
        num.toString().replace(/[^0-9]/g, "");

    useEffect(() => {
        setValue(addCommas(initialValue));
    }, [initialValue]);

    const handleChange = (event) => {
        const formattedValue = addCommas(removeNonNumeric(event.target.value));
        setValue(formattedValue);
        onChange?.(formattedValue);
    };

    const displayValue = readOnly && suffix && value.length > 0 ? `${value}${suffix}` : value;

    return (
        <input
            ref={inputRef}
            type="text"
            value={displayValue}
            onChange={handleChange}
            readOnly={readOnly}
            disabled={disabled}
            className={`thousands-number-input ${visible ? 'visible' : ''} ${className}`}
            style={{
                opacity: visible ? 1 : 0,
                transition: 'opacity 0.2s ease-in-out',
                pointerEvents: visible ? 'auto' : 'none'
            }}
        />
    );
});

export default ThousandsNumberInput;
