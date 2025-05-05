;-----------------------------------------------------------
; Title: Sum Loop Functions for x86_64
; Author: Ariel Fajimiyo
; Student Number: C00300811
; Description: Provides functions for C to test the sum loop logic.
;-----------------------------------------------------------

section .data
    running_sum dq 0    ; Running sum (64-bit)

section .bss
    num1 resq 1         ; First number (64-bit)

section .text
global compute_sum    ; Expose function to C

compute_sum:
    mov [num1], rdi

    mov rax, [num1]       ; First number
    add rax, rsi          ; Add second number
    jo overflow           ; Jump if overflow

    add [running_sum], rax

    ret

overflow:
    xor rax, rax          ; Return 0 on overflow
    ret

global get_running_sum
get_running_sum:
    mov rax, [running_sum]
    ret

global reset_running_sum
reset_running_sum:
    mov qword [running_sum], 0
    ret
