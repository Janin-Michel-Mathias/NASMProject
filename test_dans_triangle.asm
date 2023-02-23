extern printf

%define NB_TRIANGLES
%define DWORD 4

global main


section .data

dedans: db "Dedans !", 10, 0
dehors: db "Dehors", 10, 0

section .bss

coordsX: resd        3 
coordsY: resd        3 
pointX:  resd        1
pointY:  resd        1
sens:    resb        1

section .text
main:

mov dword[coordsX], 14
mov dword[coordsY], 20
mov dword[coordsX + DWORD], 25
mov dword[coordsX + DWORD], 69
mov dword[coordsX + DWORD * 2], 10
mov dword[coordsX + DWORD * 2], 60
mov dword[pointX], 16
mov dword[pointX], 40

mov r10, coordsX
mov r11, coordsY
call sensTriangle

mov byte[sens], ah

mov r10, coordsX
mov r11, coordsY
mov r12, pointX
mov r13, pointY
call pointDansTriangle 

cmp byte[sensTriangle], 0
je direct_main

cmp r15, 3
jne end_bad

mov rdi, dedans
mov rax, 0
call printf

jmp end_loop

direct_main:

cmp r15, 0
jne end_bad

mov rdi, dedans
mov rax, 0
call printf

jmp end_loop

end_bad:

mov rdi, dehors
mov rax, 0
call printf


end_loop:

mov rax, 60
mov rdi, 0
syscall
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


global sensTriangle
sensTriangle:

push    rbp
mov     rbp, rsp
push rbx


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

mov ah, 1
jmp endSens

direct:
mov ah, 0

endSens:


pop rbx
mov rsp, rbp
pop rbp

ret