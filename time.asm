
timeout:
	pusha
    mov ah, 0x86
    mov cx, 0xf
    mov dx, 0x4240
    int 0x15

	popa
    ret