;SYSTEMS PROGRAMMING
;ASSIGNMENT 1
;MEHMET CAMBAZ
;040020365

segment .text
	global a5_key
	global a5_encrypt
	global a5_decrypt
	    
;*********************************************************    
threshold:
	push ebp
	mov ebp,esp
	sub esp,4		;int total
	
	mov eax,[ebp+8]		;eax = r1
	shr eax,9
	and eax,01h
	cmp eax,1
	jne zero1

	
cont1:	mov ebx,[ebp+12]	;ebx = r2
	shr ebx,11
	and ebx,01h
	cmp ebx,1
	jne zero2

	
cont2:  mov ecx,[ebp+16]	;ecx = r3
	shr ecx,11
	and ecx,01h
	cmp ecx,1
	jne zero3
	

cont3:  add eax,ebx
	add eax,ecx
	mov dword [ebp-4],eax	;total = eax
	mov eax,[ebp-4]
	cmp eax,1
	jg return_zero
	mov eax,1

end:	mov esp,ebp
	pop ebp
	ret

zero1:  mov eax,0
	jmp cont1
zero2:	mov ebx,0
	jmp cont2
zero3:	mov ecx,0
	jmp cont3
return_zero: 
	mov eax,0
	jmp end

	
	
;*********************************************************	
clock_r1:
	push ebp
	mov ebp,esp
	sub esp,4		;unsigned long feedback
	
	mov eax,[ebp+8]		;eax = ctl
	mov ebx,[ebp+12]	;ebx = r1
	mov edx,ebx		;backup r1 at edx
	shr ebx,9
	and ebx,1h
	xor eax,ebx	
	cmp eax,0
	jle return_org_r1	
	mov eax,edx
	shr eax,18
	mov ebx,edx
	shr ebx,17
	mov ecx,edx
	shr ecx,16
	shr edx,13		;edx has already r1
	xor eax,ebx
	xor eax,ecx
	xor eax,edx
	mov dword [ebp-4],eax	;feedback = eax
	mov ebx,[ebp+12]	;ebx = r1
	shl ebx,1
	and ebx,7FFFFh		;ebx = new r1 in the if. ( r1=r1<<1&0x7ffff )
	mov eax,[ebp-4]		;eax = feedback
	and eax,01h
	cmp eax,0
	jle end2
	xor ebx,01h		;r1 = r1^0x01
	
end2:   mov eax,ebx		;return r1
	mov esp,ebp
	pop ebp
	ret	
	
return_org_r1:
	mov ebx,edx		;ebx = r1, r1 will be original r1 that has come
	jmp end2	

	
	
;*********************************************************	
clock_r2:
	push ebp
	mov ebp,esp
	sub esp,4		;unsigned long feedback
	
	mov eax,[ebp+8]		;eax = ctl
	mov ebx,[ebp+12]	;ebx = r2
	mov edx,ebx		;backup r2 at edx
	shr ebx,11
	and ebx,1h
	xor eax,ebx	
	cmp eax,0
	jle return_org_r2	
	mov eax,edx
	shr eax,21
	mov ebx,edx
	shr ebx,20
	mov ecx,edx
	shr ecx,16
	shr edx,12		;edx has already r2
	xor eax,ebx
	xor eax,ecx
	xor eax,edx
	mov dword [ebp-4],eax	;feedback = eax
	mov ebx,[ebp+12]	;ebx = r2
	shl ebx,1
	and ebx,3FFFFFh		;ebx = new r2 in the if. ( r2=r2<<1&0x3fffff )
	mov eax,[ebp-4]		;eax = feedback
	and eax,01h
	cmp eax,0
	jle end3
	xor ebx,01h		;r2 = r2^0x01
	
end3:	mov eax,ebx		;return r2
	mov esp,ebp
	pop ebp
	ret	
	
return_org_r2:
	mov ebx,[ebp+12]	;ebx = r2, r2 will be original r2 that has come
	jmp end3	

	
		
;*********************************************************	
clock_r3:
	push ebp
	mov ebp,esp
	sub esp,4		;unsigned long feedback
	
	mov eax,[ebp+8]		;eax = ctl
	mov ebx,[ebp+12]	;ebx = r3
	mov edx,ebx		;backup r3 at edx
	shr ebx,11
	and ebx,1h
	xor eax,ebx	
	cmp eax,0
	jle return_org_r3	
	mov eax,edx
	shr eax,22
	mov ebx,edx
	shr ebx,21
	mov ecx,edx
	shr ecx,18
	shr edx,17		;edx has already r3
	xor eax,ebx
	xor eax,ecx
	xor eax,edx
	mov dword [ebp-4],eax	;feedback = eax
	mov ebx,[ebp+12]
	shl ebx,1
	and ebx,7FFFFFh		;ebx = new r3 in the if. ( r3=r3<<1&0x3fffff )
	mov eax,[ebp-4]		;eax = feedback
	and eax,01h
	cmp eax,0
	jle end4
	xor ebx,01h		;r3 = r3^0x01
	
end4:	mov eax,ebx		;return r3
	mov esp,ebp
	pop ebp
	ret	
	
return_org_r3:
	mov ebx,[ebp+12]	;ebx = r3, r3 will be original r3 that has come
	jmp end4
	
	
;*********************************************************
a5_key:
	push ebp
	mov ebp,esp

	mov ecx,[ebp+8]		;ecx = start address of c[]
	mov edx,[ebp+12]	;edx = start address of k[]
	
	mov eax,[edx]		;eax = k[0]
	and eax,000000FFh	;eax's lower eight bits (0-7) contain k[0]
	shl eax,11
	mov ebx,[edx+1]		;ebx = k[1]
	and ebx,000000FFh	;ebx's lower eight bits (0-7) contain k[1]
	shl ebx,3
	or eax,ebx
	mov ebx,[edx+2]		;ebx = k[2]
	and ebx,000000FFh	;ebx's lower eight bits (0-7) contain k[2]
	shr ebx,5
	or eax,ebx
	mov [ecx],eax		;c->r1 = calculated value

	
	mov eax,[edx+2]		;eax = k[2]
	and eax,000000FFh	;eax's lower eight bits (0-7) contain k[2]
	shl eax,17
	mov ebx,[edx+3]		;ebx = k[3]
	and ebx,000000FFh	;ebx's lower eight bits (0-7) contain k[3]
	shl ebx,9
	or eax,ebx
	mov ebx,[edx+4]		;ebx = k[4]
	and ebx,000000FFh	;ebx's lower eight bits (0-7) contain k[4]
	shr ebx,1
	or eax,ebx
	mov ebx,[edx+5]		;ebx = k[5]
	and ebx,000000FFh	;ebx's lower eight bits (0-7) contain k[5]
	shr ebx,7
	or eax,ebx
	mov [ecx+4],eax		;c->r2 = calculated value	

	
	mov eax,[edx+5]		;eax = k[5]
	and eax,000000FFh	;eax's lower eight bits (0-7) contain k[5]
	shl eax,15
	mov ebx,[edx+6]		;ebx = k[6]
	and ebx,000000FFh	;ebx's lower eight bits (0-7) contain k[6]
	shl ebx,8
	or eax,ebx
	mov ebx,[edx+7]		;ebx = k[7]
	and ebx,000000FFh	;ebx's lower eight bits (0-7) contain k[7]
	or eax,ebx
	mov [ecx+8],eax		;c->r3 = calculated value	
		
	mov esp,ebp
	pop ebp
	ret


;*********************************************************
a5_step:
	push ebp
	mov ebp,esp
	sub esp,4		;int control
	
	mov edx,[ebp+8]		;start address of c
	
	mov eax,[edx+8]		;eax = c->r3
	push eax
	mov eax,[edx+4]		;eax = c->r2
	push eax
	mov eax,[edx]		;eax = c->r1
	push eax
	call threshold
	add esp,12
	
	mov [ebp-4],eax		;threshold return value is assigned to eax
				;so, do control = eax
	mov edx,[ebp+8]		;start address of c is reassigned because it will have been changed
	mov eax,[edx]		;eax = c->r1
	push eax
	mov eax,[ebp-4]		;eax = control
	push eax
	call clock_r1
	add esp,8
	
	
	mov edx,[ebp+8]		;start address of c is reassigned because it will have been changed
	mov [edx],eax		;c->r1 = clock_r1(control, c->r1)
	
	mov eax,[edx+4]		;eax = c->r2
	push eax
	mov eax,[ebp-4]		;eax = control
	push eax
	call clock_r2
	add esp,8

	mov edx,[ebp+8]		;start address of c is reassigned because it will have been changed
	mov [edx+4],eax		;c->r2 = clock_r2(control, c->r2)
	
	
	mov eax,[edx+8]		;eax = c->r3
	push eax
	mov eax,[ebp-4]		;eax = control
	push eax
	call clock_r3
	add esp,8

	mov edx,[ebp+8]		;start address of c is reassigned because it will have been changed
	mov [edx+8],eax		;c->r3 = clock_r3(control, c->r3)

	mov ebx,[edx+4]		;ebx = c->r2 
	xor eax,ebx		;c->r2^c->r3
	mov ebx,[edx]		;ebx = c->r1
	xor eax,ebx		;c->r1^c->r2^c->r3
	and eax,1
	
	mov esp,ebp
	pop ebp
	ret	


;*********************************************************	
a5_encrypt:
	push ebp
	mov ebp,esp
	sub esp,12		;int i,j char t 
				;(ebp-4) i,(ebp-8) j,(ebp-12) t

	mov dword [ebp-4],00000000h	;i = 0
	mov dword [ebp-8],00000000h	;j = 0
	mov byte [ebp-12],00h		;t = 00h

	
next_i: mov ebx,[ebp-4]		;ebx = i
	mov edx,[ebp+16]	;edx = len
	cmp ebx,edx		;i == len ? first for ends : continue
	je end5
	mov dword [ebp-8],00000000h	;j = 0
	mov ecx,[ebp-8]		;ecx = j
	
next_j:	cmp ecx,8		;j == 8 ? second for ends : continue	
	je after

	mov eax,00000000h
	mov eax,[ebp+8]		;start address of c[]	
	push eax
	call a5_step
	add esp,4
	
	mov cl,byte [ebp-12]	;ecx = t
	and ecx,000000FFh	;t is at lower eight bits (0-7) of ecx
	shl ecx,1		;t<<1
	or ecx,eax		;t<<1 OR a5_step(c)
	mov [ebp-12],ecx	;t = calculated value

	mov ecx,[ebp-8]		;ecx = j
	inc ecx
	mov [ebp-8],ecx	
		
	jmp next_j

after:	mov ecx,00000000h
	mov ecx,[ebp+12]	;ecx = address of data[]	
	mov ebx,[ebp-4]		;ebx = i
	add ecx,ebx		;data start address + i	
	mov eax,[ecx]		;eax = data[i]
	and eax,000000FFh	;data[i] is at lower eight bits (0-7) of eax
	
	mov edx,ecx		;address of data[i] is backuped at edx
	mov ecx,00000000h
	mov ecx,[ebp-12]	;ecx = t
	xor eax,ecx		;eax = data[i]^t
	mov ecx,edx
	mov [ecx],al		;data[i] = lower eight bits of eax

	mov ebx,[ebp-4]		;ebx = i
	inc ebx			;i++
	mov [ebp-4],ebx

	jmp next_i

	
end5:	mov esp,ebp
	pop ebp
	ret	

	
;*********************************************************
a5_decrypt:
	push ebp
	mov ebp,esp

	mov eax,[ebp+16]	;len
	push eax
	mov eax,[ebp+12]	;data
	push eax
	mov eax,[ebp+8]		;c
	push eax
	call a5_encrypt
	add esp,12	


	mov esp,ebp
	pop ebp
	ret
	