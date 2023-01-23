bits 64
global _start

section .data
rows: equ 5
cols: equ 5
empty: equ 'O'
nonEmpty: equ 'X'
errorMsg: db "Error!"
errorMsgLen: equ $ - errorMsg
newLine: db 0x0A

section .bss
grid: resb rows * cols
nextGrid: resb rows * cols
tmp: resb 8

section .text
_start:
    call resetGrids

    call play

    call printTable


    mov rdi, 3
    mov rsi, 3
    call countNeighbors

    add r10, '0'
    mov [tmp], r10

    mov rax, 4
    mov rbx, 1
    mov rcx, tmp
    mov rdx, 8
    int 80h


    jmp exit

play:
    call computeNextGen
    ret

computeNextGen:

    ret

applyRules:
    ret

countNeighbors:
    xor r10, r10    ; count
    xor rdx, rdx    ; required for division

    ; rdi = row
    ; rsi = col

    ; grid[row-1][col]
    mov rax, cols               ; rax = number of cells in a full row
    mov rbx, rdi                ; row
    sub rbx, 1                  ; row-1
    mul rbx
    add rax, rsi                ; [row-1][col]
    ; sub rax, 1                ; col - 1
    mov bl, [grid + rax]        ; grid[row-1][col]
    sub rbx, empty              ; if it's empty it gives 0
    mov rax, rbx                ; moves to rax for the next step
    mov rcx, nonEmpty - empty   ; it divides rax with nonEmpty - empty (since we already subtracted empty we have to subtracted empty from nonEmpty (it can result negative numbers so it might be buggy))
    div rcx                     ; if it wasn't 0 division gives 1
    add r10, rax                ; increments the counter

    ; grid[row-1][col-1]
    mov rax, cols
    mov rbx, rdi
    sub rbx, 1
    mul rbx
    add rax, rsi
    sub rax, 1
    mov bl, [grid + rax]
    sub rbx, empty
    mov rax, rbx
    mov rcx, nonEmpty - empty
    div rcx
    add r10, rax

    ; grid[row-1][col+1]
    mov rax, cols
    mov rbx, rdi
    sub rbx, 1
    mul rbx
    add rax, rsi
    add rax, 1
    mov bl, [grid + rax]
    sub rbx, empty
    mov rax, rbx
    mov rcx, nonEmpty - empty
    div rcx
    add r10, rax

    ; grid[row][col-1]
    mov rax, cols
    mul rdi
    add rax, rsi
    sub rax, 1
    mov bl, [grid + rax]
    sub rbx, empty
    mov rax, rbx
    mov rcx, nonEmpty - empty
    div rcx
    add r10, rax

    ; grid[row][col+1]
    mov rax, cols
    mul rdi
    add rax, rsi
    add rax, 1
    mov bl, [grid + rax]
    sub rbx, empty
    mov rax, rbx
    mov rcx, nonEmpty - empty
    div rcx
    add r10, rax

    ; grid[row+1][col]
    mov rax, cols
    mov rbx, rdi
    add rbx, 1
    mul rbx
    add rax, rsi
    mov bl, [grid + rax]
    sub rbx, empty
    mov rax, rbx
    mov rcx, nonEmpty - empty
    div rcx
    add r10, rax

    ; grid[row+1][col-1]
    mov rax, cols
    mov rbx, rdi
    add rbx, 1
    mul rbx
    add rax, rsi
    sub rax, 1
    mov bl, [grid + rax]
    sub rbx, empty
    mov rax, rbx
    mov rcx, nonEmpty - empty
    div rcx
    add r10, rax

    ; grid[row+1][col+1]
    mov rax, cols
    mov rbx, rdi
    add rbx, 1
    mul rbx
    add rax, rsi
    add rax, 1
    mov bl, [grid + rax]
    sub rbx, empty
    mov rax, rbx
    mov rcx, nonEmpty - empty
    div rcx
    add r10, rax

    ret

resetGrids:
    mov rcx, rows * cols
    .loopGrid:
        mov byte [grid + rcx - 1], nonEmpty
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