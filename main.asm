[org 0x0100]
jmp start
palname db 'game.pal', 0 ;load the palette indices
bgname db 'start.raw', 0 ; load the raw image file

start_selected db 'startsel.raw', 0 ; each of start and exit are 96 x 28 = 2688 bytes
start_dim db 'startdim.raw', 0
exit_selected db 'exitsel.raw', 0
exit_dim db 'exitdim.raw', 0

; offsets for sprite segment
startsel_offset equ 0
startdim_offset equ 2688
exitsel_offset equ 5376
exitdim_offset equ 8064

player_img db 'player.raw', 0
meteor_img db 'meteor.raw', 0
level_bg db 'lvl1bg.raw', 0
isSelected db 0 ; 0 means start is selected, 1 would mean exit is selected

; menu layout: 96x28 images, centered horizontally, 6px gap between them
OPT_W equ 96
OPT_H equ 28
START_X equ 112          ; (320 - 96) / 2
START_Y equ 69           ; (200 - (28 + 6 + 28)) / 2
EXIT_X equ 112
EXIT_Y equ 103           ; START_Y + 28 + 6

bgseg dw 0 ; these two hold the positions of our segments.
sprseg dw 0
palbuf times 768 db 0

load_file:
    ; this function opens bg.pal and writes it to palbuf

    ; CX is 768: the number of bytes to read.
    push ax ; save destination segment e.g for the bg or for the sprite
    mov ax, 3d00h ; 3d for opening a file, 00 for read-only mode
    int 21h ; OPEN FILE: at ds:dx in read-only
    jnc .opened ; carry flag is set to 1 if the file read operation fails
    jmp fail 
.opened:
    mov bx, ax ; BX NOW CONTAINS THE FILE HANDLE. No need to mention the file name again
    pop ax
    push ds ;
    mov ds, ax ; the segment itself.
    mov dx, bp ; need the offset where we're gonna write in dx
    mov ah, 3fh ; READ FILE: file handle service.
    int 21h 
    pop ds
    mov ah, 3eh ; closing file
    int 21h
    ret

draw_menu:
; ax holds the sprite segment
; bp + 6 = offset of START
; bp + 4 = offset of EXIT
    push bp
    mov bp ,sp
    push ds
    push es
    push si
    push di
    push cx
    push dx

    mov ds, ax ; load sprseg into ds
    mov ax, 0a000h
    mov es, ax
    cld
    ; draw start option 
    mov si, [bp + 6]
    mov di, START_Y * 320 + START_X
    call blit_option

    ; now draw exit option
    mov si, [bp + 4]
    mov di, EXIT_Y * 320 + EXIT_X
    call blit_option

    pop dx
    pop cx
    pop di
    pop si
    pop es 
    pop ds
    mov sp, bp
    pop bp
    ret 4

blit_option:
    mov dx, OPT_H ; height of the text
.row:
    mov cx, OPT_W / 2 ; divide to get words
    rep movsw ; write one row
    add di, 320 - OPT_W ; go to the next row
    dec dx
    jnz .row
    ret


; This part loads the palette so don't touch this. 
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
    out dx, al ; about to write at color slot 0
    inc dx
    mov si, palbuf
    mov cx, 768


pal: ; overwriting the DAC table with our palette
    lodsb ; AL = [DS:SI], and we increment si
    out dx, al
    loop pal

; Can start tinkering from here. Right now we're loading the start bg and drawing it on vga frame buffer
    ; load background into an off screen segment
load_bg:
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
    
    push cs
    pop ds

; load start menu over the bg now
load_menu:
    mov ax, [bgseg]
    add ax, 1000h ; the second free segment we'll be using for sprites
    mov [sprseg], ax ; sprseg now holds address of the segment after bgseg

    ; load all four sprites in memory

    mov ax, [sprseg]
    mov dx, start_selected
    mov bp, startsel_offset
    mov cx, 2688
    call load_file

    mov ax, [sprseg]
    mov dx, start_dim
    mov bp, startdim_offset
    mov cx, 2688
    call load_file

    mov ax, [sprseg]
    mov dx, exit_selected
    mov bp, exitsel_offset
    mov cx, 2688
    call load_file

    mov ax, [sprseg]
    mov dx, exit_dim
    mov bp, exitdim_offset
    mov cx, 2688
    call load_file

show_menu:
    mov ax, [sprseg]
    cmp byte [isSelected], 0
    jne exit_chosen
    push word startsel_offset
    push word exitdim_offset
    jmp drawMenu

exit_chosen:
    push word startdim_offset
    push word exitsel_offset
drawMenu:
    call draw_menu

    ; wait for a key and restore text mode, exist
listen_kb:
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


