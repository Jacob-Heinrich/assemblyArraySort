INCLUDE Irvine32.inc

ARRAYSIZE = 200
LO = 15
HI = 50
COUNTSIZE = HI + 1 - LO



.data

intro			 			BYTE	"Arrays, Addressing, and Stack-Passed Parameters.", 0
intro2					BYTE	"This project will generate a random array between a specific range, sort it, find the median, and display the sorted and unsorted arrays.",0
goodBye					BYTE	"Good Bye, Have a nice day.",0
unsortString		BYTE	"Unsorted Array",0
medianString		BYTE	"Median of Sorted List: ",0
countString			BYTE	"Count Array",0
sortString			BYTE	"Sorted Array",0
randArray				DWORD	ARRAYSIZE DUP(?)
countArray			DWORD	countSize DUP(?)



.code
main PROC

	PUSH	OFFSET intro
	PUSH	OFFSET intro2
	CALL	introduction
	CALL	Randomize
	PUSH	OFFSET randArray
	CALL	fillArray
	PUSH	ARRAYSIZE
	PUSH	OFFSET randArray
	PUSH	OFFSET unsortString
	CALL	displayList
	PUSH	OFFSET randArray
	CALL	sortList
	PUSH  ARRAYSIZE
	PUSH	OFFSET randArray
	PUSH	OFFSET sortString
	CALL	displayList
	PUSH	OFFSET randArray
	PUSH	OFFSET medianString
	CALL	displayMedian
	PUSH	COUNTSIZE
	PUSH	OFFSET randArray
	PUSH	OFFSET countArray
	CALL	countList
	PUSH	OFFSET countArray
	PUSH	OFFSET countString
	CALL	displayList
	PUSH	OFFSET goodBye
	CALL	farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; -----------------
; Name: introduction
;
; Introduces the program
;
; Preconditions: None
;
; Postconditions: None
;
; Receives: Intro string 1 and Intro string 2
;
; Returns: Displays intro strings
; ------------------

introduction PROC

	PUSH	EBP
	MOV		EBP, ESP
	MOV		EDX, [EBP + 12]
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf
	MOV		EDX, [EBP + 8]
	CALL	WriteString
	CALL	CrLf
	POP		EBP
	RET		8

introduction ENDP


; ---------------------
; Name: fillArray
;
; Fills the array with random integers between a HI and LOW range.
;
; Preconditions: ECX must be set to array size, array address stored in EDX, ESI set to array address.
;
; Postconditions: None
;
; Receives: HI range constant, LOW range constant, address offset of the array, ARRAYSIZE.
;
; Returns: Array stored with the random integers generated.
; ---------------------

fillArray PROC

		PUSH	EBP
		MOV		EBP, ESP

		MOV		ECX, ARRAYSIZE
		MOV		EDX, [EBP + 8]

	_fillLoop:
		MOV		EAX, HI
		SUB		EAX, LO - 1
		CALL	RandomRange
		ADD		EAX, LO
		MOV		[EDX], EAX
		ADD		EDX, 4
		LOOP	_fillLoop

		POP EBP
		RET 4

fillArray ENDP


; -------------------
; Name: sortList
;
; Uses bubble sort to sort, in ascending order, the array with random integers.
;
; Preconditions: Array address stored on stack, ECX set to array size, ESI set to array address.
;
; Postconditions: EAX set to the element at array[0].
;
; Receives: ARRAYSIZE, address offset of the array,
;
; Returns: Sorted array from random array.
; -------------------

sortList PROC

		; sets up starting conditions for bubble sort loop
		PUSH	EBP
		MOV		EBP, ESP
		MOV		ESI, [EBP + 8]
		MOV		ECX, ARRAYSIZE - 1
		CLD
		LODSD

	_mainLoop:
		PUSH	ECX
		PUSH	ESI
		MOV		ECX, ARRAYSIZE - 1
		CALL	exchangeElements
		POP		ESI
		POP		ECX
		MOV		EAX, [ESI]
		LOOP	_mainLoop

		; sorts the first element when the rest is already sorted
		MOV		ESI, [EBP + 8]
		MOV		ECX, ARRAYSIZE - 1
		MOV		EAX, [ESI][0]
		CALL	exchangeElements

		POP		EBP
		RET		4

sortList ENDP


; -----------------------
; Name: exchangeElements
;
; Exchanges the elements if the preceding element is greater.
;
; Preconditions: EAX set to the beginning of the array.
;
; Postconditions: None
;
; Receives: Currently sorted array, first element of the array.
;
; Returns: Array currently sorted based on main loop.
; -----------------------

exchangeElements PROC

	_swapLoop:
		; loop to swap the elements if the first is greater
		MOV		EBX, [ESI]
		CMP		EAX, EBX
		JG		_swap
		MOV		EAX, [ESI]
		ADD		ESI, 4
		LOOP	_swapLoop

		RET

	_swap:
		MOV		[ESI - 4], EBX
		MOV		[ESI], EAX
		MOV		EAX, [ESI]
		ADD		ESI, 4
		LOOP	_swapLoop

		RET

exchangeElements ENDP


; --------------------------------------
; Name: displayMedian
;
; Displays the median of the sorted array.
;
; Preconditions: ESI set to address offset of array.
;
; Postconditions: None
;
; Receives: ARRAYSIZE.
;
; Returns: Displays the median value of the array.
; ---------------------------------------

displayMedian PROC

		PUSH	EBP
		MOV		EBP, ESP

		; gets the median of the array by dividing array length in half
		MOV		ESI, [EBP + 12]
		MOV		EDX, 0
		MOV		EAX, ARRAYSIZE - 1
		MOV		EBX, 2
		DIV		EBX
		CMP		EDX, 0
		JNE		_roundUp
		MOV		EBX, 4
		MUL		EBX
		ADD		ESI, EAX
		MOV		EAX, [ESI]
		JMP		_display

	_roundUp:
		; if array is an odd length, will round up
		ADD		EAX, 1
		MOV		EBX, 4
		MUL		EBX
		ADD		ESI, EAX
		MOV		EAX, [ESI]
		JMP		_display

	_display:
		; displays median
		MOV		EDX, [EBP + 8]
		CALL	WriteString
		CALL	WriteDec
		CALL	CrLf

		POP		EBP
		RET		8

displayMedian ENDP


; --------------------------------------
; Name: displayList
;
; Will get called three times to display the unsorted,sorted, and count arrays.
;
; Preconditions: Address offset of the array stored in ESI, the address of the identifier
;				 string associated with the array, ECX set to array size.
;
; Postconditions: None
;
; Receives: Array, size of array.
;
; Returns: Displays the identifier string and the array.
; --------------------------------------

displayList PROC

		PUSH	EBP
		MOV		EBP, ESP

		; displays identifier string and formats the first line with a space
		CALL	CrLf
		MOV		EDX, [EBP + 8]
		CALL	WriteString
		CALL	CrLf
		MOV		ESI, [EBP+12]
		MOV		ECX, [EBP + 16]
		MOV		EDX, 1
		MOV		AL,  32
		CALl	WriteChar

	_print:
		; iterates through the array and display the elements
		MOV		EAX, [ESI]
		CALL	WriteDec
		CMP		EDX, 20
		JNE		_end
		MOV		EDX, 0
		CALL	CrLf

	_end:
		ADD		EDX, 1
		MOV		AL,  32
		CALL	WriteChar
		ADD		ESI, 4
		LOOP	_print
		CALL	CrLf

		POP		EBP
		RET		8

displayList ENDP


; -------------------------------------
; Name: countList
;
; Generates an array filled with the counts of each integer found
; in the sorted array.
;
; Preconditions: ESI set to address of array, EDI set to address of the count array,
;				 ECX set to array size.
;
; Postconditions: None
;
; Receives: ARRAYSIZE, sorted array, count array.
;
; Returns: Array filled with the counts of each integer found in the sorted array.
; --------------------------------------

countList PROC

		PUSH	EBP
		MOV		EBP, ESP

		MOV		ESI, [EBP + 12]
		MOV     EDI, [EBP + 8]
		MOV		ECX, ARRAYSIZE
		CLD

	_countLoop:
		; gets the count and index of each element
		LODSD
		MOV		EDX, 0
		MOV		EBX, 4
		SUB		EAX, LO
		MUL		EBX
		MOV		EDX, [EDI + EAX]
		ADD		EDX, 1
		MOV		[EDI + EAX], EDX
		LOOP	_countLoop

		POP		EBP
		RET		8

countList ENDP


; -------------------------------------
; Name: farewell
;
; Displays the farewell message.
;
; Preconditions: None
;
; Postconditions: None
;
; Receives: goodBye
;
; Returns: Displays the goodBye string.
;--------------------------------------

farewell PROC

	PUSH	EBP
	MOV		EBP,ESP

	CALL	CrLf
	MOV		EDX,[EBP + 8]
	CALL	WriteString

	POP		EBP
	RET		4

farewell ENDP

END main
