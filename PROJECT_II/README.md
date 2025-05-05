# Sum Loop Program for x86_64

## Overview

This project implements a simple assembly program for two architectures:
- `sum_loop.asm` for the x86_64 architecture.
- `InputValidation.X68` for 68K version.
The program:
- Prompts the user to input two numbers in each of three iterations.
- Computes the sum of the two numbers in each iteration.
- Maintains a running sum across all iterations.
- Prints the sum for each iteration and the final running sum.
- Includes input validation and overflow handling.

A secondary file `sum_loop_func.asm`, provides functions to interface with C for testing the summation logic.

## Development Process and Significant Changes

During the development of `sum_loop.asm`, several issues were identified and resolved. Below is a summary of the significant changes and considerations:
### 1. Adding Input Validation in the 32-bit M68k Version
**Issue**: The initial 68K version of the program lacked input validation:
- It assumed all input characters were valid digits
- It did not check if the converted number fit within the 32-bit signed integer range (`-2147483648` to `2147483647`)

**Change**:
- Introduced a `STRING_TO_NUM` routine with comprehensive input validation:
  - Added an error flag (`D5`) to signal invalid input, checked by the main loop after each conversion:
    ```asm
    BSR STRING_TO_NUM
    TST.W D5
    BNE INVALID_INPUT
    ```
  - Validated each character to ensure it is a digit (`'0'` to `'9'`), with special handling for a leading minus sign:
    ```asm
    CMP.B #'0', D0
    BLT INVALID
    CMP.B #'9', D0
    BGT INVALID
    ```
  - Supported negative numbers by checking for a leading minus sign and setting a `NEG_FLAG`:
    ```asm
    MOVE.B (A2)+, D0
    CMP.B #'-', D0
    BNE POSITIVE
    MOVE.B #1, NEG_FLAG
    ```
  - Ensured input length is limited to 10 characters using `TRAP #15` with `MOVE.W #10, D1`
  - Added range checking to ensure the converted number fits within 32-bit signed integer bounds:
    ```asm
    CHECK_RANGE:
        TST.B NEG_FLAG
        BEQ POS_RANGE
        CMP.L #2147483648, D1
        BGT INVALID
        NEG.L D1
        BRA DONE_CONVERT

    POS_RANGE:
        CMP.L #2147483647, D1
        BGT INVALID
    ```
    
### 2. Incorrect Summation Logic
**Issue**: The initial version of the program produced incorrect sums for each iteration. For example:
- For inputs 20 and 2, the program printed "The sum is: 11" instead of the correct sum, 22.
- The `register_adder` function was adding the first number to itself instead of adding the first and second numbers.

**Change**:
- Introduced a new variable `num2` in the `.bss` section
- Modified the `game_loop` to store the second number in `[num2]` after the second `string_to_num` call
- Updated the `register_adder` function to add the first number (`rbx`) and the second number (`rcx`)
  ```asm
  mov rbx, [num1]    ; First number
  mov rcx, [num2]    ; Second number
  call register_adder
