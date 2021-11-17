bits 16 ;We're working on real 16bit mode

;In real mode, we address using the logical address instead of the physical address, which consists of the 64k in which it resides
;and its offset from the beginning of that segment. That 64k segment is divided by 16:
;Given a logical address beggining at 64k segment A with offset B; we can reconstruct the physical address this way: A*0x10+B

;Our code resides at 0x7C00, so the segment will begin at 0x7C0

;STACK
	mov 	ax, 	0x7C0
	mov 	ds, 	ax
	;We'll start the storage segment for the stack after the 512 of the bootloader
	;The bootloader extends from 0x7C00 for 512 bytes to 0x7E00, so the stack segment will be 0x7E0 
	mov 	ax, 	0x7E0
	mov 	ss, 	ax
	;On x86 architectures, the stack pointer decreases, so we have to initialize it to a number of bytes past the stack segment of the desired size.
	;The stack can address 64k bytes of memory, so 8k is a good size. We'll our SP to 0x2000
	mov 	sp, 	0x2000

	call 	clearscreen

	push 	0x0000
	call	movecursor
	add	sp,	2

	push	msg
	call	print
	add	sp,	2

	cli
	hlt

clearscreen:
	push 	bp
	mov 	bp, 	sp
	pusha

	mov 	ah, 	0x07 	;Tells BIOS to scroll down
	mov 	al, 	0x00 	;Clear window
	mov 	bh, 	0x07 	;White text on black bg
	mov 	cx, 	0x00 	;Specifies top left of screen as coordinate (0,0)
	mov 	dh, 	0x18 	;18h = 24 rows of characters
	mov 	dl, 	0x4F 	;4Fh = 79 columns of characters
	int 		0x10	;Video interrupt

	popa
	mov 	sp,	bp
	pop	bp
	ret

movecursor:
	push	bp
	mov	bp,	sp
	pusha

	mov	dx,	[bp+4]
	mov	ah,	0x02
	mov	bh,	0x00
	int	0x10

	popa
	mov	sp,	bp
	pop	bp
	ret
print:
	push	bp
	mov	bp,	sp
	pusha

	mov	si,	[bp+4]	;Grab pointer to data
	mov	bh,	0x00	;Page number 0
	mov	bl,	0x00	;Foreground color
	mov	ah,	0x0E 	;Print to TTY
.char:
	mov	al,	[si]	;Get current char from pointer position
	add	si,	1	;Increment si until we get a null char
	or	al,	0
	je	.return		;End if string is done
	int	0x10		;Print character if not done
	jmp	.char		;Loop

.return:
	popa
	mov	sp,	bp
	pop	bp
	ret

msg:	db	"Working!", 0

times 510-($-$$) db 0
dw 0xAA55


