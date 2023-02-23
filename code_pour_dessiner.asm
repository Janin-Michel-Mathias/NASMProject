; external functions from X11 library
extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XDrawPoint
extern XFillArc
extern XNextEvent

; external functions from stdio library (ld-linux-x86-64.so.2)    
extern printf
extern exit

%define	StructureNotifyMask	131072
%define KeyPressMask		1
%define ButtonPressMask		4
%define MapNotify		19
%define KeyPress		2
%define ButtonPress		4
%define Expose			12
%define ConfigureNotify		22
%define CreateNotify 16
%define QWORD	8
%define DWORD	4
%define WORD	2
%define BYTE	1

global main

section .bss
display_name:	resq	1
screen:			resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		    resq	1
gc:		        resq    1
coordsX:        resd    3
coordsY:        resd    3    
i:              resd    1
j:              resd    1
minX:           resd    1
maxX:           resd    1
minY:           resd    1
maxY:           resd    1
sensTriangleVar:    resb    1

section .data

event:		times	24 dq 0

x1:	dd	0
x2:	dd	0
y1:	dd	0
y2:	dd	0
print: dd "%d: %d", 10, 0

section .text
	
;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################

main:

;define coords

mov dword[i], 0
new_point:

mov ecx, dword[i]
call randomCoords
mov dword[coordsX + DWORD * ecx], r8d

call randomCoords
mov dword[coordsY + DWORD * ecx], r8d

inc dword[i]

cmp dword[i], 3
jb new_point

xor     rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

; display_name structure
; screen = DefaultScreen(display_name);
mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov     rdi,qword[display_name]
mov     esi,dword[screen]
call    XRootWindow
mov     rbx,rax

mov     rdi,qword[display_name]
mov     rsi,rbx
mov     rdx,10
mov     rcx,10
mov     r8,400	; largeur
mov     r9,400	; hauteur
push    0xFFFFFF	; background  0xRRGGBB
push    0x00FF00
push    1
call    XCreateSimpleWindow
mov     qword[window],rax

mov     rdi,qword[display_name]
mov     rsi,qword[window]
mov     rdx,131077 ;131072
call    XSelectInput

mov     rdi,qword[display_name]
mov     rsi,qword[window]
call    XMapWindow

mov     rsi,qword[window]
mov     rdx,0
mov     rcx,0
call    XCreateGC
mov     qword[gc],rax

mov     rdi,qword[display_name]
mov     rsi,qword[gc]
mov     rdx,0x000000	; Couleur du crayon
call    XSetForeground

boucle: ; boucle de gestion des évènements
mov     rdi,qword[display_name]
mov     rsi,event
call    XNextEvent

cmp     dword[event],ConfigureNotify	; à l'apparition de la fenêtre
je      dessin							; on saute au label 'dessin'

cmp     dword[event],KeyPress			; Si on appuie sur une touche
je      closeDisplay						; on saute au label 'closeDisplay' qui ferme la fenêtre
jmp     boucle

;#########################################
;#		DEBUT DE LA ZONE DE DESSIN		 #
;#########################################
dessin:

mov     rdi, qword[display_name]
mov     rsi, qword[gc]
mov     edx, 0x000000
call    XSetForeground

mov r12, coordsX
mov r13, coordsY
call drawTriangle

mov r12, coordsX

call triangleMinCoordOnAxis
mov dword[minX], r9d
call triangleMaxCoordOnAxis
mov dword[maxX], r9d

mov r12, coordsY
call triangleMinCoordOnAxis
mov dword[minY], r9d
call triangleMaxCoordOnAxis
mov dword[maxY], r9d

mov rdi, print
movsx rsi, dword[minX]
movsx rdx, dword[maxX]
mov rax, 0
call printf

mov rdi, print
movsx rsi, dword[minY]
movsx rdx, dword[maxY]
mov rax, 0
call printf

mov     rdi, qword[display_name]
mov     rsi, qword[gc]
mov     edx, 0xFF0000
call    XSetForeground


mov r12, coordsX
mov r13, coordsY
; call sensTriangle

; mov byte[sensTriangleVar], r14b

; mov ecx, dword[minX]
; mov dword[i], ecx

; colorLoop1:

; mov ecx, dword[minY]
; mov dword[j], ecx

; colorLoop2:

; ; mov rdi, print
; ; movsx rsi, dword[i]
; ; movsx rdx, dword[j]
; ; call printf


; inc dword[j]
; mov ecx, dword[j]
; cmp ecx, dword[maxY]
; jb colorLoop2

; inc dword[i]
; mov ecx, dword[i]
; cmp ecx, dword[maxX]
; jb colorLoop1


; ############################
; # FIN DE LA ZONE DE DESSIN #
; ############################







































jmp flush

flush:
mov     rdi,qword[display_name]
call    XFlush
jmp     boucle
mov     rax,34
syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit
	


global randomCoords
randomCoords:

RDRAND      r8d

cmp r8d, 0
jl randomCoords

mov eax, r8d
mov ebx, 400
cdq
idiv ebx

mov r8d, edx

ret

global drawTriangle
drawTriangle:

;r12 = coordonnées de début du triangle dans le tableau coordsX
;r13 = idem pour coordsY

push    rbp
mov     rbp, rsp
push    rbx

mov     rdi, qword[display_name]
mov     rsi, qword[window]
mov     rdx, qword[gc]
mov     ecx, dword[r12]
mov     r8d, dword[r13]
mov     r9d, dword[r12 + DWORD]
push    qword[r13 + DWORD]
call    XDrawLine

mov     rdi, qword[display_name]
mov     rsi, qword[window]
mov     rdx, qword[gc]
mov     ecx, dword[r12 + DWORD]
mov     r8d, dword[r13 + DWORD]
mov     r9d, dword[r12 + DWORD * 2]
push    qword[r13 + DWORD * 2]
call    XDrawLine

mov     rdi, qword[display_name]
mov     rsi, qword[window]
mov     rdx, qword[gc]
mov     ecx, dword[r12]
mov     r8d, dword[r13]
mov     r9d, dword[r12 + DWORD * 2]
push    qword[r13 + DWORD * 2]
call    XDrawLine

pop rbx

mov rsp, rbp
pop rbp

ret


global triangleMaxCoordOnAxis
triangleMaxCoordOnAxis:

mov eax, dword[r12 + DWORD]

cmp dword[r12], eax
jb firstGreater

mov r9d, dword[r12]
jmp secondStepMin

firstGreater:

mov r9d, eax

secondStepMin:

cmp r9d, dword[r12 + DWORD * 2]
ja endMin

mov r9d, dword[r12 + DWORD * 2]

endMin:
ret




global triangleMinCoordOnAxis
triangleMinCoordOnAxis:

mov eax, dword[r12 + DWORD]

cmp dword[r12], eax
ja firstLower

mov r9d, dword[r12]
jmp secondStepMax

firstLower:

mov r9d, eax

secondStepMax:

cmp r9d, dword[r12 + DWORD * 2]
jb endMax

mov r9d, dword[r12 + DWORD * 2]

endMax:
ret


global sensTriangle
sensTriangle:

; r12 coords X
; r13 coords Y
; r14b =  0:direct  1: indirect

mov r10, r12
mov r11, r13

mov r9d, dword[r10 + DWORD]

sub dword[r10], r9d ; -11
sub dword[r10 + DWORD * 2], r9d ; -15
mov r9d, dword[r11 + DWORD]
sub dword[r11], r9d ; -49
sub dword[r11 + DWORD * 2], r9d ; -9

mov eax, dword[r10]
imul dword[r11 + DWORD * 2]

mov dword[r10], eax

mov eax, dword[r10 + DWORD * 2]
imul dword[r11]

sub dword[r10], eax

cmp dword[r10], 0
jl direct

mov r14b, 1
jmp endSens

direct:
mov r14b, 0

endSens:
ret

global cotePoint
cotePoint:
; rdi xA
; rsi xB
; rdx yA
; rcx yB
; r8  xP
; r9  yp

sub rsi, rdi
sub r8, rdi
sub rcx, rdx
sub r9, rdx

mov rax, rsi
imul r9

mov rsi, rax

mov rax, r8
imul rcx

sub rsi, rax

cmp rsi, 0
jl pointAGauche
mov rax, 1
jmp endCote
pointAGauche:
mov rax, 0

endCote:

ret



global pointDansTriangle
pointDansTriangle:

mov rbx, 1
mov r15, 0

movsx rdi, dword[r10]
movsx rsi, dword[r10 + DWORD]
movsx rdx, dword[r11]
movsx rcx, dword[r11 + DWORD]
mov r8, r12
mov r9, r13
call cotePoint

add r15, rax

next1:

movsx rdi, dword[r10 + DWORD]
movsx rsi, dword[r10 + DWORD * 2]
movsx rdx, dword[r11 + DWORD]
movsx rcx, dword[r11 + DWORD * 2]
mov r8, r12
mov r9, r13
call cotePoint

add r15, rax

movsx rdi, dword[r10 + DWORD]
movsx rsi, dword[r10 + DWORD * 2]
movsx rdx, dword[r11 + DWORD]
movsx rcx, dword[r11 + DWORD * 2]
mov r8, r12
mov r9, r13
call cotePoint

add r15, rax

ret



