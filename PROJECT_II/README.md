# Sum Loop Program for x86_64

## Overview

This project implements a simple assembly program (`sum_loop.asm`) for the x86_64 architecture that:
- Prompts the user to input two numbers in each of three iterations.
- Computes the sum of the two numbers in each iteration.
- Maintains a running sum across all iterations.
- Prints the sum for each iteration and the final running sum.
- Includes input validation and overflow handling.

A secondary file, `sum_loop_func.asm`, provides functions to interface with C for testing the summation logic.

## Development Process and Significant Changes

During the development of `sum_loop.asm`, several issues were identified and resolved. Below is a summary of the significant changes and considerations:

### 1. Incorrect Summation Logic
**Issue**: The initial version of the program produced incorrect sums for each iteration. For example:
- For inputs 20 and 2, the program printed "The sum is: 11" instead of the correct sum, 22.
- The `register_adder` function was adding the first number to itself (`add rax, rbx`, where `rax` was set to `rbx`) instead of adding the first and second numbers.

**Change**:
- Introduced a new variable `num2` in the `.bss` section to store the second number.
- Modified the `game_loop` to store the second number in `[num2]` after the second `string_to_num` call.
- Updated the `register_adder` function to add the first number (`rbx`) and the second number (`rcx`), ensuring the correct summation:
  ```asm
  mov rbx, [num1]    ; First number
  mov rcx, [num2]    ; Second number
  call register_adder
