
; print the string pointed to by bx
print_string:     ; Push registers onto the stack
  pusha

string_loop:
  mov al, [bx]    ; Set al to the value at bx
  cmp al, 0       ; Compare the value in al to 0 (check for null terminator)
  jne print_char  ; If it's not null, print the character at al
                  ; Otherwise the string is done, and the function is ending
  popa            ; Pop all the registers back onto the stack
  ret             ; return execution to where we were

print_char:
  mov ah, 0x0e    ; Linefeed printing
  int 0x10        ; Print character
  add bx, 1       ; Shift bx to the next character
  jmp string_loop ; go back to the beginning of our loop


print_new_line:
    pusha
	
	mov ah, 0x03 ; get cursor pos to dh,dl
	mov bh,0
	int 0x10
	
	inc dh ; new line
	mov dl,0   ; beginning of line
	mov ah, 0x02 ; set cursor pos from dh,dl
	mov bh,0
	int 0x10

    popa
    ret

    ;section .data
        ;New line string
        NEWLINE: db 0xa, 0xd
        LENGTH: equ $-NEWLINE