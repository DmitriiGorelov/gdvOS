[BITS 16]
[ORG 0x7e00]

%include "size_kernel.asm"
%include "size_loader.asm"

start:
    mov [DriveId],dl

    mov bx,MessageLoaderIsRunning
    call print_string
    call print_new_line
    call print_new_line
    jmp CheckMemory1
; ------------------------------------------ check available memory for real mode

CheckMemory1:
    ; Clear carry flag
    clc
    
    mov bx,MessageTestMemory1
    call print_string
    ; Switch to the BIOS (= request low memory size)
    int 0x12
    ; The carry flag is set if it failed
    jc CheckMemory1Error

    mov dx,ax ; result of int 0x12, in kB
    call print_hex4
    call print_new_line
    call CheckMemory2
    jmp Check1
 
CheckMemory1Error:
    mov bx,MessageError
    call print_string
    call print_new_line
    call CheckMemory2
    jmp Check1

; iterate over memory map
CheckMemory2:
    pusha    
    mov bx,MessageTestMemory2
    call print_string    
    call print_new_line
    
    xor ebx,ebx ; beginning of map. ebx will be incremented automatically by bios
CheckMemory2Loop:
    mov eax,0xe820
    mov edx,0x534D4150    
    mov edi, MemoryMapRecord
    mov ecx, 24
    int 0x15
    
    jc CheckMemory2Error1

    cmp eax,0x534D4150
    jne CheckMemory2Error2

    call func_CheckMemory2Output

    cmp ebx,0    
    je CheckMemory2Finish

    ;call func_Output
    cmp cl,0    
    je CheckMemory2Finish

    ;call func_Output
    jmp CheckMemory2Loop

    ; size of returned data block
    ; xor dx,dx
    ; mov dl,cl 
    ; call print_hex    
                ; printout Starting addr and Length in reversed bytes order
                func_CheckMemory2Output:                    
                    pusha
                    cmp dword[MemoryMapRecord+16], 1 ; if memory type is not 1=USER-> return
                    jne end_CheckMemory2Output

                    ; starting address of memory block
                    mov cx,8
                    mov bx,7
                    ;mov cx,cl ; cx already contains size in bytes
                    locLoops:
                    mov dx, [MemoryMapRecord+bx]    
                    call print_hex2    
                    dec bx
                    loop locLoops

                    ; print separator
                    mov bx,MessageSeparator
                    call print_string

                    ; length of memory block
                    mov cx,8
                    mov bx,15
                    ;mov cx,cl ; cx already contains size in bytes
                    locLoopl:
                    mov dx, [MemoryMapRecord+bx]    
                    call print_hex2    
                    dec bx
                    loop locLoopl

                    call print_new_line

                    end_CheckMemory2Output:
                    popa
                    ret
    ;call print_new_line

    ;jmp CheckMemory2Loop

CheckMemory2Finish:
    mov bx, MessageSuccess
    call print_string
    call print_new_line
    jmp CheckMemory2Ret

CheckMemory2Error1:
    mov bx, MessageENotSupport
    call print_string
    call print_new_line
    jmp CheckMemory2Ret

CheckMemory2Error2:
    mov bx, MessageError
    call print_string
    call print_new_line
    jmp CheckMemory2Ret

CheckMemory2Ret:
    popa
    ret
; ------------------------------------------ Check1 highest service index -------------------------
Check1:    
    mov bx,MessageC1
	call print_string

    mov eax,0x80000000    
    cpuid
    cmp eax,0x80000001
    jb NotSupport1
    jmp Support1

Support1:
	mov bx,MessageSuccess
	call print_string
	call print_new_line
	
    ; mov ah,0x13
    ; mov al,1
    ; mov bx,0xa
    ; mov dh,1
    ; mov dl,4
    ; mov bp,MessageS1
    ; mov cx,MessageLenS1
    ; int 0x10
    jmp Check2

NotSupport1:
	mov bx,MessageError
	call print_string
	call print_new_line
	
    ; mov ah,0x13
    ; mov al,1
    ; mov bx,0xa
    ; mov dh,1
    ; mov dl,4
    ; mov bp,MessageE1
    ; mov cx,MessageLenE1
    ; int 0x10
    jmp Check2
; --------------------------------------- Check2: Long mode support --------------
Check2:
    mov bx,MessageC2
	call print_string

    mov eax,0x80000001
    cpuid
    test edx,(1<<29)
    jz NotSupport2
    jmp Support2

Support2:
	mov bx,MessageSuccess
	call print_string
	call print_new_line
    ; mov ah,0x13
    ; mov al,1
    ; mov bx,0xa
    ; mov dh,2
    ; mov dl,4
    ; mov bp,MessageS2
    ; mov cx,MessageLenS2
    ; int 0x10
    jmp Check3

NotSupport2:
	mov bx,MessageError
	call print_string
	call print_new_line
    ; mov ah,0x13
    ; mov al,1
    ; mov bx,0xa
    ; mov dh,2
    ; mov dl,4
    ; mov bp,MessageE2
    ; mov cx,MessageLenE2
    ; int 0x10
    jmp Check3
; ----------------------------------------- Check3: Extra page size 
Check3:
    mov bx,MessageC3
	call print_string

    mov eax,0x80000001
    cpuid
    test edx,(1<<3)
    jz NotSupport3
    jmp Support3

Support3:
	mov bx,MessageSuccess
	call print_string
	call print_new_line
    ; mov ah,0x13
    ; mov al,1
    ; mov bx,0xa
    ; mov dh,3
    ; mov dl,4
    ; mov bp,MessageS3
    ; mov cx,MessageLenS3
    ; int 0x10    
    jmp Check4

NotSupport3:
	mov bx,MessageError
	call print_string
	call print_new_line
    ; mov ah,0x13
    ; mov al,1
    ; mov bx,0xa
    ; mov dh,3
    ; mov dl,4
    ; mov bp,MessageE3
    ; mov cx,MessageLenE3
    ; int 0x10    
    jmp Check4
; ------------------------------------------ Check4: 1Gb page size
Check4:
    mov bx,MessageC4
	call print_string

    mov eax,0x80000001
    cpuid
    test edx,(1<<26)
    jz NotSupport4   
    jmp Support4

Support4:
	mov bx,MessageSuccess
	call print_string
	call print_new_line
    ; mov ah,0x13
    ; mov al,1
    ; mov bx,0xa
    ; mov dh,4
    ; mov dl,4
    ; mov bp,MessageS4
    ; mov cx,MessageLenS4
    ; int 0x10    
    jmp Check5

NotSupport4:
	mov bx,MessageError
	call print_string
	call print_new_line
    ; mov ah,0x13
    ; mov al,1
    ; mov bx,0xa
    ; mov dh,4
    ; mov dl,4
    ; mov bp,MessageE4
    ; mov cx,MessageLenE4
    ; int 0x10    
    jmp Check5
; ------------------------------------------ Check5: 20 line, memory bus width
Check5:
    mov bx,MessageC5
	call print_string

    mov ax,0xffff
    mov es,ax
    mov word[ds:0x7C00],0xa200 ; 0:0x16+0x7c00 = 0x7c00 of data segment
    cmp word[es:0x7C10],0xa200  ; compare: 0xffff:0x7c10=0xffff*16+0x7c10=0x107c00
    jne Support5
    mov word[ds:0x7C00],0xb200 ; write again other value
    cmp word[es:0x7C10],0xb200 ; compare again
    je NotSupport5   
    jmp Support5    

Support5:
    xor ax,ax ; reset ax to 0
    mov es,ax ; rest es to 0

	mov bx,MessageSuccess
	call print_string
	call print_new_line
    ; mov ah,0x13
    ; mov al,1
    ; mov bx,0xa
    ; mov dh,5
    ; mov dl,4
    ; mov bp,MessageS5
    ; mov cx,MessageLenS5
    ; int 0x10    
    jmp TestResultMessage

NotSupport5:
    xor ax,ax ; reset ax to 0
    mov es,ax ; rest es to 0

	mov bx,MessageError
	call print_string
	call print_new_line
    ; mov ah,0x13
    ; mov al,1
    ; mov bx,0xa
    ; mov dh,5
    ; mov dl,4
    ; mov bp,MessageE5
    ; mov cx,MessageLenE5
    ; int 0x10    
    jmp TestResultMessage

; ----------------------------------------- Test result message
TestResultMessage:
	mov bx,MessageTestResult
	call print_string
	call print_new_line
    call timeout
    ; mov ah,0x13
    ; mov al,1
    ; mov bx,0xa
    ; mov dh,6
    ; mov dl,4
    ; mov bp,MessageTestResult
    ; mov cx,MessageTestResultLen 
    ; int 0x10
    jmp ReadKernel

; switch vide mode in kernel
; SetVideoMode:   	
;     mov ax,3
;     int 0x10

; ; from now on, we have an access to a video memory at 0xb8000 and have to write there directly in order to print anything
;     mov si,MessageVideoMode
;     ;mov di,0xb8000 ; too big for 16bit
;     mov ax,0xb800
;     mov es,ax
;     xor di,di
;     mov cx,MessageLenVM

; PrintMessage:
;     mov al,[si]
;     mov [es:di],al
;     mov byte[es:di+1],0xa
;     add di,2
;     add si,1
;     loop PrintMessage

;     call timeout

    jmp ReadKernel

; ------------------------------------------Read Kernel -------------------------
ReadKernel:

    mov bx,MessageKernelRead
	call print_string
	;call print_new_line
    call timeout

    mov si,ReadPacket
    mov word[si],0x10
    mov word[si+2],size_kernel    ; 100 sectors = ~50kb
    mov word[si+4],0      ; dst: offset=0 (direct 0x10000 cannot be located here in word, overflow)
    mov bx,address_kernel >> 4    
        ; mov dx,bx
        ; call print_hex4
        ; call print_new_line
    mov word[si+6],bx   ; dst: segment=0x1000. 
                          ; Calculation: segment(0x1000)->offset(0)=0x1000*16+offset(0) = 0x10000 
                          ; 0x10000 is a real address that we need
    mov bx, size_loader     ; size loader
    inc bx                  ; MBR loader
    ; dword - size of the data block to read in number of segments
    mov word[si+8],bx    ; src: MBR (locates in #0sect of boot.img) 
                          ; plus loader (we decided its size is 10sect) --> 
                          ; we start from 11th sector with kernel
    mov word[si+0xA],0

    mov dword[si+0xc],0
    mov dl,[DriveId]
    mov ah,0x42
    int 0x13
    jc  ReadKernelError
    jmp ReadKernelSuccess

ReadKernelSuccess:
	; mov bx,MessageSuccess
	; call print_string
	; call print_new_line
    ; call timeout


    ; mov ah,0x13
    ; mov al,1
    ; mov bx,0xa
    ; mov dh,7
    ; mov dl,4
    ; mov bp,MessageKernelReadSuccess
    ; mov cx,MessageKernelReadSuccessLen
    ; int 0x10

    mov dl,[DriveId]
    
    [BITS 16]
    jmp address_kernel ;

ReadKernelError:
	mov bx,MessageError
	call print_string
	call print_new_line
    call timeout
    ; mov ah,0x13
    ; mov al,1
    ; mov bx,0xa
    ; mov dh,7
    ; mov dl,4
    ; mov bp,MessageKernelReadError
    ; mov cx,MessageKernelReadErrorLen
    ; int 0x10    
    jmp End

End:
    hlt
    jmp End

DriveId:    db 0
MessageLoaderIsRunning: db "Loader is RUNNING!",0
MessageSuccess:    db "Success!",0
MessageError:    db "ERROR!",0
MessageENotSupport: db "Not supported!",0

MessageTestResult:    db "See test results above...",0

MessageTestMemory1: db "Test memory for real mode...",0
MessageTestMemory2: db "Get memory map...",0
MessageC1:    db "Get Highest Extended Function...",0
MessageC2:    db "Check Long mode support...",0
MessageC3:    db "Check Page size extension...",0
MessageC4:    db "Check HugePages 1GB... ",0
MessageC5:    db "Check Width of Memory bus is more than 20b...",0

MessageVideoMode:    db "Set Video Mode (Text) ... ",0
MessageLenVM: equ $-MessageVideoMode

MessageKernelRead:     db "Kernel read... ",0
MessageSeparator: db ", ",0

ReadPacket: times 16 db 0
MemoryMapRecord: times 24 db 0

%include "time.asm"
%include "print_hex.asm"


times (size_loader*512-($-$$)) db 0 ; fill in 10 sectors to the end - this is loader