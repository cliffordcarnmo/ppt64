	;$64 charindex
	;$65 rowindex
	;$66 cursorcolorindex
	;$67 pause
	;$80 colormempointer
	;$82 screenmempointer
	;$84 textcolorpointer
	;$86 textpointer
	
	tcm = $d800 + 13 * 40

	*= $0801

	jsr $e544

	lda #$01
	sta $d020
	sta $d021

	sei

	lda #%00110101
	sta $01

	lda #%01111111
	sta $dc0d
	sta $dd0d

	lda #%00000001
	sta $d01a

	lda #%00011011
	sta $d011

	lda #%11001000
	sta $d016

	lda #%00011110
	sta $d018

	lda #$00
	sta $d012

	lda #<irq 
	sta $fffe
	lda #>irq
	sta $ffff

	cli
	
	jsr resetpointers
	jsr setspritepointers

	jmp *

irq:
	asl $d019
	
	jsr textwriter

	lda #$00
	sta $d012

	lda #<irq
	sta $fffe
	lda #>irq
	sta $ffff
	rti

textwriter:
	lda $66
	cmp #26
	beq resetcursorcolor
	inc $66

	jsr checkpause
	rts

resetcursorcolor:
	lda #$00
	sta $66
	rts

checkspace:
	lda #$7f
	sta $dc00
	
	lda	$dc01
	and #$10
	beq spacepressed
	rts

checkpause:
	lda $67
	cmp #$00
	beq dotext
	bpl dopause
	rts

dopause:
	jsr resetlogo
	jsr writecursor
	jsr checkspace
	rts

spacepressed:
	jsr clearindices
	jsr setcolorpointer
	jsr setscreenpointer
	jsr clearscreen
	rts

fadelogo:
	ldx $66
	lda $42aa,x
	sta $d027
	sta $d028
	sta $d029
	sta $d02a
	rts

resetlogo:
	lda #$02
	sta $d027
	sta $d028
	sta $d029
	sta $d02a
	rts

clearscreen:
	lda #$20
	ldx #$00
-
	sta $0608,x

	inx
	bne -

	ldx #$00
-
	sta $0608 + 255,x

	inx
	cpx #225
	bne -
	rts

dotext:
	jsr fadelogo
	jsr writecharacter
	jsr writecursor
	rts

writecursor:
	ldx $66
	ldy $64
	lda $42aa,x
	sta ($80),y

	lda #$40
	sta ($82),y
	rts

writecharacter:
	jsr pickcolor

	ldy $64
	lda ($86),y
	cmp #$ff
	beq resetpointers
	sta ($82),y

	cpy #39
	beq nextrow

	inc $64
	rts

pickcolor:
	lda $65
	cmp #$00
	beq setcaptioncolor
	bpl settextcolor
	rts

setcaptioncolor:
	lda #$02
	jsr setcolor
	rts

settextcolor:
	lda #$00
	jsr setcolor
	rts

setcolor:
	ldy $64
	sta ($80),y
	rts

pushoffsets:
	clc

	lda $80
	adc #40
	sta $80
	lda $80 + 1
	adc #$00
	sta $80 + 1

	lda $84
	adc #40
	sta $84
	lda $84 + 1
	adc #$00
	sta $84 + 1

	lda $82
	adc #40
	sta $82
	lda $82 + 1
	adc #$00
	sta $82 + 1
	rts

pushrowoffset:
	clc

	lda $86
	adc #40
	sta $86
	lda $86 + 1
	adc #$00
	sta $86 + 1
	rts

nextrow:
	jsr pushrowoffset

	lda $65
	cmp #$0a
	beq nextscreen

	jsr pushoffsets

	lda #$00
	sta $64

	inc $65
	rts

nextscreen:
	lda #$01
	sta $67
	rts

resetpointers:
	jsr clearindices
	jsr setcolorpointer
	jsr setscreenpointer
	jsr settextpointer
	rts

clearindices:
	lda #$00
	sta $64
	sta $65
	sta $66
	jsr nopause
	rts

nopause:
	lda #$00
	sta $67
	rts

setcolorpointer:
	lda #<tcm
	sta $80
	lda #>tcm
	sta $80 + 1
	rts

setscreenpointer:
	lda #$08
	sta $82
	lda #$06
	sta $82 + 1
	rts

settextpointer:
	lda #$40
	sta $86
	lda #$44
	sta $86 + 1
	rts

setspritepointers:
	lda #$f8
	sta $07f8

	lda #$f9
	sta $07f9

	lda #$fa
	sta $07fa

	lda #$fb
	sta $07fb

	lda #%00001111
	sta $d015
	sta $d01b

	lda #%00001111
	sta $d017
	sta $d01d

	lda #$02
	sta $d027
	sta $d028
	sta $d029
	sta $d02a

	lda #130
	sta $d000

	lda #108-55
	sta $d001

	lda #178
	sta $d002

	lda #108-55
	sta $d003

	lda #130
	sta $d004

	lda #150-55
	sta $d005

	lda #178
	sta $d006

	lda #150-55
	sta $d007
	rts

	*= $3800
	!byte $7c, $c6, $de, $de, $dc, $c0, $7c, $00, $7c, $c6, $c6, $fe, $c6, $c6, $c6, $00, $fc, $c6, $c6, $fc, $c6, $c6, $fc, $00, $7e, $c0, $c0, $c0, $c0, $c0, $7e, $00, $fc, $c6, $c6, $c6, $c6, $c6, $fc, $00, $7e, $c0, $c0, $fc, $c0, $c0, $7e, $00, $7e, $c0, $c0, $fc, $c0, $c0, $c0, $00, $7c, $c0, $c0, $de, $c6, $c6, $7c, $00, $c6, $c6, $c6, $fe, $c6, $c6, $c6, $00, $30, $30, $30, $30, $30, $30, $30, $00, $06, $06, $06, $06, $06, $c6, $7c, $00, $c6, $c6, $c6, $fc, $c6, $c6, $c6, $00, $c0, $c0, $c0, $c0, $c0, $c0, $7e, $00, $c6, $ee, $d6, $c6, $c6, $c6, $c6, $00, $c6, $e6, $f6, $de, $ce, $c6, $c6, $00, $7c, $c6, $c6, $c6, $c6, $c6, $7c, $00, $fc, $c6, $c6, $fc, $c0, $c0, $c0, $00, $7c, $c6, $c6, $c6, $d6, $ce, $7c, $00, $fc, $c6, $c6, $fc, $c6, $c6, $c6, $00, $7e, $c0, $c0, $7c, $06, $06, $fc, $00, $fc, $30, $30, $30, $30, $30, $30, $00, $c6, $c6, $c6, $c6, $c6, $c6, $7c, $00, $c6, $c6, $c6, $c6, $c6, $6c, $38, $00, $c6, $c6, $c6, $d6, $fe, $ee, $c6, $00, $c6, $c6, $c6, $7c, $c6, $c6, $c6, $00, $cc, $cc, $cc, $78, $30, $30, $30, $00, $fe, $0c, $18, $30, $60, $c0, $fe, $00, $7e, $60, $60, $60, $60, $60, $7e, $00, $3c, $66, $60, $60, $f8, $60, $fc, $00, $fc, $0c, $0c, $0c, $0c, $0c, $fc, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $30, $30, $30, $30, $30, $00, $30, $00, $66, $66, $00, $00, $00, $00, $00, $00, $6c, $6c, $fe, $6c, $fe, $6c, $6c, $00, $30, $7e, $c0, $7c, $06, $fc, $30, $00, $00, $c6, $cc, $18, $30, $66, $c6, $00, $78, $cc, $d8, $7c, $da, $cc, $76, $00, $30, $30, $60, $00, $00, $00, $00, $00, $3c, $60, $c0, $c0, $c0, $60, $3c, $00, $78, $0c, $06, $06, $06, $0c, $78, $00, $00, $6c, $38, $fe, $38, $6c, $00, $00, $00, $18, $18, $7e, $18, $18, $00, $00, $00, $00, $00, $00, $30, $30, $60, $00, $00, $00, $00, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00, $30, $30, $00, $00, $06, $0c, $18, $30, $60, $c0, $00, $7c, $c6, $ce, $d6, $e6, $c6, $7c, $00, $30, $70, $30, $30, $30, $30, $30, $00, $7c, $c6, $0c, $18, $30, $60, $fe, $00, $fc, $06, $06, $7c, $06, $06, $fc, $00, $c6, $c6, $c6, $7e, $06, $06, $06, $00, $fe, $c0, $c0, $fc, $06, $06, $fc, $00, $7c, $c0, $c0, $fc, $c6, $c6, $7c, $00, $fc, $06, $06, $3e, $06, $06, $06, $00, $7c, $c6, $c6, $7c, $c6, $c6, $7c, $00, $7c, $c6, $c6, $7e, $06, $06, $06, $00, $00, $30, $30, $00, $00, $30, $30, $00, $00, $30, $30, $00, $00, $30, $60, $00, $1c, $30, $60, $c0, $60, $30, $1c, $00, $00, $00, $fc, $00, $00, $fc, $00, $00, $70, $18, $0c, $06, $0c, $18, $70, $00, $7c, $c6, $06, $3c, $30, $00, $30, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6c, $fe, $fe, $fe, $7c, $38, $10, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $ff, $ff, $ff, $00, $00, $00, $00, $00

	*= $3e00
	!byte $00, $00, $03, $00, $00, $0f, $00, $00, $3f, $00, $00, $ff, $00, $03, $fe, $00, $0f, $fc, $00, $3f, $f0, $00, $ff, $c0, $03, $ff, $03, $0f, $fc, $0f, $3f, $f0, $3f, $ff, $c0, $ff, $ff, $e3, $ff, $fc, $f7, $ff, $f8, $7f, $ff, $f0, $1f, $ff, $f0, $07, $ff, $f8, $81, $ff, $fc, $e0, $7f, $fc, $f8, $1e, $fc, $fe, $04, $00, $c0, $00, $00, $f0, $00, $00, $fc, $00, $00, $ff, $00, $00, $7f, $c0, $00, $3f, $f0, $00, $0f, $fc, $00, $03, $ff, $00, $c0, $ff, $c0, $f0, $3f, $f0, $fc, $0f, $fc, $ff, $03, $ff, $ff, $c7, $ff, $ff, $ef, $3f, $ff, $fe, $1f, $ff, $f8, $0f, $ff, $e0, $0f, $ff, $81, $1f, $fe, $07, $3f, $78, $1f, $3f, $20, $7f, $3f, $00, $fc, $ff, $80, $fc, $ff, $e0, $fc, $ff, $fc, $f8, $7f, $fe, $f0, $3f, $ff, $f0, $3f, $ff, $f8, $7f, $ff, $fc, $f7, $ff, $ff, $e3, $ff, $7f, $c0, $ff, $3f, $f0, $3f, $0f, $fc, $0f, $03, $ff, $03, $00, $ff, $c0, $00, $3f, $f0, $00, $0f, $fc, $00, $03, $fe, $00, $00, $ff, $00, $00, $3f, $00, $00, $0f, $00, $00, $03, $00, $01, $ff, $3f, $07, $ff, $3f, $3f, $ff, $3f, $7f, $fe, $1f, $ff, $fc, $0f, $ff, $fc, $0f, $ff, $fe, $1f, $ff, $ef, $3f, $ff, $c7, $ff, $ff, $03, $fe, $fc, $0f, $fc, $f0, $3f, $f0, $c0, $ff, $c0, $03, $ff, $00, $0f, $fc, $00, $3f, $f0, $00, $7f, $c0, $00, $ff, $00, $00, $fc, $00, $00, $f0, $00, $00, $c0, $00, $00

	*= $42aa
	!byte $01, $01, $01, $01, $0f, $0f, $0f, $0f, $0c, $0c, $0c, $0c, $02, $02, $02, $0c, $0c, $0c, $0c, $0f, $0f, $0f, $0f, $01, $01, $01, $01

	*= $4440
	!scr "                slide 1                 "
	!scr "                                        "
	!scr "                                        "
	!scr "* example text 1                        "
	!scr "* example text 2                        "
	!scr "* example text 3                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "

	!scr "                slide 2                 "
	!scr "                                        "
	!scr "                                        "
	!scr "* example text 4                        "
	!scr "* example text 5                        "
	!scr "* example text 6                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "	

	!scr "                slide 3                 "
	!scr "                                        "
	!scr "                                        "
	!scr "* example text 7                        "
	!scr "* example text 8                        "
	!scr "* example text 9                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!byte $ff
