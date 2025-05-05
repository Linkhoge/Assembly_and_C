;-----------------------------------------------------------
; Title: Sum Loop Program for x86_64
; Author: Ariel Fajimiyo
; Student Number: C00300811
; Date: May 05, 2025
; Description: Prompts for two numbers, computes their sum, and prints it.
;              Runs for 3 iterations, keeping a running sum.
;              Validates inputs within 64-bit.
;-----------------------------------------------------------

section .data
    PROMPT db 'Enter number: ', 0
    RESULT db 'The sum is: ', 0
    FINAL_RESULT db 'Final sum is: ', 0
    ERROR_MSG db 'Invalid input! Number must be within 64-bit range.', 13, 10, 0
    CRLF db 13, 10, 0

section .bss
    INPUT_BUFFER resb 128    ; Buffer for input
    loop_counter resd 1
    running_sum resq 1
    num1 resq 1
    num2 resq 1
    current_sum resq 1       ; Store the current sum for printing
    error_flag resd 1        ; Flag for invalid input
    negative_flag resd 1
    num_buffer resb 128      ; Buffer for printing numbers

section .text
global _start

_start:
    mov qword [running_sum], 0
    mov dword [loop_counter], 3

game_loop:
    ; Prompt for first number
    mov rax, 1
    mov rdi, 1
    mov rsi, PROMPT
    mov rdx, 13
    syscall

    ; Read first number
    mov rax, 0
    mov rdi, 0
    mov rsi, INPUT_BUFFER
    mov rdx, 128
    syscall

    call string_to_num
    cmp dword [error_flag], 1
    je invalid_input
    mov [num1], rax

    ; Prompt for second number
    mov rax, 1
    mov rdi, 1
    mov rsi, PROMPT
    mov rdx, 13
    syscall

    ; Read second number
    mov rax, 0
    mov rdi, 0
    mov rsi, INPUT_BUFFER
    mov rdx, 128
    syscall

    call string_to_num
    cmp dword [error_flag], 1
    je invalid_input
    mov [num2], rax

    mov rbx, [num1]
    mov rcx, [num2]
    call register_adder
    mov [current_sum], rax   ; Store the sum for printing
    add [running_sum], rax   ; Update running sum

    ; Print "The sum is: " message
    mov rax, 1
    mov rdi, 1
    mov rsi, RESULT
    mov rdx, 11
    syscall

    ; Print the actual sum
    mov rax, [current_sum]
    call print_number
    call new_line

    dec dword [loop_counter]
    jnz game_loop

    ; Print "Final sum is: " message
    mov rax, 1
    mov rdi, 1
    mov rsi, FINAL_RESULT
    mov rdx, 14
    syscall

    mov rax, [running_sum]
    call print_number
    call new_line

    ; Exit program
    mov rax, 60
    xor rdi, rdi
    syscall

invalid_input:
    mov rax, 1
    mov rdi, 1
    mov rsi, ERROR_MSG
    mov rdx, 47
    syscall
    jmp game_loop

string_to_num:
    ; Convert string to number with 64-bit validation
    xor rax, rax
    mov dword [error_flag], 0
    mov rsi, INPUT_BUFFER
    xor rcx, rcx
    mov byte [negative_flag], 0

    ; Check for negative sign
    mov bl, [rsi]
    cmp bl, '-'
    jne positive
    mov byte [negative_flag], 1
    inc rsi

positive:
    xor rax, rax

convert_loop:
    ; Parse each character
    mov bl, [rsi]
    cmp bl, 0
    je check_range
    cmp bl, 10
    je check_range
    cmp bl, '0'
    jl invalid
    cmp bl, '9'
    jg invalid

    sub bl, '0'
    imul rax, 10              ; Multiply current value by 10
    jo invalid                ; Check for overflow during multiplication
    add rax, rbx              ; Add new digit
    jo invalid                ; Check for overflow during addition
    inc rsi
    inc rcx
    cmp rcx, 19               ; Rough check: 64-bit signed max has up to 19 digits
    jg invalid
    jmp convert_loop

check_range:
    ; Validate within 64-bit signed integer range
    cmp byte [negative_flag], 1
    jne pos_range
    ; For negative numbers, check against -2^63
    cmp rax, 0x8000000000000000  ; -2^63
    ja invalid                   ; If greater than -2^63 (unsigned comparison), invalid
    neg rax                      ; Apply negative sign
    jmp done_convert

pos_range:
    ; For positive numbers, check against 2^63 - 1
    cmp rax, 0x7FFFFFFFFFFFFFFF  ; 2^63 - 1
    ja invalid                   ; If greater than 2^63 - 1, invalid

done_convert:
    ret

invalid:
    mov dword [error_flag], 1
    ret

register_adder:
    ; Add two numbers (allows wrapping)
    mov rax, rbx
    add rax, rcx
    ret

new_line:
    mov rax, 1
    mov rdi, 1
    mov rsi, CRLF
    mov rdx, 2
    syscall
    ret

print_number:
    ; Convert number in rax to string for printing
    mov rsi, num_buffer + 127
    mov byte [rsi], 0
    mov rbx, 10
    xor rcx, rcx
    cmp rax, 0
    jge convert_digits
    neg rax
    mov byte [num_buffer], '-'
    inc rcx

convert_digits:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc rcx
    test rax, rax
    jnz convert_digits

    cmp byte [num_buffer], '-'
    jne print
    dec rsi
    mov byte [rsi], '-'
    inc rcx

print:
    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    syscall
    ret
