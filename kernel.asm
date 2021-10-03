[BITS 16]

%include "size_kernel.asm"

[ORG address_kernel]

begin:
    mov [DriveId],dl

; resetStackRegisters:
;     xor ax,ax   
;     mov ds,ax ; set ds to 0
;     mov es,ax ; set es to 0
;     mov ss,ax ; set ss to 0
;     mov sp,07e00 ; stack offset	

ReportKernelStart:    
checkRegisters:    
    ; mov dx,[DriveId]
    ; call print_hex

    mov bx, Message
    call print_string
    call print_new_line
    call print_new_line
    call print_new_line
    call timeout

Daedalus4:
    mov bx,MessageInput
    call print_string	
	call print_new_line

    mov word[buffer16+1],0 ; #0 - for input, #1 - null termination
loop4:
    mov ah,0x0 ; get keystroke
    int 0x16

    ; print the symbol back (echo)
    mov byte[buffer16], al
    mov bx,buffer16
    call print_string

    ; compare the symbol with ENTER
    mov al,[ENTERKEY]
    cmp byte[buffer16], al
    je Back
    jmp loop4

Back:    
	call print_new_line

    jmp Daedalus4

end:
    hlt
    jmp end

DriveId:    db 0
Message: db "KERNEL IS RUNNING!",0
buffer16: times 16 db 0
ENTERKEY: db 0x0d
MessageInput:    db "Input values and press Enter", 0

%include "print_hex.asm"
;%include "print_string.asm"
%include "time.asm"



finalize:    
    ;%include "size_kernel.asm"
    times (size_kernel*512 - ($-$$)) db 0