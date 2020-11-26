;; Author Ričardas Čubukinas
;;

.model small
.stack 100h
CONST_READ_BUFFER_SIZE = 20

JUMPS


.data
    error_fopen             db "File couldn't be opened for reading", 13, 10, '$'
    msg_help                db "NAME",13,10,9, "U2 - Second assigment 1st variant", 13,10,13,10, '$'
    msg_help2               db "SYNOPSIS",13,10,9, "U2 [/?] FILENAME [FILENAME2]...",13,10,13,10, '$'
    msg_help3               db "DESCRIPTION",13,10,9, "This program counts the number of symbols, uppercase letters",13,10, '$'
    msg_help4               db 9, "lowercase letters as well as words of multiple files",13,10,13,10, '$'
    msg_symbol_count        db "Symbols in file: $"
    msg_uppercase_count     db "Uppercase letters in file: $"
    msg_lowercase_count     db "Lowercase letters in file: $"
    msg_words_count         db "Words in file: $"
    msg_newline             db 13, 10, '$'

    sourceFile              db 12 dup (0)
    sourceFileHandle        dw ?
    buffer                  db CONST_READ_BUFFER_SIZE dup (?)
    symbol_count            db 0
 
.code
    
start:
    mov ax, @data
    mov es, ax

    mov si, 81h

    call skip_spaces

    mov al, byte ptr ds:[si]
    cmp al, 13
    je help

    mov ax, word ptr ds:[si]
    cmp ax, 3F2Fh
    je help

help:
    mov ax, @data
    mov ds, ax

    mov dx, offset msg_help
    mov ah, 09h
    int 21h
    
    mov dx, offset msg_help2
    mov ah, 09h
    int 21h

    mov dx, offset msg_help3
    mov ah, 09h
    int 21h

    mov dx, offset msg_help4
    mov ah, 09h
    int 21h

    jmp ending


ending:
    mov ax, 4C00h
    mov al, 00h
    int 21h

skip_spaces PROC near
    skip_spaces_iterate:
        cmp byte ptr ds:[si], ' '
        jne skip_spaces_end
        inc si
        jmp skip_spaces_iterate
    skip_spaces_end:
        ret
skip_spaces ENDP

end start
