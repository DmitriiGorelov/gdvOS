[BITS 16]
[ORG 0x7c00]

%include "size_loader.asm"

global _start

_start:    
    jmp resetStackRegisters

resetStackRegisters:
    xor ax,ax   
    mov ds,ax ; set ds to 0
    mov es,ax ; set es to 0
    mov ss,ax ; set ss to 0
    mov sp,0x7c00 ; set stack pointer to 0x7c00 - location is Below the MBR (stack grows downwards)
	
    ; after registers reset
    mov [DriveId],dl ; save disk id

; DiskExtensionStart:
; 	mov bx, MessageDiskExt
; 	call print_string
; 	;call print_new_line
; 	call timeout	
	
TestDiskExtension:
    ;mov [DriveId],dl ; we did this on top
    ;mov dl, [DriveId]
    mov ah,0x41
    mov bx,0x55aa
    int 0x13
    jc NotSupport1
    cmp bx,0xaa55
    jne NotSupport2

DiskExtensionSuccess:
    mov bx, MessageDiskExt
	call print_string
	mov bx, MessageSuccess
	call print_string
	call print_new_line
	call timeout		
	

;     mov cx,5
; checkLoop:
;     mov [ReadPacket],cx
;     mov dx,[ReadPacket]
;     call print_hex
;     loop checkLoop

setVideoMode:
    ;mov ax,3
    ;int 0x10
    
checkRegisters:    
    ; mov dx,MessageInput
    ; call print_hex

    ; jmp End

LoadLoader:
    mov bx, MessageStartLoader
    call print_string
	;call print_new_line
	call timeout

    mov si,ReadPacket
    mov word[si],0x10
    mov bx,size_loader
    mov word[si+2],bx ; loader size as agreed
    mov word[si+4],0x7e00
    mov word[si+6],0 ; this is segment, so result will be 0x7e00
    mov dword[si+8],1 ; start segment
    mov dword[si+0xc],0
    mov dl,[DriveId]
    mov ah,0x42
    int 0x13
    jc  ReadError

    mov dl,[DriveId]
    jmp 0x7e00 ;result will be 0x7e00

NotSupport1:
    mov bx, Message1
    call print_string
	call print_new_line
	call timeout
    jmp End

NotSupport2:
    mov bx, Message2
    call print_string
	call print_new_line
	call timeout
    jmp End

ReadError:
    mov bx, MessageError
    call print_string
	call print_new_line
	call timeout
    jmp End

End:
    hlt    
    jmp End
    
%include "print_string.asm"
%include "time.asm"

DriveId:    db 0
MessageDiskExt: db "Disk extentions test....",0
MessageSuccess: db "SUCCESS!", 0
MessageError: db "ERROR!", 0
Message1:    db "Disk extentions test ERROR - NOT SUPPORTED!", 0
Message2:    db "Disk extentions test ERROR - TEST FAILED!", 0

MessageStartLoader: db "Start loader...", 0
ReadPacket: times 16 db 0

times (0x1be-($-$$)) db 0

    db 80h
    db 0,2,0
    db 0f0h
    db 0ffh,0ffh,0ffh
    dd 1
    dd (20*16*63-1)
	
    times (16*3) db 0

    db 0x55
    db 0xaa

	
