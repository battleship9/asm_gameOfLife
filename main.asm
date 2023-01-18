bits 64
global _start

section .bss
grid: resw rows * cols
nextGrid: resw rows * cols

section .data
rows: equ 3
cols: equ 3
empty: equ 'a'
nonEmpty: equ 'X'
errorMsg: db "Error!"
errorMsgLen: equ $ - errorMsg
newLine: db 0x0A

section .text
_start:
    call initializeGrids

    call resetGrids

    call play

    call printTable

    jmp exit

play:
    call computeNextGen
    ret

computeNextGen:

    ret

applyRules:
    ret

countNeighbors:
    xor rcx, rcx    ; count

    ; r10 = row
    ; r11 = col

    ; grid[row-1][col]
    mov rax, cols
    mul r10 - 1
    add rax, r11            ; [row-1][col]
    mov rbx, [grid + rax]   ; grid[row-1][col]
    sub rbx, empty          ; if it's empty gives 0
    mov rdx, nonEmpty - empty
    div rdx
    add rcx, rax

    ; grid[row-1][col-1]
    mov rax, cols
    mul r10 - 1
    add rax, r11
    mov rbx, [grid + rax]
    sub rbx, ' '
    mov rdx, 'X'
    div rdx
    add rcx, rax

    ret

initializeGrids:
    ; allocate memory for grid
    mov rax, 45 ; sys_brk
    int 80h

    mov rax, rows * cols
    mov rbx, rax
    mov rax, 45
    int 80h

    cmp rax, 0
    jl error

    mov [grid], rax
    sub word [grid], rows * cols


    ; allocate memory for nextGrid
    mov rax, 45 ; sys_brk
    int 80h

    mov rax, rows * cols
    mov rbx, rax
    mov rax, 45
    int 80h

    cmp rax, 0
    jl error

    mov [nextGrid], rax
    sub word [nextGrid], rows * cols

    ret

resetGrids:
    mov rcx, rows * cols
    .loopGrid:
        mov byte [grid + rcx - 1], empty
        dec rcx
        cmp rcx, 0
        jg .loopGrid

    mov rcx, rows * cols
    .loopNextGrid:
        mov byte [nextGrid + rcx - 1], empty
        dec rcx
        cmp rcx, 0
        jg .loopNextGrid

    ret

printTable:
    xor r10, r10    ; rows counter

    .loop:
        mov rax, cols
        mul r10
        add rax, grid
        mov rcx, rax

        mov rax, 4
        mov rbx, 1
        mov rdx, cols
        int 80h

        mov rax, 4
        mov rbx, 1
        mov rcx, newLine
        mov rdx, 1
        int 80h

        inc r10

        cmp r10, rows
        jl .loop

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