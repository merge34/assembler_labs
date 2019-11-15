; -------------------------------------------------------------------------------------	;
;	������������ ������ �n �� ����� ���������������� �� ����� ����������				;
;	������� �2.6																		;
;	�������� ������� ������� ����.														;
;																						;
;	�������� ������ LabAssignment.asm													;
;	�������� ������� �� ����� ����������, ������������� � ������������ � ��������		;
; -------------------------------------------------------------------------------------	;
;	�������: 
;		����������� ������ ������ ��������� ����������� � �������������� ������������
;       ����������
.DATA
	TopBorder		qword	255	; ������� ������� �������� ������� � ���������� ���������
	MultiplierTwo	dword	2	; ��������� "2" ��� ������� ������
.CODE
; -------------------------------------------------------------------------------------	;
; ������������ ���������� ����� �������� ������������ �����������						;
; void Kernel( PBYTE pDst, PBYTE pSrc, int Width )										;
; ���������:																			;
;	pDst   - ����� ������� - ���������� ���������										;
;   pSrc   - ����� ������� ��������� �����������										;
;	Width  - ������ ����������� � �������� (���������� ��������)						;
; ��������!!! ��� ���������� ������ ���������� ���������� ���������� ��������� � �����	;
;	Tuning.h � ������������ � ��������													;
; -------------------------------------------------------------------------------------	;
Kernel PROC	; [RCX] - pDst
			; [RDX] - pSrc
			; R8    - Width

	; ������ ������:
	; �������������� ������� ����� ��� ([RDX] = z0):
	; (z1, z2, z3)
	; (z4, z5, z6)
	; (z7, z8, z9)
	; �����:
	; Gx = 2*(z4 - z0) + z1 + z7 - z3 - z9
	; Gy = 2*(z2 - z8) + z2 + z3 - z7 - z9
	; ����� �������� �������� ����� ��������� ����� ����� [RCX] = sqrt(Gx^2 + Gy^2)


	; ��������� ����������� ������� ����� ��� ������������ ��� ��������������
	mov r9, rsp

	; ��������� ������ �������������� ������� � ����
	movzx rax, byte ptr [rdx]					; ������ z1 � ��������� ������ �� qword,
												; ����� ����� ���� �������� � ����
	push rax									; ��������� ��� � ����
	movzx rax, byte ptr [rdx + 1]				; ������ z2
	push rax									; ��������� ��� � ����
	movzx rax, byte ptr [rdx + 2]				; ������ z3
	push rax									; ��������� ��� � ����
	movzx rax, byte ptr [rdx + r8]				; ������ z4
	push rax									; ��������� ��� � ����
	movzx rax, byte ptr [rdx + r8 + 2]			; ������ z6
	push rax									; ��������� ��� � ����
	movzx rax, byte ptr [rdx + 2*r8]			; ������ z7
	push rax									; ��������� ��� � ����
	movzx rax, byte ptr [rdx + 2*r8 + 1]		; ������ z8
	push rax									; ��������� ��� � ����
	movzx rax, byte ptr [rdx + 2*r8 + 2]		; ������ z9
	push rax
	
	; ��������� Gx

	; ��������� �������� � ������������� +-1
	fldz							; ������������� ����� ����� Gx ����
	fiadd dword ptr [rsp + 8* 7]	; + z1
	fisub dword ptr [rsp + 8* 5]	; - z3
	fiadd dword ptr [rsp + 8* 2]	; + z7
	fisub dword ptr [rsp + 8* 0]	; - z9

	; ��������� �������� � ������������� +-2
	fldz							; ������������� ����� (z4 - z6) ����
	fiadd dword ptr [rsp + 8* 4]	; + z4
	fisub dword ptr [rsp + 8* 3]	; - z6
	fimul MultiplierTwo				; �������� (z4 - z6) �� 2
	faddp							; ��������� ��������� ����� � ����� ����� 
									; � �������� Gx

	; �������� Gx � ��������
	fmul st(0),st(0)
	

	; ��������� Gy

	; ��������� �������� � ������������� +-1
	fldz							; ������������� ����� ����� Gy ����
	fiadd dword ptr [rsp + 8* 7]    ; + z1
	fiadd dword ptr [rsp + 8* 5]    ; + z3
	fisub dword ptr [rsp + 8* 2]	; - z7
	fisub dword ptr [rsp + 8* 0]	; - z9

	; ��������� �������� � ������������� +-2
	fldz							; ������������� ����� (z2 - z8) ����
	fiadd dword ptr [rsp + 8* 6]	; + z2
	fisub dword ptr [rsp + 8* 1]	; - z8 
	fimul MultiplierTwo				; �������� (z2 - z8) �� 2
	faddp							; ��������� ��������� ����� � ����� ����� 
									; � �������� Gy

	; �������� Gy � ��������
	fmul st(0),st(0)

	; Gx^2 + Gy^2
	faddp

	; sqrt(Gx^2 + Gy^2)
	fsqrt

	; ���������� ���������:
	; 1) �������� ������� �������
	fild TopBorder			; ��������� � FPU ������� ������� (255)
	fcomi st(0),st(1)		; ���� ���������� ����� �������� ������� ������ 255,
	fcmovnbe st(0),st(1); �� ������ ��� 255
	; 2) �������� ������ �������
	fldz					; ��������� � FPU ������ ������� (0)
	fcomi st(0),st(1)		; ���� ���������� ����� �������� ������� ������ 0,
	fcmovb st(0),st(1)		; �� ������ ��� ����

	; ���������� ����������� �������� � �������
	fistp qword ptr [rsp]	; ������ ������� ����� FPU �� ������� ����� 
							; ����� ������������ ������� ��������� RSP, 
							; �.� ��� ����� ��� �� ������ ��������
	pop rax					; ��������� ��������� ��������� � ������� ������ ����������
	mov byte ptr [rcx], al	; ���������� ��������� ���������

	; ������� �������� ��������, �������������� ����� ���������, �� ����� FPU
	fstp st(0)	; ������� ������� ����� ��������� � BottomBorder
	fstp st(0)  ; ������� ������� ����� ��������� � TopBorder

	; ������� ���� RSP
	mov rsp, r9

	; ������� �� �������
	ret
Kernel ENDP
END