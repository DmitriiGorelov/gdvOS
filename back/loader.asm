[BITS 16]
[ORG 0x7e00]

start:
    mov [DriveId],dl

; ------------------------------------------ Check1 highest service index -------------------------
Check1:    
    mov eax,0x80000000
    cpuid
    cmp eax,0x80000001
    jb NotSupport1
    jmp Support1

Support1:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    mov dh,1
    mov dl,4
    mov bp,MessageS1
    mov cx,MessageLenS1
    int 0x10
    jmp Check2

NotSupport1:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    mov dh,1
    mov dl,4
    mov bp,MessageE1
    mov cx,MessageLenE1
    int 0x10
    jmp Check2
; --------------------------------------- Check2: Long mode support --------------
Check2:
    mov eax,0x80000001
    cpuid
    test edx,(1<<29)
    jz NotSupport2
    jmp Support2

Support2:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    mov dh,2
    mov dl,4
    mov bp,MessageS2
    mov cx,MessageLenS2
    int 0x10
    jmp Check3

NotSupport2:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    mov dh,2
    mov dl,4
    mov bp,MessageE2
    mov cx,MessageLenE2
    int 0x10
    jmp Check3
; ----------------------------------------- Check3: Extra page size 
Check3:
    mov eax,0x80000001
    cpuid
    test edx,(1<<3)
    jz NotSupport3
    jmp Support3

Support3:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    mov dh,3
    mov dl,4
    mov bp,MessageS3
    mov cx,MessageLenS3
    int 0x10    
    jmp Check4

NotSupport3:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    mov dh,3
    mov dl,4
    mov bp,MessageE3
    mov cx,MessageLenE3
    int 0x10    
    jmp Check4
; ------------------------------------------ Check4: 1Gb page size
Check4:
    mov eax,0x80000001
    cpuid
    test edx,(1<<26)
    jz NotSupport4   
    jmp Support4

Support4:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    mov dh,4
    mov dl,4
    mov bp,MessageS4
    mov cx,MessageLenS4
    int 0x10    
    jmp Check5

NotSupport4:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    mov dh,4
    mov dl,4
    mov bp,MessageE4
    mov cx,MessageLenE4
    int 0x10    
    jmp Check5
; ------------------------------------------ Check5: 20 line, memory bus width
Check5:
    mov ax,0xffff
    mov es,ax
    mov word[ds:0x7c00],0xa200 ; 0:0x16+0x7c00 = 0x7c00 of data segment
    cmp word[es:0x7c10],0xa200  ; compare: 0xffff:0x7c10=0xffff*16+0x7c10=0x107c00
    jne Support5
    mov word[ds:0x7c00],0xb200 ; write again other value
    cmp word[es:0x7c10],0xb200 ; compare again
    je NotSupport5   
    jmp Support5    

Support5:
    xor ax,ax ; reset ax to 0
    mov es,ax ; rest es to 0

    mov ah,0x13
    mov al,1
    mov bx,0xa
    mov dh,5
    mov dl,4
    mov bp,MessageS5
    mov cx,MessageLenS5
    int 0x10    
    jmp TestResultMessage

NotSupport5:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    mov dh,5
    mov dl,4
    mov bp,MessageE5
    mov cx,MessageLenE5
    int 0x10    
    jmp TestResultMessage

; ----------------------------------------- Test result message
TestResultMessage:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    mov dh,6
    mov dl,4
    mov bp,MessageTestResult
    mov cx,MessageTestResultLen 
    int 0x10
    jmp SetVideoMode

SetVideoMode:   
    mov ax,3
    int 0x10

    mov si,MessageVM
    ;mov di,0xb8000 ; too big for 16bit
    mov ax,0xb800
    mov es,ax
    xor di,di
    mov cx,MessageLenVM

PrintMessage:
    mov al,[si]
    mov [es:di],al
    mov byte[es:di+1],0xa
    add di,2
    add si,1
    loop PrintMessage

    jmp End

; ------------------------------------------Read Kernel -------------------------
ReadKernel:
    mov si,ReadPacket
    mov word[si],0x10
    mov word[si+2],100    ; 100 sectors = ~50kb
    mov word[si+4],0      ; dst: offset=0 (direct 0x10000 cannot be located here in word, overflow)
    mov word[si+6],0x1000 ; dst: segment=0x1000. 
                          ; Calculation: segment(0x1000)->offset(0)=0x1000*16+offset(0) = 0x10000 
                          ; 0x10000 is a real address that we need
    mov dword[si+8],11    ; src: MBR (locates in #0sect of boot.img) 
                          ; plus loader (we decided its size is 10sect) --> 
                          ; we start from 11th sector with kernel
    mov dword[si+0xc],0
    mov dl,[DriveId]
    mov ah,0x42
    int 0x13
    jc  ReadKernelError
    jmp ReadKernelSuccess

ReadKernelSuccess:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    mov dh,7
    mov dl,4
    mov bp,MessageKernelReadSuccess
    mov cx,MessageKernelReadSuccessLen
    int 0x10

    mov dl,[DriveId]
    jmp 0x10000 

ReadKernelError:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    mov dh,7
    mov dl,4
    mov bp,MessageKernelReadError
    mov cx,MessageKernelReadErrorLen
    int 0x10    
    jmp End

End:
    hlt
    jmp End

DriveId:    db 0
MessageTestResult:    db "See test results above..."
MessageTestResultLen: equ $-MessageTestResult

MessageS1:    db "Success: Get Highest Extended Function"
MessageLenS1: equ $-MessageS1
MessageE1:    db "Error 1: Get Highest Extended Function not supported"
MessageLenE1: equ $-MessageE1

MessageS2:    db "Success: Long mode"
MessageLenS2: equ $-MessageS2
MessageE2:    db "Error 2: Long mode not supported"
MessageLenE2: equ $-MessageE2

MessageS3:    db "Success: Page size extension"
MessageLenS3: equ $-MessageS3
MessageE3:    db "Error 3: Page size extension not supported"
MessageLenE3: equ $-MessageE3

MessageS4:    db "Success: HugePages 1GB"
MessageLenS4: equ $-MessageS4
MessageE4:    db "Error 4: HugePages 1GB Not supported"
MessageLenE4: equ $-MessageE4

MessageS5:    db "Success: Width of Memory bus is more than 20b"
MessageLenS5: equ $-MessageS5
MessageE5:    db "Error 4: Width of Memory bus is only 20b"
MessageLenE5: equ $-MessageE5

MessageVM:    db "Success: Video Mode (Text) is set"
MessageLenVM: equ $-MessageVM

MessageKernelReadSuccess:    db "Success: Kernel read "
MessageKernelReadSuccessLen: equ $-MessageKernelReadSuccess
MessageKernelReadError:    db "Error: Kernel read failed "
MessageKernelReadErrorLen: equ $-MessageKernelReadError

ReadPacket: times 16 db 0

times 10*512 db 0 ; fill in 10 sectors to the end