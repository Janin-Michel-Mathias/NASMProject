extern printf

%define NB_TRIANGLES
%define DWORD 4

global main


section .data

printValue: db "%d", 10, 0
printCoords: db "Point %d : X: %lld Y: %lld",10 ,0
printRectangle: db "Rectangle : X1: %lld X2: %lld Y1: %lld Y2: %lld", 10, 0
printSensDirect: db "Sens: Direct", 10, 0
printSensIndirect: db "Sens: Indirect", 10, 0
printPointInterne: db "Point : X: %lld Y: %lld",10 ,0


section .bss

coordsX: resd        3 
coordsY: resd        3 
i:       resd        1 
j:       resd        1
minX:    resd        1
maxX:    resd        1
minY:    resd        1
maxY:    resd        1
sens:    resb        1



section .text

main:

mov byte[i], 0

def_coord_loop:

movsx ecx, byte[i]

call randomCoords
mov dword[coordsX + DWORD * ecx], r8d

call randomCoords
mov dword[coordsY + DWORD * ecx], r8d

inc byte[i]
cmp byte[i], 3 
jl def_coord_loop

mov byte[i], 0

print_coords_loop:

movsx ecx, byte[i]

mov rdi, printCoords
movsx rsi, dword[i]
movsx rdx, dword[coordsX + DWORD * ecx]
movsx rcx, dword[coordsY + DWORD * ecx]
mov rax, 0
call printf

inc byte[i]
cmp byte[i], 3
jl print_coords_loop

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

mov rdi, printRectangle
movsx rsi, dword[minX]
movsx rdx, dword[maxX]
movsx rcx, dword[minY]
movsx r8, dword[maxY]
mov rax, 0
call printf

mov r10, coordsX
mov r11, coordsY
call sensTriangle
mov byte[sens], ah

cmp byte[sens], 0
jne Indirect

mov rdi, printSensDirect
jmp finSens
Indirect:
mov rdi, printSensIndirect

finSens:
mov rax, 0
call printf

mov ecx, minX
mov rdi, printValue
movsx rsi, ecx

loop_points_interne_1:

mov ecx, minY
mov dword[j], ecx
movsx rsi, ecx

loop_points_interne_2:

mov rdi, printPointInterne
movsx rsi, dword[i]
movsx rdx, dword[j]
mov rax, 0
call printf

mov r10, coordsX
mov r11, coordsY
movsx r12, dword[i]
movsx r12, dword[j]
call pointDansTriangle

cmp byte[sens], 0
jne Indirect_interne

cmp r15, 3
jne fin_loop_points

mov rdi, printPointInterne
movsx rsi, dword[i]
movsx rdx, dword[j]
mov rax, 0
call printf

jmp fin_loop_points

Indirect_interne:

cmp r15, 0
jne fin_loop_points

mov rdi, printPointInterne
movsx rsi, dword[i]
movsx rdx, dword[j]
mov rax, 0
call printf

fin_loop_points:

inc dword[j]
mov ecx, dword[j]
cmp ecx, dword[maxY]
jl loop_points_interne_2

inc dword[i]
mov ecx, dword[i]
cmp ecx, dword[maxX]
jl loop_points_interne_1


mov rax, 60
mov rdi, 0
syscall
ret








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