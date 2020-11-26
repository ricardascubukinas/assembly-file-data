;; Author Ričardas Čubukinas
;; This program calculates statistical data about provided text files
;; and prints it out if there is no input or the input is /?
;; there is a help message with usage instructions

.model small
.stack 100h
CONST_READ_BUFFER_SIZE = 20
CONST_WRITE_BUFFER_SIZE = 20

;; Auto generate inverted condition jmp on far jumps
JUMPS


.data
    error_file_destination  db "File couldn't be opened for writing", 13, 10, '$'
    error_file_source       db "File couldn't be opened for reading", 13, 10, '$'
    error_empty_file        db "The file: $"
    error_emtpy_file2       db ", was empty", 13, 10, "$"
    msg_help                db "NAME",13,10,9, "U2 - Second assigment 1st variant", 13,10,13,10, '$'
    msg_help2               db "SYNOPSIS",13,10,9, "U2 [/?] FILENAME [FILENAME2]...",13,10,13,10, '$'
    msg_help3               db "DESCRIPTION",13,10,9, "This program counts the number of symbols, uppercase letters",13,10, '$'
    msg_help4               db 9, "lowercase letters as well as words of multiple files",13,10,13,10, '$'
    msg_help5               db "EXIT STATUS", '$'
    msg_symbol_count        db "Symbols in file: $"
    msg_uppercase_count     db "Uppercase letters in file: $"
    msg_lowercase_count     db "Lowercase letters in file: $"
    msg_words_count         db "Words in file: $"
    msg_newline             db 13, 10, "$"

    filename_length         dw 0
    buffer_count            dw 0
    dest_file               db "result.txt", 0 
    dest_file_handle        dw ?
    source_file             db 12 dup (0)
    source_file_handle      dw ?
    read_buffer             db CONST_READ_BUFFER_SIZE dup (?)
    write_buffer            db CONST_READ_BUFFER_SIZE dup (?)
    symbol_count            dw 0
    lowercase_count         dw 0
    uppercase_count         dw 0
    word_count              dw 0
    divisor                 dw 10
 
.code
    
start:
    mov ax, @data
    mov es, ax
    ;; Using es in order to use stosb function

    ;; Command arguments are saved in es segment starting with 81h byte
    mov si, 81h

    call    skip_spaces

    ;; Checking for any input or /? and providing the help message if needed
    mov al, byte ptr ds:[si]
    cmp al, 13
    je help

    mov ax, word ptr ds:[si]
    cmp ax, 3F2Fh
    je help

    ;; Saving the source file name
    lea di, source_file
    call    read_filename

    push ds si

    ;; ds is free for now so let's open data in it 
    mov ax, @data
    mov ds, ax

open_file_write:
    ;; Opening the destination file for writing, option 1 = write, no attributes
    mov dx, offset dest_file
    mov cx, 0
    mov ah, 3Ch
    mov al, 1
    int 21h

    ;; If file failed to open
    jc error_destination
    mov dest_file_handle, ax
    
    jmp file_check

read_source_file:
    pop si ds

    lea di, source_file
    call    read_filename

    push ds si

    mov ax, @data
    mov ds, ax
    ;; Did we read all the files
    cmp byte ptr ds:[source_file], '$'
    jne file_check

    jmp close_file

file_check:
    ;; Can we really open the file?
    cmp byte ptr ds:[source_file], '$'
    jne open_file_read

    mov source_file_handle, 0
    jmp read_data


open_file_read:
    ;; Open the file
    mov dx, offset source_file
    mov ah, 3Dh
    mov al, 0
    int 21h

    jc error_source
    mov source_file_handle, ax

read_data:
    mov bx, source_file_handle
    mov dx, offset read_buffer
    mov cx, CONST_READ_BUFFER_SIZE
    mov ah, 3Fh
    int 21h

    mov cx, ax
    cmp ax, 0
    jne set_options

    mov bx, source_file_handle
    mov ah, 3Eh
    int 21h
    call    empty_file
    jmp read_source_file


set_options:
    mov si, offset read_buffer
    mov bx, dest_file_handle


    cmp source_file_handle, 0
    jne save_count
    cmp byte ptr ds:[si], 13
    je close_file

save_count:
    call    check_buffer_count
    mov dx, symbol_count
    add dx, ax
    mov symbol_count, dx
    push ax
    mov cx, ax

buffer_loop:
    lodsb

    mov bl, al
    call check_symbol 

    loop buffer_loop
    jmp check_buffer

check_buffer:
    pop ax
    cmp ax, CONST_READ_BUFFER_SIZE
    je read_data
    jmp write_result

write_result:
    mov ah, 40h
    mov bx, dest_file_handle
    mov cx, filename_length
    lea dx, source_file
    int 21h

    call    print_newline

    mov ah, 40h
    mov bx, dest_file_handle
    mov cx, 17
    lea dx, msg_symbol_count
    int 21h   

    mov ax, symbol_count
    call    convert_print
    call    print_newline

    mov ah, 40h
    mov bx, dest_file_handle
    mov cx, 27
    lea dx, msg_lowercase_count
    int 21h

    mov ax, lowercase_count
    call    convert_print
    call    print_newline

    mov ah, 40h
    mov bx, dest_file_handle
    mov cx, 27
    lea dx, msg_uppercase_count
    int 21h

    mov ax, uppercase_count
    call    convert_print
    call    print_newline

    mov ah, 40h
    mov bx, dest_file_handle
    mov cx, 15
    lea dx, msg_words_count
    int 21h

    mov ax, word_count
    call    convert_print
    call    print_newline
    call    print_newline

    call reset_variables

    jmp read_source_file

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


error_destination:
    mov ax, @data
    mov ds, ax

    mov dx, offset error_file_destination
    mov ah, 09h
    int 21h

    mov dx, offset dest_file
    int 21h

    mov ax, 4C02h
    int 21h

error_source:
    mov ax, @data
    mov ds, ax

    mov dx, offset error_file_source
    mov ah, 09h
    int 21h

    mov dx, offset source_file
    int 21h

    mov ax, 4C01h
    int 21h

close_file:
    pop ds si
    mov ah, 3Eh
    mov bx, dest_file_handle
    int 21h

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

read_filename PROC near
    push	ax

	call	skip_spaces
read_filename_start:
 	cmp	byte ptr ds:[si], 13
    je	read_filename_end
    cmp	byte ptr ds:[si], ' '
    jne	read_filename_next

read_filename_end:
   	mov	al, '$'
   	stosb
   	pop	ax
   	ret

read_filename_next:
    push ax ds
    mov ax, @data
    mov ds, ax
    inc filename_length
    pop ds ax

   	lodsb   
   	stosb
   	jmp read_filename_start

read_filename ENDP

check_symbol PROC near
    push ax
    
    is_lowercase:
        cmp bl, 61h
        jl is_uppercase

        cmp bl, 7Ah
        jg check_symbol_end
        inc lowercase_count
        jmp check_symbol_end

    is_uppercase:
        cmp bl, 41h
        jl is_space

        cmp bl, 5Ah
        jg check_symbol_end

        inc uppercase_count
        jmp check_symbol_end

    is_space:
        cmp al, 20h
        jne check_symbol_end

        inc word_count
        jmp check_symbol_end

    check_symbol_end:
        pop ax
        ret

check_symbol ENDP


convert_print PROC near
    
   xor cx,cx  
   convert: 
        sub dx, dx
        div divisor
        add dl, 30h
        push dx
        inc cx
        cmp ax, 0
        ja convert
             
   print:
     
        pop dx
        mov write_buffer, dl
        mov ah, 40h
        mov bx, dest_file_handle
        push cx
        mov cx, 1
        lea dx, write_buffer
        int 21h
        pop cx 
        loop print

        ret
                  
convert_print ENDP

print_newline PROC near
    mov ah, 40h
    mov bx, dest_file_handle
    mov cx, 2
    lea dx, msg_newline
    int 21h
    ret

print_newline ENDP


reset_variables PROC near
    mov symbol_count, 0
    mov lowercase_count, 0
    mov uppercase_count, 0
    mov word_count, 0
    mov buffer_count, 0
    mov filename_length, 0
    ret

reset_variables ENDP

check_buffer_count PROC near
    cmp buffer_count, 0
    jne check_buffer_count_end
    inc word_count

    check_buffer_count_end:
        inc buffer_count
        ret

check_buffer_count ENDP

empty_file PROC near
    mov ah, 40h
    mov bx, dest_file_handle
    lea dx, error_empty_file
    mov cx, 10
    int 21h

    mov ah, 40h
    mov bx, dest_file_handle
    lea dx, source_file
    mov cx, filename_length
    int 21h

    mov ah, 40h
    mov bx, dest_file_handle
    lea dx, error_emtpy_file2
    mov cx, 13
    int 21h

    mov filename_length, 0
    call    print_newline
    ret

empty_file ENDP

end start
