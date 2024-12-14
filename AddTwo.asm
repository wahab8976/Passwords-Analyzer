include irvine32.inc
include macros.inc

max_Input_Size = 500

.data

;Variables to store track of Password strength
	numCount dd 0
	smallCount dd 0
	captCount dd 0
	charCount dd 0
    userChoice dd 0
    passLength dd 0
    fileHandler HANDLE ?



    generatedSmallAlphabetCount dd ?
    generatedCaptAlphabetCount dd ?
    generatedNumCount dd ?
    generatedCharCount dd ?

	inputPasswordStr byte max_Input_Size dup(?)
    generatedPass byte max_Input_Size dup(?)

    logFileName byte "password_strength.txt",0

    strength byte max_Input_Size dup(?)   
    
    loadedPasswords byte max_Input_Size dup(?)
    
.code

main PROC

    ; Display welcome message
    mwrite "Welcome to Password Strength Checker"
    call crlf

    .repeat
        ; Display menu
        call crlf
        mwrite "1. Check Password Strength"
        call crlf
        mwrite "2. Read Password's History from File"
        call crlf
        mwrite "3. Exit"
        call crlf
        mwrite "Enter your choice: "
        call readint
        mov userChoice, eax
        
        ; Handle user choice
        .if userChoice == 1
            ; Password strength checker
            mwrite "Enter your password to track the strength: "
            call crlf
            
            ; Read user input password
            mov edx, offset inputPasswordStr ; Address of password string
            mov ecx, max_Input_Size         ; Maximum size of password
            call readstring                 ; Read password input

            ; Count character types in the password
            push offset inputPasswordStr    ; Pass password as parameter
            call count                      ; Updates smallCount, numCount, etc.

            ; Evaluate password strength
            push smallCount
            push numCount
            push captCount
            push charCount
            call evaluate                   ; Evaluates strength based on counts

            ; Suggest a strong password
            call crlf
            mwrite "Here is a strong suggested password for you to use: "
            call crlf

            mov edx, offset generatedPass   ; Address for suggested password
            mov ecx, max_Input_Size         ; Max size for the suggestion
            call suggest                    ; Generates a strong password

            ; Display the suggested password
            push offset generatedPass       ; Push suggested password
            push offset inputPasswordStr    ; Push original input
            call writestring                ; Write both to console or file
            
            ; Log the password details to the file
            call writer                     ; Writes to log file

        .elseif userChoice == 2
            ; Read password history from the file
            call reader                     ; Reads and displays password history

        .endif
    .until userChoice == 3                  ; Exit loop when choice is 3

    ; Exit program
    exit
main ENDP



count proc
    
    ;Procedure to count the number of (uppercase, lowercase, digits, and special characters) in a string
    ;Takes the offset of (Password) as an argument
    ;Returns Nothing

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
        inc passLength

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

    mwrite "Password Length: "
    mov eax, passLength
    call writedec
    call crlf
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

    .if passLength < 8
		mwrite "Password Strength: Weak"
        ret
    .endif

    
    .if captCount >=2 && smallCount >=2 && numCount >= 2 && charCount >=1
        mwrite "Password Strength: Strong"
    .elseif captCount >= 1 && smallCount >= 1 && numCount >= 1 && charCount >= 1
        mwrite "Password Strength: Medium"
    .else
        mwrite "Password Strength: Weak"
    .endif


    pop ebp
    ret

evaluate endp


suggest proc

    ;Procedure to suggest a strong password to the user
    ;Takes nothing as an argument
    ;Returns the suggested password

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


writer proc

    ;Procedure to write the password strength in a file and maintain Log file
    ;Takes offsets of (Password,Strength and Suggested Password) as an argument and writes it to a file
    ;Returns Nothing

    push ebp                
    mov ebp, esp            

    mov edx, [ebp + 8]      ; edx = address of password (passed argument)

    mov edx, offset logFileName 
    call createoutputfile
    mov filehandler, eax

    ; Write the password to the file
    mov edx, [ebp + 8]      
    mov ecx, max_Input_Size 
    mov eax, filehandler    
    call writeToFile        

    mov edx, offset strength      
    mov ecx, max_Input_Size 
    mov eax, filehandler    
    call writeToFile

    mov edx, offset generatedPass      
    mov ecx, max_Input_Size 
    mov eax, filehandler    
    call writeToFile

    call closeFile

    pop ebp                 
    ret            
writer endp


reader PROC

    ; Purpose:
    ; Reads passwords from a log file and displays them.
    ; Arguments: None
    ; Returns: None

    ; Open the log file
    mov edx, offset logFileName   ; File name to be opened
    call openinputfile           ; Open file for reading
    mov filehandler, eax         ; Store the file handle in filehandler

    ; Read from the file
    mov edx, offset loadedPasswords ; Buffer to store the file's content
    mov ecx, max_Input_Size         ; Maximum number of bytes to read
    mov eax, filehandler            ; File handle to read from
    call readfromfile               ; Reads data into loadedPasswords

    ; Write the loaded passwords to the console
    mov edx, offset loadedPasswords ; Address of loaded data
    call writestring                ; Display loaded passwords

    ; Close the file
    mov eax, filehandler            ; File handle to close
    call closefile                  ; Closes the log file

    ; Return to the caller
    ret

reader ENDP


end main

