;-----------------------------------------------------------
; Title: Sum Loop Test Functions for x86_64
; Author: Ariel Fajimiyo
; Student Number: C00300811
; Description: Provides functions for test.c to test the sum loop logic.
;              Allows overflow wrapping (no overflow handling).
;-----------------------------------------------------------

section .data
    running_sum dq 0    ; Running sum (64-bit)

section .bss
    num1 resq 1         ; Storage for first number (64-bit)

section .text
global compute_sum    ; Expose compute_sum function to C

compute_sum:
    ; Function: compute_sum
    ; Inputs: rdi = first number, rsi = second number
    ; Output: rax = current sum (also updates running_sum)
    mov [num1], rdi       ; Store first number from rdi

    mov rax, [num1]       ; Load first number into rax
    add rax, rsi          ; Add second number (from rsi)

    add [running_sum], rax ; Update running sum with the result

    mov rax, rsi          ; Return the second number (to match sum_loop.asm behavior)
    ret                   ; Return with second number in rax

global get_running_sum
get_running_sum:
    ; Function: get_running_sum
    ; Output: rax = current running sum
    mov rax, [running_sum] ; Load running sum into rax
    ret                   ; Return

global reset_running_sum
reset_running_sum:
    ; Function: reset_running_sum
    ; Resets the running sum to 0
    mov qword [running_sum], 0 ; Clear running sum
    ret                   ; Return
