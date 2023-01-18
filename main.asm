bits 64
global _start

section .data
rows: equ 3
cols: equ 3
empty: equ 'a'
nonEmpty: equ 'X'
errorMsg: db "Error!"
errorMsgLen: equ $ - errorMsg
newLine: db 0x0A

section .bss
grid: resw rows * cols
nextGrid: resw rows * cols

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
    mov rax, cols               ; rax = number of cells in a full row
    mul r10 - 1
    add rax, r11                ; [row-1][col]
    mov rbx, [grid + rax]       ; grid[row-1][col]
    sub rbx, empty              ; if it's empty it gives 0
    mov rax, rbx                ; moves to rax for the next step
    mov rdx, nonEmpty - empty   ; it divides rax with nonEmpty - empty (since we already subtracted empty we have to subtracted empty from nonEmpty (it can result negative numbers so it might be buggy))
    div rdx                     ; if it wasn't 0 division gives 1
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