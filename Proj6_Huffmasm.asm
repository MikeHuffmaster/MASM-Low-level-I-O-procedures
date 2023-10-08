INCLUDE Irvine32.inc

.data
array SDWORD 10 DUP(?)
buffer BYTE 16 DUP(0)
bytesRead DWORD ?
isNegative DWORD 0

intro BYTE "MASM Low Level Procedures by Mike Huffmaster",13,10,13,10,0
instructions BYTE "Please enter 10 signed integers that will fit in a 32 bit register,",13,10
            BYTE "The numbers will then be displayed, followed by their sum, and average.",13,10,13,10,0
prompt BYTE "Please enter a number: ",0
error BYTE "Please enter a valid number.",13,10,0
numbers BYTE 13,10,"Your numbers: ",0
sum BYTE "Sum of your entered numbers: ",0
average BYTE 13,10,"Your Truncated Average: ",0
farewell BYTE 13,10,13,10,"Thank you for using my program! Sorry if it didn't work as expected,",13,10
         BYTE "I ran in to some negation issues.",13,10,0
userInput DWORD 16 DUP(0) ; to store user input
count SDWORD ?

.code
mGetString MACRO prompt, userInput, count, bytesRead
    LOCAL _retry

    _retry:
        push EAX
        push ECX
        push EDX
        
        ; Display the prompt
        mov edx, OFFSET prompt
        call WriteString
        
        ; Get user input and store in userInput
        mov EDX, OFFSET userInput
        mov ECX, SIZEOF userInput
        call ReadString
        mov count, 0
        mov count, EAX
        mov bytesRead, EAX ; Store the number of bytes read
        
        pop EDX
        pop ECX
        pop EAX
    ENDM

mDisplayString MACRO string
    push edx
    mov edx, OFFSET string
    call WriteString
    pop edx
    ENDM

ReadVal PROC
    push EBP
    mov EBP, ESP

    LOCAL index

    mGetString prompt, buffer, 16, bytesRead ; Get user input
    mov ESI, OFFSET buffer
    
    ; Check for a sign character
    mov al, [ESI]
    cmp al, '-'
    jnz _checkDigits
    inc ESI
    mov isNegative, 1
    jmp _checkDigits

    _checkDigits:
        xor ECX, ECX ; Clear ECX to accumulate the number
        xor EAX, EAX ; Clear EAX to accumulate the digits
        
        _digitLoop:
            movzx eax, byte ptr [ESI] ; Load ASCII digit
            sub eax, '0'              ; Convert ASCII to numeric
            test eax, eax
            jz _endLoop               ; Exit loop if not a digit
            imul ECX, ECX, 10         ; Multiply current accumulated number by 10
            add ECX, eax              ; Add new digit to accumulated number
            inc ESI                   ; Move to the next character
            jmp _digitLoop
        
        _endLoop:
            ; Check for negative sign
            cmp isNegative, 1
            jz _storeResult
            neg ECX ; Negate the positive number
        
        _storeResult:
            mov EAX, ECX ; Store the result in EAX
        
    pop EBP
    ret
ReadVal ENDP

WriteVal PROC
    push EBP
    mov EBP, ESP

    LOCAL index

    mov EAX, [EBP + 8] ; Load the input number
    mov ECX, 16        ; Set the maximum buffer size
    
    ; Check for negative value
    cmp EAX, 0
    jge _convertLoop ; Jump to the loop if positive or zero
    neg EAX          ; Negate the value
    mov isNegative, 1
    
    _convertLoop:
        xor EDX, EDX ; Clear EDX for division
        div EAX, 10       ; Divide by 10
        add dl, '0'  ; Convert remainder to ASCII
        dec ECX      ; Decrement the buffer position
        mov [buffer + ECX], dl ; Store the ASCII digit
        
        test EAX, EAX
        jnz _convertLoop ; Repeat the loop until quotient is zero
    
    ; Check for negative sign
    cmp isNegative, 1
    jnz _display
    
    dec ECX
    mov [buffer + ECX], '-' ; Add negative sign to the buffer

    _display:
        mov ESI, OFFSET buffer + ECX ; Load the address of buffer
        
        mDisplayString ESI ; Display the converted number

    pop EBP
    ret 4
WriteVal ENDP

main PROC
    push OFFSET instructions
    push OFFSET intro
    call introduction

    mov ECX, 10 ; Loop 10 times to read and process 10 integers
    mov EDI, OFFSET array
    _loop:
        call ReadVal ; Read and convert user input
        mov [EDI], EAX ; Store the converted value in the array
        add EDI, 4 ; Move to the next array element
        loop _loop

    mDisplayString OFFSET numbers

    mov ECX, 10 ; Reset the loop counter
    mov ESI, OFFSET array
    _displayLoop:
        push [ESI] ; Push the array element to be displayed
        call WriteVal ; Display the integer
        add ESI, 4 ; Move to the next array element
        loop _displayLoop

    ; Calculate and display the sum
    mov ECX, 10
    mov EDX, 0
    mov ESI, OFFSET array
    _sumLoop:
        add EDX, [ESI]
        add ESI, 4
        loop _sumLoop

    push EDX
    call WriteVal ; Display the sum
    pop EDX

    ; Calculate and display the average
    mov ECX, 10
    mov EAX, EDX ; Sum value is in EAX
    xor EDX, EDX ; Clear EDX for division
    div ECX ; Divide sum by 10
    push EAX
    call WriteVal ; Display the average
    pop EAX

    mDisplayString OFFSET farewell

    invoke ExitProcess, 0
main ENDP

introduction PROC
    push EBP
    mov EBP, ESP
    mDisplayString [EBP + 8]
    mDisplayString [EBP + 12]
    pop EBP
    ret 8
introduction ENDP

END main
