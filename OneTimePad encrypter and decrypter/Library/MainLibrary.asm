.386
.MODEL FLAT, STDCALL

GENERIC_WRITE		equ 40000000h
CREATE_ALWAYS		equ 2
GENERIC_READ        equ 80000000h
OPEN_EXISTING		equ 3
STD_INPUT EQU		-10
STD_OUTPUT EQU		-11

ReadConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetCurrentDirectoryA PROTO :DWORD,:DWORD
WriteFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateFileA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CloseHandle PROTO :DWORD 
lstrcatA PROTO :DWORD,:DWORD
CharToOemA PROTO :DWORD,:DWORD
GetStdHandle PROTO :DWORD

.DATA
	bin DWORD 0
	bufor BYTE 150 DUP(0)
	ALIGN 4
	warning1 BYTE "B£¥D! - Nie mo¿na odczytaæ plików!",13,10,0
	warning2 BYTE "B£¥D! - Nie mo¿na zapisaæ plików!",13,10,0
	fhandle DWORD 0
.CODE

wczytaj PROC USES EBX handle:DWORD, adres:DWORD, dlugosc:DWORD ;///////// W EAX zawracana jest faktyczna ilosc odczytanych znakow
	INVOKE ReadConsoleA, handle, adres, dlugosc, OFFSET bin, 0
	MOV EBX,adres
	ADD EBX,bin
	MOV [EBX-2],BYTE PTR 0
	SUB bin,2
	MOV EAX,bin
	RET
wczytaj ENDP

zapis PROC USES EAX sciezka:DWORD, adres:DWORD, dlugosc:DWORD
	INVOKE GetCurrentDirectoryA, LENGTHOF bufor, OFFSET bufor
	INVOKE lstrcatA, OFFSET bufor, sciezka
	INVOKE CreateFileA, OFFSET bufor, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, 0, 0
	MOV fhandle,EAX
	INVOKE WriteFile, fhandle, adres, dlugosc, OFFSET bin, 0
	CMP EAX,0
	JNZ QUIT
	INVOKE CharToOemA, OFFSET warning2, OFFSET warning2
	INVOKE GetStdHandle, STD_OUTPUT
	INVOKE WriteConsoleA, EAX, OFFSET warning2, LENGTHOF warning2, OFFSET bin, 0
	MOV EBX,-11
	QUIT:
	INVOKE CloseHandle, fhandle
	RET
zapis ENDP

odczyt PROC USES EAX sciezka:DWORD, adres:DWORD, dlugosc:DWORD, wczytane:DWORD
	INVOKE GetCurrentDirectoryA, LENGTHOF bufor, OFFSET bufor
	INVOKE lstrcatA, OFFSET bufor, sciezka
	INVOKE CreateFileA, OFFSET bufor, GENERIC_READ, 0, 0, OPEN_EXISTING, 0, 0
	MOV fhandle,EAX
	INVOKE ReadFile, fhandle, adres, dlugosc, wczytane, 0
	CMP EAX,0
	JNZ QUIT2
	INVOKE CharToOemA, OFFSET warning1, OFFSET warning1
	INVOKE GetStdHandle, STD_OUTPUT
	INVOKE WriteConsoleA, EAX, OFFSET warning1, LENGTHOF warning1, OFFSET bin, 0
	MOV EBX,-11
	QUIT2:
	INVOKE CloseHandle, fhandle
	RET
odczyt ENDP

END