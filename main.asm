[org 0x0100]
jmp start
palname db 'bg.pal', 0 ;load the palette indices
bgname db 'bg.raw', 0 ; load the raw image file
bgseg dw 0
palbuf times 768 db 0

load_file:
    push ax ; save destination segment
    mov ax, 3d00h 
    int 21h ; open file at ds:dx in read-only
    jc fail ; 
    mov bx, ax
    pop ax
    push ds
    mov ds, ax
    mov dx, bp 
    mov ah, 3fh
    int 21h
    pop ds
    mov ah, 3eh
    int 21h
    ret

start:
    mov ax, 13h
    int 10h

    mov dx, palname
    mov ax, ds
    mov bp, palbuf
    mov cx, 768 ; bytes to read into palbuf
    call load_file

    mov dx, 3c8h
    xor al, al
    out dx, al ; about to write at color 0
    inc dx
    mov si, palbuf
    mov cx, 768

pal:
    lodsb ; AL = [DS:SI], and we increment si
    out dx, al
    loop pal

    ; load background into an off screen segment
    mov ax, cs
    add ax, 1000h
    mov [bgseg], ax
    mov dx, bgname
    mov bp, 0
    mov cx, 64000 ; 320x200
    call load_file

    ; copy background to screen

    mov ax, [bgseg]
    mov ds, ax
    xor si, si
    mov ax, 0a000h
    mov es, ax
    xor di, di
    mov cx, 32000
    cld
    rep movsw

    ; wait for a key and restore text mode, exist

    xor ah, ah
    int 16h
    mov ax, 3
    int 10h
    mov ax, 4c00h
    int 21h
fail:
    mov ax, 3
    int 10h
    mov ax, 4c01h
    int 21h


