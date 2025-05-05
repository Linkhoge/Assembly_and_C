;-----------------------------------------------------------
; Title: Sum Loop Functions for x86_64
; Description: Provides functions for C to test the sum loop logic.
;-----------------------------------------------------------

section .data
    running_sum dq 0    ; Running sum (64-bit)

section .bss
    num1 resq 1         ; First number (64-bit)

section .text
global compute_sum    ; Expose function to C

; Function: compute_sum
; Inputs: rdi = first number, rsi = second number
; Output: rax = current sum (also updates running_sum)
compute_sum:
    mov [num1], rdi

    mov rbx, [num1]       ; First number
    mov rax, rbx          ; Prepare for addition
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
