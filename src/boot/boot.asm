ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start
    nop

times 33 db 0

start:
    jmp 0:step2

step2:
    cli ; Clear Interrupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enables Interrupts


.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax,cr0
    or  eax, 0x1
    mov cr0,eax
    jmp CODE_SEG:load32

;GDT
gdt_start:
gdt_null: ;allocate 0 for first 8 bytes
    dd 0x0
    dd 0x0

;OFFSET 0x08 (gtd_null did allocate 0 for 8 byte of ram)
gdt_code:       ;Code Segment Register should point to this label
    dw 0xffff   ; Segment limit first 0-15 bits
    dw 0x0000   ; Base first 0-15 bits
    db 0x00     ; Base 16-23 bits
    db 0x9a     ; Access byte
    db 11001111b; High 4 bit flags and the low 4 bit flags
    db 0        ; Base 24-31 bits

; 0x08 + 8(byte) = 0x10

;OFFSET 0x10
gdt_data:       ; it'll point to DS ,SS, ES,FS,GS Registers
    dw 0xffff   ; Segment limit first 0-15 bits
    dw 0x0000   ; Base first 0-15 bits
    db 0x00     ; Base 16-23 bits
    db 0x92     ; Access byte
    db 11001111b; High 4 bit flags and the low 4 bit flags
    db 0        ; Base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start -1; our descriptor size
    dd gdt_start; our descriptor size

[BITS 32]
load32:
    mov eax, 1          ;2nd kenel sector(boot sector is 0) -----LBA
    mov ecx, 100        ;how many sector we want to load to memory(if it is changed changed makefile dd sector count count=?)
    mov edi, 0x0100000  ;starting address of the ram which we want to load our kernel into (notice we read-mode specify 1 MG of memory to our boot ) 
                        ;(0-1000000[bytes])->boot section && (1000000-?[bytes])->kernel section of the ram
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax ;Backup the LBA
    ;Send the highest 8 bits of the lba to hard disk controller
    shr eax, 24
    or  eax, 0xE0 ; Select the master drive
    mov dx , 0x1F6
    out dx , al
    ;Finished sending the highest 8 bits of the lba

    ;Send the total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al
    ;Finished sending the total sectors to read

    ;Send more bits of the LBA
    mov eax, ebx ;Restore the backup LBA
    mov dx, 0x1F3
    out dx, al
    ;Finished sending more bits of the LBA

    ;Send more bits of the LBA
    mov dx, 0x1F4
    mov eax, ebx ; Restore the Backup LBA
    shr eax, 8
    out dx, al
    ;Finished sending more bits of the LBA

    ;Send upper 16 bits of the LBA
    mov dx, 0x1F5
    mov eax, ebx ; Restore the Backup LBA
    shr eax, 16
    out dx, al
    ;Send upper 16 bits of the LBA

    mov dx, 0x1F7
    mov al, 0x20
    out dx, al

    ;Read all sectors into memory
.next_sector:
    push ecx

;Checking if we need to read
.try_again:
    mov  dx, 0x1F7
    in   al, dx
    test al, 8
    jz .try_again

;we nead to read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw          ; goind to read 512 bytes(or 256 words) = 1sector from our virtual hard drive to ram at the address of 1000000 bytes where kenel ram section starts 
    pop ecx
    loop .next_sector ; 100 99 98 97 96 ... 0 when it hits zero all bytes are written to ram
    ;End of reading sectors into memory
    ret

times 510-($ - $$) db 0
dw 0xAA55