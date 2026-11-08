[org 0x0100]
jmp start
palname db 'game.pal', 0 ;load the palette indices
bgname db 'start.raw', 0 ; load the raw image file

; sprites 
player_img db 'player.raw', 0
meteor_img db 'meteor.raw', 0
fuel1_img db 'fuel1.raw', 0
fuel2_img db 'fuel2.raw', 0
fuel3_img db 'fuel3.raw', 0
mine_img db 'mine.raw', 0
digits_img db 'digits.raw', 0

; gameover screen art

gameover_img db 'gameover.raw', 0
lblscore_img db 'lblscore.raw', 0
lbltime_img db 'lbltime.raw', 0
end_bg db 'start.raw', 0 ; reuses the same start bg 

; menu options and their offsets in the sprite segment
start_selected db 'startsel.raw', 0 ; each of start and exit are 96 x 28 = 2688 bytes
start_dim db 'startdim.raw', 0
exit_selected db 'exitsel.raw', 0
exit_dim db 'exitdim.raw', 0

; offsets for sprite segment
startsel_offset equ 0
startdim_offset equ 2688
exitsel_offset equ 5376
exitdim_offset equ 8064

; background for levels and some booleans
level_bg db 'lvl1bg.raw', 0
isSelected db 0 ; 0 means start is selected, 1 would mean exit is selected
isAtStart db 0 ; 0 means yes, 1 would mean no
currLvlv db 1

; constants for sprite sizes
PLAYER_W equ 32
PLAYER_H equ 32
METEOR_W equ 6
METEOR_H equ 22
FUEL_W equ 16
FUEL_H equ 16
MINE_W equ 24
MINE_H equ 24

; sizes. These will be stored in cx when reading files
PLAYER_SZ equ PLAYER_W * PLAYER_H
METEOR_SZ equ METEOR_W * METEOR_H
FUEL_SZ equ FUEL_W * FUEL_H
MINE_SZ equ MINE_W * MINE_H

; gameplay sprites sit right after the menu images in the sprite segment
; we'll be loading our sprites in these buffers
player_offset equ exitdim_offset + 2688
meteor_offset equ player_offset + PLAYER_SZ
fuel1_offset equ meteor_offset + METEOR_SZ
fuel2_offset equ fuel1_offset + FUEL_SZ
fuel3_offset equ fuel2_offset + FUEL_SZ
mine_offset equ fuel3_offset + FUEL_SZ

; sprite descriptors for draw_sprite: offset in sprseg, width, height
player_desc dw player_offset, PLAYER_W, PLAYER_H
meteor_desc dw meteor_offset, METEOR_W, METEOR_H
fuel1_desc dw fuel1_offset, FUEL_W, FUEL_H
fuel2_desc dw fuel2_offset, FUEL_W, FUEL_H
fuel3_desc dw fuel3_offset, FUEL_W, FUEL_H
mine_desc dw mine_offset, MINE_W, MINE_H

; digits 0-9 are stacked in one file. Each digit is 12x16
DIGIT_W equ 12
DIGIT_H equ 16
DIGIT_SZ equ DIGIT_W * DIGIT_H
DIGITS_TOTAL equ DIGIT_SZ * 11 ; digits 0-9 and then a colon
COLON equ 10
digits_offset equ mine_offset + MINE_SZ
digit_desc dw 0, DIGIT_W, DIGIT_H

; game over screen art is stored after digits in the sprite segment
GAMEOVER_W equ 156
GAMEOVER_H equ 24
GAMEOVER_SZ equ GAMEOVER_H * GAMEOVER_W
LBL_W equ 60
LBL_H equ 16
LBL_SZ equ LBL_W * LBL_H
gameover_offset equ digits_offset + DIGITS_TOTAL ; digits total is the size, so we move to the offset after digits
lblscore_offset equ gameover_offset + GAMEOVER_SZ
lbltime_offset equ lblscore_offset + LBL_SZ

gameover_desc dw gameover_offset, GAMEOVER_W, GAMEOVER_H
lblscore_desc dw lblscore_offset, LBL_W, LBL_H
lbltime_desc dw lbltime_offset, LBL_W, LBL_H

; gameover screen layout
END_TITLE_X equ (320 - GAMEOVER_W) / 2 ; centered horizontally
END_TITLE_Y equ 3
END_LBL_X equ 88 ; for score and time
END_VAL_X equ 160 ; numbers sit next to the words
END_ROW1_Y equ 48 ; score row
END_ROW2_Y equ 70 ; time row
END_START_Y equ 104 ; start button
END_EXIT_Y equ 138 ; exit button

SCORE_DIGITS equ 4 ; store in cx
; position of the score
SCORE_X equ 320 - SCORE_DIGITS * DIGIT_W - 6 ; position at the top right
SCORE_Y equ 6 ; 6 pixels from top
TIMER_X equ 6 ; 6 pixels from top left
TIMER_Y equ 6 ; 6 pixels from top

score dw 0
seconds dw 120
pow10: dw 1, 10, 100, 1000 ; divisors

; starting positions for sprites
; these are only the initial values the live positions are the *_pos variables below
PLAYER_X equ (320 - PLAYER_W) / 2  ; bottom center
PLAYER_Y equ 200 - PLAYER_H - 10   ; 10 pixels of margin from the bottom
 
ROW_Y equ 80 ; a little above the vertical center (100)
METEOR_X equ 70 - METEOR_W / 2 ; the numbers are the horizontal centers
METEOR_Y equ ROW_Y - METEOR_H / 2
FUEL1_X equ 115 - FUEL_W / 2
FUEL1_Y equ ROW_Y - FUEL_H / 2
FUEL2_X equ 160 - FUEL_W / 2
FUEL2_Y equ ROW_Y - FUEL_H / 2
FUEL3_X equ 205 - FUEL_W / 2
FUEL3_Y equ ROW_Y - FUEL_H / 2
MINE_X equ 250 - MINE_W / 2
MINE_Y equ ROW_Y - MINE_H / 2

; live positions:
; each one is two words: x at [name], y at [name + 2]
player_pos dw PLAYER_X, PLAYER_Y
meteor_pos dw METEOR_X, METEOR_Y
fuel1_pos dw FUEL1_X, FUEL1_Y
fuel2_pos dw FUEL2_X, FUEL2_Y
fuel3_pos dw FUEL3_X, FUEL3_Y
mine_pos dw MINE_X, MINE_Y

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

; ax holds the sprite segment
; bp + 6 = offset of START
; bp + 4 = offset of EXIT
draw_end_menu:
    push bp
    mov bp, sp
    push ds
    push es
    push si
    push di
    push cx
    push dx

    mov ds, ax ; sprseg
    mov ax, 0a000h
    mov es, ax
    cld
    mov si, [bp + 6] ; offset of start
    mov di, END_START_Y * 320 + START_X
    call blit_option

    mov si, [bp + 4]
    mov di, END_EXIT_Y * 320 + EXIT_X
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

; skips transparent index (index 0) pixels. 
; arguments: sprite name, x pos, y pos

draw_sprite:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    mov ax, [bp + 4] ; y pos
    mov di, 320
    mul di ; y * 320
    add ax, [bp + 6] ; x
    mov di, ax
    mov bx, [bp + 8] ; the descriptor. Scroll up to see the full array 
    mov si, [bx] ; where the sprite starts inside the sprite segment
    mov cx, [bx + 2] ; width
    mov dx, [bx + 4] ; height
    mov bx, cx ; bx = width, we keep this in memory to determine end of each row

    mov ax, [sprseg]
    mov ds, ax
    mov ax, 0a000h
    mov es, ax
    cld
.row:
    mov cx, bx ; the width basically
.pixel:
    lodsb
    or al, al
    jz .skip ; if al is index 0, then skip
    mov [es:di], al
.skip:
    inc di
    loop .pixel
    add di, 320 ; jump to next row
    sub di, bx ; start of the width
    dec dx ; decrement rows
    jnz .row

    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 6

; arguments: digit, x pos, y pos
draw_digit:
    push bp
    mov bp, sp
    push ax
    push bx
    push dx

    ; to get a specific digit, we do digit * digit_size (192)
    mov ax, [bp + 8] ; the digit
    mov bx, DIGIT_SZ
    mul bx
    add ax, digits_offset ; jumps to the start of the digit we want to print
    mov [digit_desc], ax

    push word digit_desc
    push word [bp + 6] ; x
    push word [bp + 4] ; y
    call draw_sprite

    pop dx
    pop bx
    pop ax
    pop bp
    ret 6

; arguments: value, digit count, x pos, y pos
draw_number:
    push bp
    mov bp, sp
    push ax
    push bx
    push dx
    push si
    push di

    mov ax, [bp + 10] ; the value
    mov si, [bp + 8] ; number of digits i.e 4
    dec si
    shl si, 1; for words
    mov di, [bp + 6] ; x of the next digit

.digit:
    mov bx, [pow10 + si] ; 1000, then 100, then 10 and then 1
    xor dx, dx
    div bx 
    push dx 
    push ax
    push di ; x
    push word [bp + 4] ; y
    call draw_digit
    pop ax
    add di, DIGIT_W
    sub si, 2
    cmp si, 0
    jge .digit

    pop di
    pop si
    pop dx
    pop bx
    pop ax
    pop bp
    ret 8

draw_time: 
    push bp
    mov bp, sp
    push ax
    push bx
    push dx

    mov ax, [seconds]
    xor dx, dx
    mov bx, 60
    div bx
    push dx

    push ax
    push word 1
    push word [bp + 6] ; x pos
    push word [bp + 4] ; y pos
    call draw_number

    mov ax, [bp + 6] ; calculate colon position using last digit position
    add ax, DIGIT_W
    push word COLON
    push ax ; x pos
    push word [bp + 4]
    call draw_digit

    pop ax ; the saved seconds
    mov bx, [bp + 6]
    add bx, 2 * DIGIT_W ; two digits to the right
    push ax
    push word 2
    push bx ; x pos
    push word [bp + 4]
    call draw_number

    pop dx
    pop bx
    pop ax
    pop bp
    ret 4

draw_hud:
    push word [score]
    push word SCORE_DIGITS
    push word SCORE_X
    push word SCORE_Y
    call draw_number

    push word TIMER_X
    push word TIMER_Y
    call draw_time
    ret

; put file name into dx before calling this function
show_background:
    mov ax, [bgseg]
    mov bp, 0
    mov cx, 64000
    call load_file

    push ds
    mov ax, [bgseg]
    mov ds, ax
    xor si, si
    mov ax, 0a000h
    mov es, ax
    xor di, di
    mov cx, 32000 ; words
    cld
    rep movsw
    pop ds
    ret

; reset variables
reset_game:
    mov word [score], 0
    mov word [seconds], 120
    mov word [player_pos], PLAYER_X
    mov word [player_pos + 2], PLAYER_Y
    mov word [meteor_pos], METEOR_X
    mov word [meteor_pos + 2], METEOR_Y
    mov word [fuel1_pos], FUEL1_X
    mov word [fuel1_pos + 2], FUEL1_Y
    mov word [fuel2_pos], FUEL2_X
    mov word [fuel2_pos + 2], FUEL2_Y
    mov word [fuel3_pos], FUEL3_X
    mov word [fuel3_pos + 2], FUEL3_Y
    mov word [mine_pos], MINE_X
    mov word [mine_pos + 2], MINE_Y
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
    cmp byte [isAtStart], 0
    jne past_start

    mov dl, [isSelected]
    xor ah, ah
    int 16h
    cmp ah, 048h
    jne moveCursorDown

    mov byte [isSelected], 0
    cmp [isSelected], dl
    jz noCursorChange
    jmp load_menu
moveCursorDown:
    cmp ah, 050h
    jne noCursorChange
    mov byte [isSelected], 1
    cmp [isSelected], dl
    jz noCursorChange
    jmp load_menu

noCursorChange:
    cmp ah, 01ch
    jne listen_kb
    cmp byte [isSelected], 1
    jne past_start
    jmp exitGame
    ; only other case is 0, in which case we go past start

past_start:
    ; render level background
    mov ax, [bgseg]
    mov dx, level_bg
    mov bp, 0
    mov cx, 64000
    call load_file
    
    ; now copy to the screen
    push ds
    mov ax, [bgseg]
    mov ds, ax
    xor si, si
    mov ax, 0a000h
    mov es,ax
    xor di, di
    mov cx, 32000
    cld
    rep movsw
    pop ds

    ; now load the sprites into their respective buffers
    mov ax, [sprseg]
    mov dx, player_img
    mov bp, player_offset
    mov cx, PLAYER_SZ
    call load_file

    mov ax, [sprseg]
    mov dx, meteor_img
    mov bp, meteor_offset
    mov cx, METEOR_SZ
    call load_file

    mov ax, [sprseg]
    mov dx, fuel1_img
    mov bp, fuel1_offset
    mov cx, FUEL_SZ
    call load_file
 
    mov ax, [sprseg]
    mov dx, fuel2_img
    mov bp, fuel2_offset
    mov cx, FUEL_SZ
    call load_file
 
    mov ax, [sprseg]
    mov dx, fuel3_img
    mov bp, fuel3_offset
    mov cx, FUEL_SZ
    call load_file

    mov ax, [sprseg]
    mov dx, mine_img
    mov bp, mine_offset
    mov cx, MINE_SZ
    call load_file

    mov ax, [sprseg]
    mov dx, digits_img
    mov bp, digits_offset
    mov cx, DIGITS_TOTAL
    call load_file

    ; draw on top of the background
    push word player_desc
    push word [player_pos] ; x
    push word [player_pos + 2] ; y
    call draw_sprite

    push word meteor_desc
    push word [meteor_pos]
    push word [meteor_pos + 2]
    call draw_sprite
 
    push word fuel1_desc
    push word [fuel1_pos]
    push word [fuel1_pos + 2]
    call draw_sprite
 
    push word fuel2_desc
    push word [fuel2_pos]
    push word [fuel2_pos + 2]
    call draw_sprite
 
    push word fuel3_desc
    push word [fuel3_pos]
    push word [fuel3_pos + 2]
    call draw_sprite

     push word mine_desc
    push word [mine_pos]
    push word [mine_pos + 2]
    call draw_sprite

    call draw_hud

    xor ah, ah
    int 16h ; for now any key ends the game. Later you jump to game_over when time runs out or you hit a mine/meteor

game_over:
    ; background first
    mov dx, end_bg
    call show_background

    ; load game over art into sprite segment!!
    mov ax, [sprseg]
    mov dx, gameover_img
    mov bp, gameover_offset
    mov cx, GAMEOVER_SZ
    call load_file

    mov ax, [sprseg]
    mov dx, lblscore_img
    mov bp, lblscore_offset
    mov cx, LBL_SZ
    call load_file

    mov ax, [sprseg]
    mov dx, lbltime_img
    mov bp, lbltime_offset
    mov cx, LBL_SZ
    call load_file

    ;title
    push word gameover_desc
    push word END_TITLE_X
    push word END_TITLE_Y
    call draw_sprite

    ; score row. Word then number
    push word lblscore_desc
    push word END_LBL_X
    push word END_ROW1_Y
    call draw_sprite

    push word [score]
    push word SCORE_DIGITS
    push word END_VAL_X
    push word END_ROW1_Y

    ; time row: word then time
    push word lbltime_desc
    push word END_LBL_X
    push word END_ROW2_Y
    call draw_sprite

    push word END_VAL_X
    push word END_ROW2_Y
    call draw_time

    mov byte [isSelected], 0 ; start is highlighted

end_buttons:
    mov ax, [sprseg]
    cmp byte [isSelected], 0
    jne end_exit_chosen
    push word startsel_offset
    push word exitdim_offset
    jmp end_draw

end_exit_chosen:
    push word startdim_offset
    push word exitsel_offset
end_draw:
    call draw_end_menu
end_kb:
    xor ah, ah
    int 16h
    cmp ah, 048h ; up
    jne end_down
    mov byte [isSelected], 0
    jmp end_buttons
end_down:
    cmp ah, 050h ; down
    jne end_enter
    mov byte [isSelected], 1
    jmp end_buttons
end_enter:
    cmp ah, 01ch
    jne end_kb ; some other key, keep waiting
    cmp byte [isSelected], 1
    jne play_again
    jmp exitGame

play_again:
    call reset_game
    jmp past_start

exitGame:
    mov ax, 3
    int 10h
    mov ax, 4c00h
    int 21h
fail:
    mov ax, 3
    int 10h
    mov ax, 4c01h
    int 21h
