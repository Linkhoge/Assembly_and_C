;-----------------------------------------------------------
; Title: Sum Loop Program for x86_64
; Author: Ariel Fajimiyo
; Student Number: C00300811
; Description: Prompts for two numbers, computes their sum, and prints it.
;              Runs for 3 iterations, keeping a running sum.
;              Includes input validation and overflow handling.
;-----------------------------------------------------------

section .data
    PROMPT db 'Enter number: ', 0
    RESULT db 'The sum is: ', 0
    FINAL_RESULT db 'Final sum is: ', 0
    ERROR_MSG db 'Invalid input! Please enter a valid number', 13, 10, 0
    OVERFLOW_MSG db 'Arithmetic overflow occurred!', 13, 10, 0
    CRLF db 13, 10, 0

section .bss
    INPUT_BUFFER resb 12    ; Buffer for string input
    loop_counter resd 1     ; Loop counter (32-bit, as 3 fits)
    running_sum resq 1      ; Running sum (64-bit for x86_64)
    num1 resq 1             ; First number (64-bit)
    error_flag resd 1       ; Error flag (32-bit)
    negative_flag resd 1    ; Negative number flag (32-bit)
    num_buffer resb 12      ; Buffer for printing numbers

section .text
global _start

_start:
    mov qword [running_sum], 0    ; Running sum = 0
    mov dword [loop_counter], 3   ; Loop counter = 3

game_loop:
    mov rax, 1                    ; sys_write
    mov rdi, 1                    ; stdout
    mov rsi, PROMPT
    mov rdx, 13                   ; Length of "Enter number: "
    syscall

    mov rax, 0                    ; sys_read
    mov rdi, 0                    ; stdin
    mov rsi, INPUT_BUFFER
    mov rdx, 12                   ; Max 12 chars
    syscall

    call string_to_num
    cmp dword [error_flag], 1
    je invalid_input
    mov [num1], rax               ; Store first number

    mov rax, 1
    mov rdi, 1
    mov rsi, PROMPT
    mov rdx, 13
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, INPUT_BUFFER
    mov rdx, 12
    syscall

    call string_to_num
    cmp dword [error_flag], 1
    je invalid_input

    mov rbx, [num1]
    call register_adder
    add [running_sum], rax        ; Update running sum

    mov rax, 1
    mov rdi, 1
    mov rsi, RESULT
    mov rdx, 11                   ; Length of "The sum is: "
    syscall

    call print_number
    call new_line

    dec dword [loop_counter]
    jnz game_loop

    mov rax, 1
    mov rdi, 1
    mov rsi, FINAL_RESULT
    mov rdx, 14                   ; Length of "Final sum is: "
    syscall

    mov rax, [running_sum]
    call print_number
    call new_line

    mov rax, 60                   ; sys_exit
    xor rdi, rdi
    syscall

invalid_input:
    mov rax, 1
    mov rdi, 1
    mov rsi, ERROR_MSG
    mov rdx, 42                   ; Length of error message
    syscall
    jmp game_loop

string_to_num:
    xor rax, rax                  ; Result
    mov dword [error_flag], 0     ; Clear error flag
    mov rsi, INPUT_BUFFER         ; String pointer
    xor rcx, rcx                  ; Digit counter
    mov byte [negative_flag], 0

    mov bl, [rsi]
    cmp bl, '-'
    jne positive
    mov byte [negative_flag], 1
    inc rsi

positive:
    xor rax, rax

convert_loop:
    mov bl, [rsi]
    cmp bl, 0
    je check_range
    cmp bl, 10                    ; Newline
    je check_range
    cmp bl, '0'
    jl invalid
    cmp bl, '9'
    jg invalid

    sub bl, '0'
    imul rax, 10
    add rax, rbx
    inc rsi
    inc rcx
    cmp rcx, 10                   ; Max 10 digits
    jg invalid
    jmp convert_loop

check_range:
    cmp byte [negative_flag], 1
    jne pos_range
    cmp rax, 0x80000000           ; -2^31
    ja invalid
    neg rax
    jmp done_convert

pos_range:
    cmp rax, 0x7FFFFFFF           ; 2^31 - 1
    ja invalid

done_convert:
    ret

invalid:
    mov dword [error_flag], 1
    ret

register_adder:
    mov rax, rbx                  ; First number
    add rax, rbx                  ; Add second number
    jo overflow                   ; Jump if overflow
    ret

overflow:
    mov rax, 1
    mov rdi, 1
    mov rsi, OVERFLOW_MSG
    mov rdx, 28
    syscall
    xor rax, rax                  ; Reset to 0 on overflow
    ret

new_line:
    mov rax, 1
    mov rdi, 1
    mov rsi, CRLF
    mov rdx, 2
    syscall
    ret

print_number:
    mov rsi, num_buffer + 11      ; Point to end of buffer
    mov byte [rsi], 0             ; Null terminator
    mov rbx, 10                   ; Base 10
    xor rcx, rcx                  ; Digit counter
    cmp rax, 0
    jge convert_digits
    neg rax                       ; Handle negative
    mov byte [num_buffer], '-'
    inc rcx

convert_digits:
    xor rdx, rdx
    div rbx                       ; rax / 10, remainder in rdx
    add dl, '0'                   ; Convert to ASCII
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
    mov rax, 1                    ; sys_write
    mov rdi, 1                    ; stdout
    mov rdx, rcx                  ; Length
    syscall
    ret
