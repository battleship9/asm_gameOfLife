bits 64
global _start

section .data
file: db "./grid.txt", 0
errorMsg: db "Error!"
errorMsgLen: equ $ - errorMsg
rows: equ 30
cols: equ 50
dead: equ '.'
alive: equ 'X'
newLine: db 0x0A
nextGrid: times rows * cols db '.'

section .bss
fileBuffer: resb cols * rows + rows - 1
grid: resb rows * cols

section .text
%include "gameOfLifeCore.asm"

_start:
    mov rax, 5      ; open file
    mov rbx, file
    mov rcx, 0
    int 80h

    mov rax, 3      ; read the file
    mov rbx, rax
    mov rcx, fileBuffer
    mov rdx, cols * rows + rows - 1
    int 80h

    mov rax, 6      ; close file
    int 80h

    xor rax, rax
    .loop:          ; removes enters and copies to grid
    mov al, [fileBuffer + r10]
    mov [grid + r11], al

    cmp rax, 0x0a
    jne .skip
    dec r11
    .skip:

    inc r10
    inc r11
    cmp r11, cols * rows
    jl .loop

    call play

    jmp exit

play:
    ; times 10 call computeNextGen
    call computeNextGen
    jmp play
    ret

error:
    mov rax, 4
    mov rbx, 1
    mov rcx, errorMsg
    mov rdx, errorMsgLen
    int 80h

exit:
    mov rax, 1
    int 80h