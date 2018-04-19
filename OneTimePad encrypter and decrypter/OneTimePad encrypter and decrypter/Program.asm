.386
.MODEL FLAT, STDCALL

STD_INPUT EQU -10
STD_OUTPUT EQU -11

ExitProcess PROTO :DWORD
CharToOemA PROTO :DWORD,:DWORD
GetStdHandle PROTO :DWORD
ReadConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetCurrentDirectoryA PROTO :DWORD,:DWORD
WriteFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CloseHandle PROTO :DWORD 
GetTickCount PROTO
nseed PROTO :DWORD
nrandom PROTO :DWORD
wczytaj PROTO :DWORD,:DWORD,:DWORD
zapis PROTO :DWORD,:DWORD,:DWORD
odczyt PROTO :DWORD,:DWORD,:DWORD,:DWORD

.DATA
	menu1 BYTE "             ###################################################################           ",13,10,0
	menu1b BYTE "            ###################################################################            ",13,10,0
	menu2 BYTE "            ####                                                           ####            ",13,10,0
	menu3 BYTE "            ####             OneTimePad encrypter/decrypter                ####            ",13,10,0
	menu4 BYTE "            ####                           by                              ####            ",13,10,0
	menu5 BYTE "            ####                    Jakub Ostropolski                      ####            ",13,10,0
	pustalinia BYTE " ",13,10,0

	komunikat1 BYTE "Aby zaszyfrowaæ wiadomoœæ, wprowadŸ 1",13,10,0
	komunikat2 BYTE "Aby odszyfrowaæ wiadomoœæ, wprowadŸ 2",13,10,0
	komunikat3 BYTE "Podaj treœæ wiadomoœci (UWAGA!!! - Wysoce sugerowane jest nieu¿ywanie znaku spacji.) : ",13,10,0
	komunikat4 BYTE "Umieœæ plik z wiadomoœci¹ 'message.dat' oraz 'key.dat' w katalogu aplikacji.",13,10,0
	komunikat5 BYTE "Gdy to zrobisz, wciœnij ENTER.",13,10,0
	komunikat6 BYTE "GOTOWE! Odszyfrowan¹ wiadomoœæ znajdziesz w pliku message.txt",13,10,0
	komunikat7 BYTE "GOTOWE! Zaszyfrowan¹ wiadomoœæ oraz klucz znajdziesz w plikach message.dat oraz key.dat",13,10,0
	komunikat8 BYTE "Aby wyjœæ, wciœnij ENTER.",13,10,0
	komunikat9 BYTE "Aby wyjœæ, wprowadŸ 'Q'.",13,10,0
	komunikat10 BYTE "B³êdny wybór! Wybierz jeszcze raz :",13,10,0

	sciezka1 BYTE "\message.pad",0
	sciezka2 BYTE "\key.pad",0
	sciezka3 BYTE "\message.txt",0
	ALIGN 4

	bufor BYTE 128 DUP(0)
	tekst BYTE 512 DUP(0)
	klucz BYTE 512 DUP(0)
	hout DWORD 0
	hinp DWORD 0
	wypisane DWORD 0
	zczytane DWORD 0
	wczytane DWORD 0


.CODE

main PROC
;					///////////////// Przygotowanie aplikacji i menu /////////////////
	INVOKE GetStdHandle, STD_INPUT
	MOV hinp,EAX
	INVOKE GetStdHandle, STD_OUTPUT
	MOV hout,EAX

	INVOKE CharToOemA, OFFSET komunikat1, OFFSET komunikat1
	INVOKE CharToOemA, OFFSET komunikat2, OFFSET komunikat2
	INVOKE CharToOemA, OFFSET komunikat3, OFFSET komunikat3
	INVOKE CharToOemA, OFFSET komunikat4, OFFSET komunikat4
	INVOKE CharToOemA, OFFSET komunikat5, OFFSET komunikat5
	INVOKE CharToOemA, OFFSET komunikat6, OFFSET komunikat6
	INVOKE CharToOemA, OFFSET komunikat7, OFFSET komunikat7
	INVOKE CharToOemA, OFFSET komunikat8, OFFSET komunikat8
	INVOKE CharToOemA, OFFSET komunikat9, OFFSET komunikat9
	INVOKE CharToOemA, OFFSET komunikat10, OFFSET komunikat10

;					///////////////// Wyœwietlenie menu /////////////////
	INVOKE WriteConsoleA, hout, OFFSET menu1, LENGTHOF menu1, wypisane, 0
	INVOKE WriteConsoleA, hout, OFFSET menu2, LENGTHOF menu2, wypisane, 0
	INVOKE WriteConsoleA, hout, OFFSET menu3, LENGTHOF menu3, wypisane, 0
	INVOKE WriteConsoleA, hout, OFFSET menu4, LENGTHOF menu4, wypisane, 0
	INVOKE WriteConsoleA, hout, OFFSET menu5, LENGTHOF menu5, wypisane, 0
	INVOKE WriteConsoleA, hout, OFFSET menu2, LENGTHOF menu2, wypisane, 0
	INVOKE WriteConsoleA, hout, OFFSET menu1b, LENGTHOF menu1b, wypisane, 0

	INVOKE WriteConsoleA, hout, OFFSET pustalinia, LENGTHOF pustalinia, wypisane, 0

	INVOKE WriteConsoleA, hout, OFFSET komunikat1, LENGTHOF komunikat1, wypisane, 0
	INVOKE WriteConsoleA, hout, OFFSET komunikat2, LENGTHOF komunikat2, wypisane, 0
	INVOKE WriteConsoleA, hout, OFFSET komunikat9, LENGTHOF komunikat9, wypisane, 0

;					///////////////// Wybór opcji /////////////////
	AGAIN:
		INVOKE wczytaj, hinp, OFFSET bufor, LENGTHOF bufor
		MOV AL,[bufor]
		CMP AL,31H
		JZ SZYFRUJ
		CMP AL,32H
		JZ ODSZYFRUJ
		CMP AL,51H
		JZ WYJDZ2
		INVOKE WriteConsoleA, hout, OFFSET komunikat10, LENGTHOF komunikat10, wypisane, 0
	JMP AGAIN

	SZYFRUJ:

		INVOKE WriteConsoleA, hout, OFFSET komunikat3, LENGTHOF komunikat3, wypisane, 0
		INVOKE wczytaj, hinp, OFFSET tekst, LENGTHOF tekst
		
		
		MOV zczytane,EAX
		;INVOKE CharToOemA, OFFSET tekst, OFFSET tekst
		MOV ECX,zczytane
		MOV ESI,OFFSET tekst
		MOV EDI,OFFSET klucz
		INVOKE GetTickCount
		INVOKE nseed, EAX

;					///////////////// Procedura szyfrowania /////////////////
		PETLA:
			PUSH ECX
			MOV EAX,120
			INVOKE nrandom, EAX
			MOV [EDI], AL
			MOV EBX,0
			MOV BL,[ESI]
			SUB BL,11
			MOV [ESI], BL
			XOR [ESI], AL
			INC ESI
			INC EDI
			POP ECX
		LOOP PETLA

;					///////////////// Zapis do plików /////////////////
		INVOKE zapis, OFFSET sciezka1, OFFSET tekst, zczytane
		CMP EBX,-11
		JZ WYJDZ
		INVOKE zapis, OFFSET sciezka2, OFFSET klucz, zczytane
		CMP EBX,-11
		JZ WYJDZ

		INVOKE WriteConsoleA, hout, OFFSET komunikat7, LENGTHOF komunikat7, wypisane, 0
		JMP WYJDZ

	ODSZYFRUJ:

		INVOKE WriteConsoleA, hout, OFFSET komunikat4, LENGTHOF komunikat4, wypisane, 0
		INVOKE WriteConsoleA, hout, OFFSET komunikat5, LENGTHOF komunikat5, wypisane, 0
		INVOKE wczytaj, hinp, OFFSET bufor, LENGTHOF bufor

;					///////////////// Odczyt z plików /////////////////
		INVOKE odczyt, OFFSET sciezka1, OFFSET tekst, LENGTHOF tekst, OFFSET zczytane
		CMP EBX,-11
		JZ WYJDZ
		INVOKE odczyt, OFFSET sciezka2, OFFSET klucz, LENGTHOF klucz, OFFSET zczytane
		CMP EBX,-11
		JZ WYJDZ

;					///////////////// Procedura odszyfrowania /////////////////
		MOV ECX,zczytane
		MOV ESI,OFFSET tekst
		MOV EDI,OFFSET klucz
		PETLA2:
			MOV AL,[EDI]
			XOR [ESI],AL
			MOV EBX,0
			MOV BL,[ESI]
			ADD BL,11
			MOV [ESI], BL
			INC EDI
			INC ESI
		LOOP PETLA2

		INVOKE zapis, OFFSET sciezka3, OFFSET tekst, zczytane

		INVOKE WriteConsoleA, hout, OFFSET komunikat6, LENGTHOF komunikat6, wypisane, 0

WYJDZ:
	
	INVOKE WriteConsoleA, hout, OFFSET komunikat8, LENGTHOF komunikat8, wypisane, 0
	INVOKE wczytaj, hinp, OFFSET bufor, LENGTHOF bufor

WYJDZ2:
PUSH 0
CALL ExitProcess
main ENDP
END