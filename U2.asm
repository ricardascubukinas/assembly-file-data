;; Author Ričardas Čubukinas
;;

.model small
.stack 100h

JUMPS


.data
    help        db 'This program prints all symbol differences & their positions between two files', 13,10, '$'
    error_file  db 'File couldn't be opened for reading', 13, 10, '$'
.code
    
start:
    mov ax, @data
    mov ds, ax


ending:
    mov ax, 4Ch
    mov al, 00h
    int 21h
            
end start
