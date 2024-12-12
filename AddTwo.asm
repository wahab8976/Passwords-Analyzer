include irvine32.inc
include macros.inc

max_Input_Size = 500

.data

;Variables to store track of Password strength
	numCount dd 0
	smallCount dd 0
	captCount dd 0
	charCount dd 0



	inputPasswordStr byte max_Input_Size dup(?)
    userChoice byte max_Input_Size dup(?)

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
    mwrite"Here is a strong Password suggested by us"

    





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

            ; Check if it's a lowercase letter (a-z)
            .elseif al >= 'a' && al <= 'z'
            inc smallCount         

            ; Check if it's a digit (0-9)
            .elseif al >= '0' && al <= '9'
            inc numCount            

            ; Otherwise, it's a special character
            .else
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

end main

