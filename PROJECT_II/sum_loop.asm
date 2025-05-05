;-----------------------------------------------------------
; Title: Sum Loop Program for x86_64
; Author: Ariel Fajimiyo
; Student Number: C00300811
; Description: Prompts for two numbers, computes their sum, and prints it.
;              Runs for 3 iterations, keeping a running sum.
;              Allows large numbers and overflow wrapping (no validation).
;-----------------------------------------------------------

section .data
    PROMPT db 'Enter number: ', 0
    RESULT db 'The sum is: ', 0
    FINAL_RESULT db 'Final sum is: ', 0
    CRLF db 13, 10, 0

section .bss
    INPUT_BUFFER resb 128    ; Increased buffer for large numbers
    loop_counter resd 1
    running_sum resq 1
    num1 resq 1
    num2 resq 1              ; Added storage for second number
    negative_flag resd 1
    num_buffer resb 128      ; Increased buffer for printing large numbers

section .text
global _start

_start:
    mov qword [running_sum], 0
    mov dword [loop_counter], 3

game_loop:
    ; Prompt for first number using sys_write (rax=1, rdi=stdout, rsi=string, rdx=length)
    mov rax, 1
    mov rdi, 1
    mov rsi, PROMPT
    mov rdx, 13
    syscall

    ; Read first number using sys_read (rax=0, rdi=stdin, rsi=buffer, rdx=max chars)
    mov rax, 0
    mov rdi, 0
    mov rsi, INPUT_BUFFER
    mov rdx, 128
    syscall

    call string_to_num
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
    mov [num2], rax          ; Store second number

    mov rbx, [num1]          ; Load first number into rbx
    mov rcx, [num2]          ; Load second number into rcx
    call register_adder       ; Compute sum (result in rax)
    add [running_sum], rax   ; Update running sum

    ; Print "The sum is: " message
    mov rax, 1
    mov rdi, 1
    mov rsi, RESULT
    mov rdx, 11
    syscall

    ; Print the second number (to match screenshot behavior)
    mov rax, [num2]
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

    ; Exit program using sys_exit (rax=60, rdi=exit code)
    mov rax, 60
    xor rdi, rdi
    syscall

string_to_num:
    ; Convert string to number (no validation)
    xor rax, rax
    mov rsi, INPUT_BUFFER
    mov byte [negative_flag], 0

    ; Check for negative sign at the start
    mov bl, [rsi]
    cmp bl, '-'
    jne positive
    mov byte [negative_flag], 1
    inc rsi

positive:
    xor rax, rax

convert_loop:
    ; Parse each character to build the number
    mov bl, [rsi]
    cmp bl, 0
    je done_convert
    cmp bl, 10
    je done_convert
    sub bl, '0'
    imul rax, 10              ; Shift left by multiplying by 10
    add rax, rbx              ; Add new digit
    inc rsi
    jmp convert_loop

done_convert:
    cmp byte [negative_flag], 1
    jne end_convert
    neg rax                   ; Apply negative sign

end_convert:
    ret

register_adder:
    ; Add two numbers (no overflow check, allows wrapping)
    mov rax, rbx              ; First number (from rbx)
    add rax, rcx              ; Add second number (from rcx)
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
    neg rax                   ; Handle negative numbers
    mov byte [num_buffer], '-'
    inc rcx

convert_digits:
    ; Convert each digit by dividing by 10
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc rcx
    test rax, rax
    jnz convert_digits

    ; Add negative sign if needed
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
