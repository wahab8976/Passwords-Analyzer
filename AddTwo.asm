include irvine32.inc
include macros.inc

max_Input_Size = 500

.data

;Variables to store track of Password strength
	numCount dd 0
	smallCount dd 0
	captCount dd 0
	charCount dd 0

    

    generatedSmallAlphabetCount dd ?
    generatedCaptAlphabetCount dd ?
    generatedNumCount dd ?
    generatedCharCount dd ?

	inputPasswordStr byte max_Input_Size dup(?)
    userChoice byte max_Input_Size dup(?)
    generatedPass byte max_Input_Size dup(?)
.code


main proc
	mwrite"Enter your password to track the strength: "

	;Reads String from the user
	mov edx,offset inputPasswordStr
	mov ecx,max_Input_Size
	call readstring 

	;Calling count function to get values of Combinations
	push offset inputPasswordStr
	call count


    push smallCount
    push numCount 
	push captCount
	push charCount

    call evaluate

    call crlf
    mwrite"Here  Strong Suggested Password for you to Use"
    mov edx, offset generatedPass
    mov ecx, max_Input_Size
    call suggest
    call writestring


exit
main endp


count proc
    push ebp
    mov ebp, esp

    mov edx, [ebp+8]    ; Load the address of the string into EDX
    mov esi, 0          ; Initialize index to 0

    ; Initialize counters
    mov numCount, 0      
    mov captCount, 0     
    mov smallCount, 0    
    mov charCount, 0     

    ; Loop through the string until null terminator (\0)
    ; Reads the whole string and counts the type of characters in the string
    
    .while byte ptr [edx + esi] != 0

        mov al, byte ptr [edx + esi] ; Load the current character into AL

            ; Check if it's an uppercase letter (A-Z)
            .if al >= 'A' && al <= 'Z'
            inc captCount           
            .endif

            ; Check if it's a lowercase letter (a-z)
            .if al >= 'a' && al <= 'z'
            inc smallCount         
            .endif

            ; Check if it's a digit (0-9)
            .if al >= '0' && al <= '9'
            inc numCount            
            .endif

            ; Otherwise, it's a special character
            .if
            inc charCount           
            .endif

        inc esi    ;This register contains the track of while loop to itterate through the loop
    
    .endw

    pop ebp
    ret
count endp


evaluate proc
    push ebp
    mov ebp, esp


    ; Access the arguments
    mov eax, [ebp+8]
    mov charCount, eax

    mov eax, [ebp+12]
    mov numCount, eax

    mov eax, [ebp+16]
    mov smallCount, eax

    mov eax, [ebp+20]
    mov captCount, eax


    ;Password Criterias
    ;Strong: More than 2 upper and lowercase, more than 3 Numbers and Characters
    ;Medium: Atleast 1, uppercase and lowercase, more than 2 Numbers and Characters
    ;Weak: Otherwise, password is weak

    call crlf

    .if captCount > 2 && smallCount > 2 && numCount > 3 && charCount > 3
        mwrite "Password Strength: Strong"
    .elseif captCount >= 1 && smallCount >= 1 && numCount >= 2 && charCount >= 2
        mwrite "Password Strength: Medium"
    .else
        mwrite "Password Strength: Weak"
    .endif


    pop ebp
    ret

evaluate endp


suggest proc
    ; Initialize random number generator
    call Randomize

    ; Define password length
    mov ecx, 16               ; Total password length
    lea edi, [edx]            ; Pointer passed from the caller, where the password will be stored

    ; Ensure inclusion of one character from each category
    ; Uppercase (A–Z)
    call RandomRange
    mov eax, 26
    call RandomRange
    add al, 65                ; Shift to uppercase ASCII
    mov [edi], al
    inc edi

    ; Lowercase (a–z)
    call RandomRange
    mov eax, 26
    call RandomRange
    add al, 97                ; Shift to lowercase ASCII
    mov [edi], al
    inc edi

    ; Digit (0–9)
    call RandomRange
    mov eax, 10
    call RandomRange
    add al, 48                ; Shift to digit ASCII
    mov [edi], al
    inc edi

    ; Special character (!–/)
    call RandomRange
    mov eax, 15
    call RandomRange
    add al, 33                ; Shift to special character ASCII
    mov [edi], al
    inc edi

    ; Fill remaining password length with random printable characters
    sub ecx, 4                ; Remaining characters after mandatory inclusions
fill_remaining:
    call RandomRange
    mov eax, 94               ; Range of printable ASCII characters
    call RandomRange
    add al, 33                ; Shift to printable ASCII range (33-126)
    mov [edi], al
    inc edi
    loop fill_remaining

    ; Null-terminate the password
    mov byte ptr [edi], 0

    ret ; Return to the calling location (password has been written to the memory address passed in edx)
suggest endp





end main

