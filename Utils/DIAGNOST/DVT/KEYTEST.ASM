	ifndef	??version
?debug	macro
	endm
publicdll macro	name
	public	name
	endm
$comm	macro	name,dist,size,count
	comm	dist name:BYTE:count*size
	endm
	else
$comm	macro	name,dist,size,count
	comm	dist name[size]:BYTE:count
	endm
	endif
	?debug	V 300h
	?debug	S "keytest.c"
	?debug	C E9C0BC271B096B6579746573742E63
	?debug	C E94019CA1815443A5C42435C494E434C5544455C737464696F2E68
	?debug	C E94019CA1815443A5C42435C494E434C5544455C5F646566732E68
	?debug	C E94019CA1816443A5C42435C494E434C5544455C5F6E66696C652E+
	?debug	C 68
	?debug	C E94019CA1815443A5C42435C494E434C5544455C5F6E756C6C2E68
	?debug	C E94019CA1814443A5C42435C494E434C5544455C74696D652E68
	?debug	C E94019CA1813443A5C42435C494E434C5544455C6D656D2E68
	?debug	C E94019CA1813443A5C42435C494E434C5544455C646F732E68
	?debug	C E9D405B31A086B65796465662E68
	?debug	C E9E605B31A0A7363616E636F64652E68
_TEXT	segment byte public 'CODE'
_TEXT	ends
DGROUP	group	_DATA,_BSS
	assume	cs:_TEXT,ds:DGROUP
_DATA	segment word public 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends
_BSS	segment word public 'BSS'
b@	label	byte
b@w	label	word
_BSS	ends
_DATA	segment word public 'DATA'
_scanmap	label	word
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	27
	db	0
	db	252
	db	255
	db	254
	db	255
	db	255
	db	255
	db	0
	db	0
	db	49
	db	0
	db	33
	db	0
	db	49
	db	0
	db	136
	db	255
	db	0
	db	0
	db	50
	db	0
	db	64
	db	0
	db	50
	db	0
	db	135
	db	255
	db	0
	db	0
	db	51
	db	0
	db	35
	db	0
	db	51
	db	0
	db	134
	db	255
	db	0
	db	0
	db	52
	db	0
	db	36
	db	0
	db	52
	db	0
	db	133
	db	255
	db	0
	db	0
	db	53
	db	0
	db	37
	db	0
	db	53
	db	0
	db	132
	db	255
	db	0
	db	0
	db	54
	db	0
	db	94
	db	0
	db	54
	db	0
	db	131
	db	255
	db	0
	db	0
	db	55
	db	0
	db	38
	db	0
	db	55
	db	0
	db	130
	db	255
	db	0
	db	0
	db	56
	db	0
	db	42
	db	0
	db	56
	db	0
	db	129
	db	255
	db	0
	db	0
	db	57
	db	0
	db	40
	db	0
	db	57
	db	0
	db	128
	db	255
	db	0
	db	0
	db	48
	db	0
	db	41
	db	0
	db	48
	db	0
	db	127
	db	255
	db	0
	db	0
	db	45
	db	0
	db	95
	db	0
	db	45
	db	0
	db	45
	db	0
	db	0
	db	0
	db	61
	db	0
	db	43
	db	0
	db	61
	db	0
	db	61
	db	0
	db	0
	db	0
	db	8
	db	0
	db	8
	db	0
	db	8
	db	0
	db	8
	db	0
	db	0
	db	0
	db	9
	db	0
	db	241
	db	255
	db	108
	db	255
	db	91
	db	255
	db	0
	db	0
	db	113
	db	0
	db	81
	db	0
	db	17
	db	0
	db	240
	db	255
	db	1
	db	0
	db	119
	db	0
	db	87
	db	0
	db	23
	db	0
	db	239
	db	255
	db	1
	db	0
	db	101
	db	0
	db	69
	db	0
	db	5
	db	0
	db	238
	db	255
	db	1
	db	0
	db	114
	db	0
	db	82
	db	0
	db	18
	db	0
	db	237
	db	255
	db	1
	db	0
	db	116
	db	0
	db	84
	db	0
	db	20
	db	0
	db	236
	db	255
	db	1
	db	0
	db	121
	db	0
	db	89
	db	0
	db	25
	db	0
	db	235
	db	255
	db	1
	db	0
	db	117
	db	0
	db	85
	db	0
	db	21
	db	0
	db	234
	db	255
	db	1
	db	0
	db	105
	db	0
	db	73
	db	0
	db	9
	db	0
	db	233
	db	255
	db	1
	db	0
	db	111
	db	0
	db	79
	db	0
	db	15
	db	0
	db	232
	db	255
	db	1
	db	0
	db	112
	db	0
	db	80
	db	0
	db	16
	db	0
	db	231
	db	255
	db	1
	db	0
	db	91
	db	0
	db	123
	db	0
	db	91
	db	0
	db	91
	db	0
	db	0
	db	0
	db	93
	db	0
	db	125
	db	0
	db	93
	db	0
	db	93
	db	0
	db	0
	db	0
	db	13
	db	0
	db	13
	db	0
	db	10
	db	0
	db	228
	db	255
	db	0
	db	0
	db	84
	db	255
	db	84
	db	255
	db	84
	db	255
	db	84
	db	255
	db	0
	db	0
	db	97
	db	0
	db	65
	db	0
	db	1
	db	0
	db	226
	db	255
	db	1
	db	0
	db	115
	db	0
	db	83
	db	0
	db	19
	db	0
	db	225
	db	255
	db	1
	db	0
	db	100
	db	0
	db	68
	db	0
	db	4
	db	0
	db	224
	db	255
	db	1
	db	0
	db	102
	db	0
	db	70
	db	0
	db	6
	db	0
	db	223
	db	255
	db	1
	db	0
	db	103
	db	0
	db	71
	db	0
	db	7
	db	0
	db	222
	db	255
	db	1
	db	0
	db	104
	db	0
	db	72
	db	0
	db	8
	db	0
	db	221
	db	255
	db	1
	db	0
	db	106
	db	0
	db	74
	db	0
	db	10
	db	0
	db	220
	db	255
	db	1
	db	0
	db	107
	db	0
	db	75
	db	0
	db	11
	db	0
	db	219
	db	255
	db	1
	db	0
	db	108
	db	0
	db	76
	db	0
	db	12
	db	0
	db	218
	db	255
	db	1
	db	0
	db	59
	db	0
	db	58
	db	0
	db	59
	db	0
	db	59
	db	0
	db	0
	db	0
	db	39
	db	0
	db	34
	db	0
	db	39
	db	0
	db	39
	db	0
	db	0
	db	0
	db	96
	db	0
	db	126
	db	0
	db	96
	db	0
	db	96
	db	0
	db	0
	db	0
	db	82
	db	255
	db	82
	db	255
	db	82
	db	255
	db	82
	db	255
	db	0
	db	0
	db	92
	db	0
	db	124
	db	0
	db	92
	db	0
	db	92
	db	0
	db	0
	db	0
	db	122
	db	0
	db	90
	db	0
	db	26
	db	0
	db	212
	db	255
	db	1
	db	0
	db	120
	db	0
	db	88
	db	0
	db	24
	db	0
	db	211
	db	255
	db	1
	db	0
	db	99
	db	0
	db	67
	db	0
	db	3
	db	0
	db	210
	db	255
	db	1
	db	0
	db	118
	db	0
	db	86
	db	0
	db	22
	db	0
	db	209
	db	255
	db	1
	db	0
	db	98
	db	0
	db	66
	db	0
	db	2
	db	0
	db	208
	db	255
	db	1
	db	0
	db	110
	db	0
	db	78
	db	0
	db	14
	db	0
	db	207
	db	255
	db	1
	db	0
	db	109
	db	0
	db	77
	db	0
	db	13
	db	0
	db	206
	db	255
	db	1
	db	0
	db	44
	db	0
	db	60
	db	0
	db	44
	db	0
	db	44
	db	0
	db	0
	db	0
	db	46
	db	0
	db	62
	db	0
	db	46
	db	0
	db	46
	db	0
	db	0
	db	0
	db	47
	db	0
	db	63
	db	0
	db	47
	db	0
	db	47
	db	0
	db	0
	db	0
	db	83
	db	255
	db	83
	db	255
	db	83
	db	255
	db	83
	db	255
	db	0
	db	0
	db	42
	db	0
	db	42
	db	0
	db	42
	db	0
	db	42
	db	0
	db	0
	db	0
	db	85
	db	255
	db	85
	db	255
	db	85
	db	255
	db	85
	db	255
	db	0
	db	0
	db	32
	db	0
	db	32
	db	0
	db	32
	db	0
	db	32
	db	0
	db	0
	db	0
	db	89
	db	255
	db	89
	db	255
	db	89
	db	255
	db	89
	db	255
	db	0
	db	0
	db	197
	db	255
	db	172
	db	255
	db	162
	db	255
	db	152
	db	255
	db	0
	db	0
	db	196
	db	255
	db	171
	db	255
	db	161
	db	255
	db	151
	db	255
	db	0
	db	0
	db	195
	db	255
	db	170
	db	255
	db	160
	db	255
	db	150
	db	255
	db	0
	db	0
	db	194
	db	255
	db	169
	db	255
	db	159
	db	255
	db	149
	db	255
	db	0
	db	0
	db	193
	db	255
	db	168
	db	255
	db	158
	db	255
	db	148
	db	255
	db	0
	db	0
	db	192
	db	255
	db	167
	db	255
	db	157
	db	255
	db	147
	db	255
	db	0
	db	0
	db	191
	db	255
	db	166
	db	255
	db	156
	db	255
	db	146
	db	255
	db	0
	db	0
	db	190
	db	255
	db	165
	db	255
	db	155
	db	255
	db	145
	db	255
	db	0
	db	0
	db	189
	db	255
	db	164
	db	255
	db	154
	db	255
	db	144
	db	255
	db	0
	db	0
	db	188
	db	255
	db	163
	db	255
	db	153
	db	255
	db	143
	db	255
	db	0
	db	0
	db	88
	db	255
	db	88
	db	255
	db	88
	db	255
	db	88
	db	255
	db	0
	db	0
	db	90
	db	255
	db	90
	db	255
	db	90
	db	255
	db	90
	db	255
	db	0
	db	0
	db	185
	db	255
	db	55
	db	0
	db	137
	db	255
	db	105
	db	255
	db	2
	db	0
	db	184
	db	255
	db	56
	db	0
	db	115
	db	255
	db	104
	db	255
	db	2
	db	0
	db	183
	db	255
	db	57
	db	0
	db	124
	db	255
	db	103
	db	255
	db	2
	db	0
	db	45
	db	0
	db	45
	db	0
	db	45
	db	0
	db	45
	db	0
	db	2
	db	0
	db	181
	db	255
	db	52
	db	0
	db	141
	db	255
	db	101
	db	255
	db	2
	db	0
	db	0
	db	0
	db	53
	db	0
	db	0
	db	0
	db	0
	db	0
	db	2
	db	0
	db	179
	db	255
	db	54
	db	0
	db	140
	db	255
	db	99
	db	255
	db	2
	db	0
	db	43
	db	0
	db	43
	db	0
	db	43
	db	0
	db	43
	db	0
	db	2
	db	0
	db	177
	db	255
	db	49
	db	0
	db	139
	db	255
	db	97
	db	255
	db	2
	db	0
	db	176
	db	255
	db	50
	db	0
	db	111
	db	255
	db	96
	db	255
	db	2
	db	0
	db	175
	db	255
	db	51
	db	0
	db	138
	db	255
	db	95
	db	255
	db	2
	db	0
	db	174
	db	255
	db	48
	db	0
	db	110
	db	255
	db	94
	db	255
	db	2
	db	0
	db	173
	db	255
	db	46
	db	0
	db	109
	db	255
	db	93
	db	255
	db	2
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	92
	db	0
	db	124
	db	0
	db	92
	db	0
	db	92
	db	0
	db	0
	db	0
	db	123
	db	255
	db	121
	db	255
	db	119
	db	255
	db	117
	db	255
	db	0
	db	0
	db	122
	db	255
	db	120
	db	255
	db	118
	db	255
	db	116
	db	255
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
_G_shiftstat	label	byte
	db	0
_G_extnext	label	word
	db	0
	db	0
_G_kpstart	label	word
	db	0
	db	0
_G_kpend	label	word
	db	0
	db	0
_G_keypress	label	word
	db	0
	db	0
_G_hadcrdn	label	word
	db	0
	db	0
_G_tl	label	byte
	db	32
	db	201
	db	205
	db	65
	db	205
	db	203
	db	205
	db	66
	db	205
	db	203
	db	205
	db	67
	db	205
	db	203
	db	205
	db	68
	db	205
	db	203
	db	205
	db	69
	db	205
	db	203
	db	205
	db	70
	db	205
	db	203
	db	205
	db	71
	db	205
	db	203
	db	205
	db	72
	db	205
	db	203
	db	205
	db	73
	db	205
	db	203
	db	205
	db	74
	db	205
	db	203
	db	205
	db	75
	db	205
	db	203
	db	205
	db	76
	db	205
	db	203
	db	205
	db	77
	db	205
	db	203
	db	205
	db	78
	db	205
	db	203
	db	205
	db	79
	db	205
	db	187
	db	32
	db	0
_G_m1	label	byte
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	32
	db	32
	db	186
	db	32
	db	0
_G_m2	label	byte
	db	32
	db	204
	db	205
	db	205
	db	205
	db	206
	db	205
	db	205
	db	205
	db	206
	db	205
	db	205
	db	205
	db	206
	db	205
	db	205
	db	205
	db	206
	db	205
	db	205
	db	205
	db	206
	db	205
	db	205
	db	205
	db	206
	db	205
	db	205
	db	205
	db	206
	db	205
	db	205
	db	205
	db	206
	db	205
	db	205
	db	205
	db	206
	db	205
	db	205
	db	205
	db	206
	db	205
	db	205
	db	205
	db	206
	db	205
	db	205
	db	205
	db	206
	db	205
	db	205
	db	205
	db	206
	db	205
	db	205
	db	205
	db	206
	db	205
	db	205
	db	205
	db	185
	db	32
	db	0
_G_bl	label	byte
	db	32
	db	200
	db	205
	db	205
	db	205
	db	202
	db	205
	db	205
	db	205
	db	202
	db	205
	db	205
	db	205
	db	202
	db	205
	db	205
	db	205
	db	202
	db	205
	db	205
	db	205
	db	202
	db	205
	db	205
	db	205
	db	202
	db	205
	db	205
	db	205
	db	202
	db	205
	db	205
	db	205
	db	202
	db	205
	db	205
	db	205
	db	202
	db	205
	db	205
	db	205
	db	202
	db	205
	db	205
	db	205
	db	202
	db	205
	db	205
	db	205
	db	202
	db	205
	db	205
	db	205
	db	202
	db	205
	db	205
	db	205
	db	202
	db	205
	db	205
	db	205
	db	188
	db	32
	db	0
_G_scanlyt	label	byte
	db	60
	db	12
	db	13
	db	53
	db	54
	db	84
	db	85
	db	86
	db	87
	db	66
	db	67
	db	68
	db	58
	db	69
	db	70
	db	15
	db	41
	db	88
	db	43
	db	89
	db	26
	db	27
	db	39
	db	90
	db	91
	db	40
	db	92
	db	93
	db	71
	db	73
	db	94
	db	95
	db	96
	db	97
	db	98
	db	99
	db	100
	db	101
	db	102
	db	103
	db	104
	db	74
	db	78
	db	79
	db	81
	db	16
	db	17
	db	18
	db	19
	db	20
	db	21
	db	22
	db	23
	db	24
	db	25
	db	63
	db	8
	db	9
	db	10
	db	65
	db	59
	db	30
	db	31
	db	32
	db	33
	db	34
	db	35
	db	36
	db	37
	db	38
	db	62
	db	5
	db	6
	db	7
	db	64
	db	1
	db	44
	db	45
	db	46
	db	47
	db	48
	db	49
	db	50
	db	51
	db	52
	db	61
	db	2
	db	3
	db	4
	db	0
	db	42
	db	29
	db	56
	db	0
	db	57
	db	0
	db	72
	db	80
	db	75
	db	77
	db	14
	db	83
	db	11
	db	82
	db	28
_G_scanpos	label	byte
	db	94
	db	80
	db	91
	db	92
	db	93
	db	75
	db	76
	db	77
	db	59
	db	60
	db	61
	db	108
	db	1
	db	2
	db	106
	db	16
	db	48
	db	49
	db	50
	db	51
	db	52
	db	53
	db	54
	db	55
	db	56
	db	57
	db	21
	db	22
	db	110
	db	97
	db	65
	db	66
	db	67
	db	68
	db	69
	db	70
	db	71
	db	72
	db	73
	db	23
	db	26
	db	17
	db	96
	db	19
	db	81
	db	82
	db	83
	db	84
	db	85
	db	86
	db	87
	db	88
	db	89
	db	3
	db	4
	db	0
	db	98
	db	100
	db	12
	db	64
	db	0
	db	90
	db	74
	db	58
	db	78
	db	62
	db	9
	db	10
	db	11
	db	13
	db	14
	db	29
	db	102
	db	30
	db	43
	db	104
	db	105
	db	44
	db	45
	db	103
	db	46
	db	109
	db	107
	db	5
	db	6
	db	7
	db	8
	db	18
	db	20
	db	24
	db	25
	db	27
	db	28
	db	32
	db	33
	db	34
	db	35
	db	36
	db	37
	db	38
	db	39
	db	40
	db	41
	db	42
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	void prline(int x,int y,unsigned char *str)
   ;	
	assume	cs:_TEXT
_prline	proc	near
	push	bp
	mov	bp,sp
	sub	sp,6
	push	si
	mov	si,word ptr [bp+8]
   ;	
   ;	{
   ;	    unsigned int far *s;
   ;	    unsigned int attr;
   ;	
   ;	    if (Location==CT) {
   ;	
	cmp	word ptr DGROUP:_Location,1
	jne	short @1@86
   ;	
   ;	        s=(unsigned int far *)0xB0000000L;
   ;	
	mov	word ptr [bp-2],-20480
	jmp	short @1@114
@1@86:
   ;	
   ;	    } else {
   ;	        s=(unsigned int far *)0xB8000000L;
   ;	
	mov	word ptr [bp-2],-18432
@1@114:
	mov	word ptr [bp-4],0
   ;	
   ;	    }
   ;	    s+=x+y*80;
   ;	
	mov	ax,word ptr [bp+6]
	mov	dx,80
	imul	dx
	mov	dx,word ptr [bp+4]
	add	dx,ax
	shl	dx,1
	add	word ptr [bp-4],dx
   ;	
   ;	    attr=0x0700;
   ;	
	mov	word ptr [bp-6],1792
	jmp	short @1@198
@1@170:
   ;	
   ;	
   ;	    while (*str) *(s++)=attr|*(str++);
   ;	
	mov	al,byte ptr [si]
	mov	ah,0
	mov	dx,word ptr [bp-6]
	or	dx,ax
	les	bx,dword ptr [bp-4]
	mov	word ptr es:[bx],dx
	inc	si
	add	word ptr [bp-4],2
@1@198:
	cmp	byte ptr [si],0
	jne	short @1@170
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_prline	endp
   ;	
   ;	unsigned int findkey(int k)
   ;	
	assume	cs:_TEXT
_findkey	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
   ;	
   ;	{
   ;		int i,j;
   ;		for (i=0;i<7;i++) {
   ;	
	xor	si,si
	jmp	short @2@254
@2@58:
   ;	
   ;			for (j=0;j<15;j++) {
   ;	
	xor	di,di
	jmp	short @2@198
@2@86:
   ;	
   ;				if (G_scanlyt[i][j]==k) return(((i<<8)|j)|0x80);
   ;	
	mov	ax,si
	mov	dx,15
	imul	dx
	add	ax,di
	mov	bx,ax
	mov	al,byte ptr DGROUP:_G_scanlyt[bx]
	mov	ah,0
	cmp	ax,word ptr [bp+4]
	jne	short @2@170
	mov	ax,si
	mov	cl,8
	shl	ax,cl
	or	ax,di
	or	ax,128
@2@142:
	jmp	short @2@310
@2@170:
	inc	di
@2@198:
	cmp	di,15
	jl	short @2@86
	inc	si
@2@254:
	cmp	si,7
	jl	short @2@58
   ;	
   ;			}
   ;		}
   ;		return(0);
   ;	
	xor	ax,ax
	jmp	short @2@142
@2@310:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_findkey	endp
   ;	
   ;	void markkey(int x,int y,int s,int k)
   ;	
	assume	cs:_TEXT
_markkey	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	si,word ptr [bp+4]
	mov	di,word ptr [bp+6]
   ;	
   ;	{
   ;		if (k==SPACE) {
   ;	
	cmp	word ptr [bp+10],32
	jne	short @3@198
   ;	
   ;			if (s==1) {
   ;	
	cmp	word ptr [bp+8],1
	jne	short @3@114
   ;	
   ;				prline(6+x*4,5+y*2,"ÜÜÜÜÜÜÜÜÜÜÜ");
   ;	
	mov	ax,offset DGROUP:s@
	jmp	short @3@142
@3@114:
   ;	
   ;			} else {
   ;				prline(6+x*4,5+y*2,"ÛÛÛÛÛÛÛÛÛÛÛ");
   ;	
	mov	ax,offset DGROUP:s@+12
@3@142:
	push	ax
	mov	ax,di
	shl	ax,1
	add	ax,5
	push	ax
	mov	ax,si
	mov	cl,2
	shl	ax,cl
	add	ax,6
	push	ax
	call	near ptr _prline
	add	sp,6
   ;	
   ;			}
   ;		} else if (k==CR) {
   ;	
	jmp	@3@478
@3@198:
	cmp	word ptr [bp+10],13
	je	@@0
	jmp	@3@366
@@0:
   ;	
   ;			if (s==1) {
   ;	
	cmp	word ptr [bp+8],1
	jne	short @3@282
   ;	
   ;				prline(10+x*4,3+y*2,"   ");
   ;	
	mov	ax,offset DGROUP:s@+24
	push	ax
	mov	ax,di
	shl	ax,1
	add	ax,3
	push	ax
	mov	ax,si
	mov	cl,2
	shl	ax,cl
	add	ax,10
	push	ax
	call	near ptr _prline
	add	sp,6
   ;	
   ;				prline(10+x*4,4+y*2,"ÜÜÜ");
   ;	
	mov	ax,offset DGROUP:s@+28
	push	ax
	mov	ax,di
	shl	ax,1
	add	ax,4
	push	ax
	mov	ax,si
	mov	cl,2
	shl	ax,cl
	add	ax,10
	push	ax
	call	near ptr _prline
	add	sp,6
   ;	
   ;				prline(10+x*4,5+y*2,"ÛÛÛ");
   ;	
	mov	ax,offset DGROUP:s@+32
	jmp	short @3@310
@3@282:
   ;	
   ;			} else {
   ;				prline(10+x*4,3+y*2,"ÛÛÛ");
   ;	
	mov	ax,offset DGROUP:s@+36
	push	ax
	mov	ax,di
	shl	ax,1
	add	ax,3
	push	ax
	mov	ax,si
	mov	cl,2
	shl	ax,cl
	add	ax,10
	push	ax
	call	near ptr _prline
	add	sp,6
   ;	
   ;				prline(10+x*4,4+y*2,"ÛÛÛ");
   ;	
	mov	ax,offset DGROUP:s@+40
	push	ax
	mov	ax,di
	shl	ax,1
	add	ax,4
	push	ax
	mov	ax,si
	mov	cl,2
	shl	ax,cl
	add	ax,10
	push	ax
	call	near ptr _prline
	add	sp,6
   ;	
   ;				prline(10+x*4,5+y*2,"ÛÛÛ");
   ;	
	mov	ax,offset DGROUP:s@+44
@3@310:
	push	ax
	mov	ax,di
	shl	ax,1
	add	ax,5
	push	ax
	mov	ax,si
	mov	cl,2
	shl	ax,cl
	add	ax,10
	push	ax
	call	near ptr _prline
	add	sp,6
   ;	
   ;			}
   ;		} else {
   ;	
	jmp	short @3@478
@3@366:
   ;	
   ;			if (s==1) {
   ;	
	cmp	word ptr [bp+8],1
	jne	short @3@422
   ;	
   ;				prline(10+x*4,5+y*2,"ÜÜÜ");
   ;	
	mov	ax,offset DGROUP:s@+48
	jmp	short @3@450
@3@422:
   ;	
   ;			} else {
   ;				prline(10+x*4,5+y*2,"ÛÛÛ");
   ;	
	mov	ax,offset DGROUP:s@+52
@3@450:
	push	ax
	mov	ax,di
	shl	ax,1
	add	ax,5
	push	ax
	mov	ax,si
	mov	cl,2
	shl	ax,cl
	add	ax,10
	push	ax
	call	near ptr _prline
	add	sp,6
@3@478:
   ;	
   ;			}
   ;		}
   ;	    G_keystat[y][x]=s;
   ;	
	mov	ax,di
	mov	dx,15
	imul	dx
	add	ax,si
	mov	dl,byte ptr [bp+8]
	mov	bx,ax
	mov	byte ptr DGROUP:_G_keystat[bx],dl
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_markkey	endp
   ;	
   ;	void interrupt mykeyb(void)
   ;	
	assume	cs:_TEXT
_mykeyb	proc	far
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	ds
	push	si
	push	di
	push	bp
	mov	bp,cs:DGROUP@
	mov	ds,bp
	mov	bp,sp
   ;	
   ;	{
   ;		asm {
   ;			CLI
   ;	
	CLI	
   ;	
   ;			MOV BX,OFFSET G_keybuf
   ;	
	MOV	 BX,OFFSET DGROUP:_G_keybuf
   ;	
   ;			ADD BX,G_kpend
   ;	
	ADD	 BX,DGROUP:_G_kpend
   ;	
   ;			MOV DX,0x60
   ;	
	MOV	 DX,060H
   ;	
   ;			IN  AL,DX
   ;	
	IN	  AL,DX
   ;	
   ;			MOV DS:[BX],AL
   ;	
	MOV	 DS:[BX],AL
   ;	
   ;			INC G_kpend
   ;	
	INC	 DGROUP:_G_kpend
   ;	
   ;			CMP G_kpend,ENDOFBUF
   ;	
	CMP	 DGROUP:_G_kpend,080H
   ;	
   ;			JLE	dontloop
   ;	
	jle	short @4@310
   ;	
   ;			MOV G_kpend,0
   ;	
	MOV	 DGROUP:_G_kpend,0
@4@310:
   ;	
   ;		}
   ;	dontloop:
   ;		asm {
   ;			MOV DX,0x61
   ;	
	MOV	 DX,061H
   ;	
   ;			IN  AL,DX
   ;	
	IN	  AL,DX
   ;	
   ;			OR  AL,0x80
   ;	
	OR	  AL,080H
   ;	
   ;			OUT DX,AL
   ;	
	OUT	 DX,AL
   ;	
   ;			AND AL,0x7F
   ;	
	AND	 AL,07FH
   ;	
   ;			OUT DX,AL
   ;	
	OUT	 DX,AL
   ;	
   ;			MOV DX,0x20
   ;	
	MOV	 DX,020H
   ;	
   ;			MOV AL,DL
   ;	
	MOV	 AL,DL
   ;	
   ;			OUT DX,AL
   ;	
	OUT	 DX,AL
   ;	
   ;			STI
   ;	
	STI	
   ;	
   ;		}
   ;	}
   ;	
	pop	bp
	pop	di
	pop	si
	pop	ds
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	iret	
_mykeyb	endp
   ;	
   ;	void far prockey(void)
   ;	
	assume	cs:_TEXT
_prockey	proc	far
	push	bp
	mov	bp,sp
	push	si
	push	di
   ;	
   ;	{
   ;		asm {
   ;			PUSH ES
   ;	
	PUSH	 ES
   ;	
   ;			PUSH DS
   ;	
	PUSH	 DS
   ;	
   ;			PUSH SI
   ;	
	PUSH	 SI
   ;	
   ;			PUSH DI
   ;	
	PUSH	 DI
   ;	
   ;			PUSH AX
   ;	
	PUSH	 AX
   ;	
   ;			PUSH BX
   ;	
	PUSH	 BX
   ;	
   ;			PUSH CX
   ;	
	PUSH	 CX
   ;	
   ;			PUSH DX
   ;	
	PUSH	 DX
   ;	
   ;			MOV BX,OFFSET G_keybuf
   ;	
	MOV	 BX,OFFSET DGROUP:_G_keybuf
   ;	
   ;			ADD BX,G_kpend
   ;	
	ADD	 BX,DGROUP:_G_kpend
   ;	
   ;			MOV CS:[BX],AL
   ;	
	MOV	 CS:[BX],AL
   ;	
   ;			INC G_kpend
   ;	
	INC	 DGROUP:_G_kpend
   ;	
   ;			CMP G_kpend,ENDOFBUF
   ;	
	CMP	 DGROUP:_G_kpend,080H
   ;	
   ;			JLE	dontloop
   ;	
	jle	short @5@450
   ;	
   ;			MOV G_kpend,0
   ;	
	MOV	 DGROUP:_G_kpend,0
@5@450:
   ;	
   ;		}
   ;	dontloop:
   ;		asm {
   ;			POP DX
   ;	
	POP	 DX
   ;	
   ;			POP CX
   ;	
	POP	 CX
   ;	
   ;			POP BX
   ;	
	POP	 BX
   ;	
   ;			POP AX
   ;	
	POP	 AX
   ;	
   ;			POP DI
   ;	
	POP	 DI
   ;	
   ;			POP SI
   ;	
	POP	 SI
   ;	
   ;			POP DS
   ;	
	POP	 DS
   ;	
   ;			POP ES
   ;	
	POP	 ES
   ;	
   ;			MOV AX,-1
   ;	
	MOV	 AX,-1
   ;	
   ;			MOV BX,AX
   ;	
	MOV	 BX,AX
   ;	
   ;			XOR DX,DX
   ;	
	XOR	 DX,DX
   ;	
   ;		}
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_prockey	endp
   ;	
   ;	int ismos (void)
   ;	
	assume	cs:_TEXT
_ismos	proc	near
	push	bp
	mov	bp,sp
	sub	sp,18
   ;	
   ;	{
   ;	    union REGS regs;
   ;	    int ax;
   ;	
   ;	    regs.x.dx=regs.x.cx=regs.x.bx=regs.x.ax=0x3000;
   ;	
	mov	ax,12288
	mov	word ptr [bp-18],ax
	mov	word ptr [bp-16],ax
	mov	word ptr [bp-14],ax
	mov	word ptr [bp-12],ax
   ;	
   ;	    intdos(&regs,&regs);
   ;	
	lea	ax,word ptr [bp-18]
	push	ax
	lea	ax,word ptr [bp-18]
	push	ax
	call	near ptr _intdos
	pop	cx
	pop	cx
   ;	
   ;	    ax=regs.x.ax;
   ;	
	mov	ax,word ptr [bp-18]
	mov	word ptr [bp-2],ax
   ;	
   ;	    regs.x.ax=0x30ff;             /* Make AX different */
   ;	
	mov	word ptr [bp-18],12543
   ;	
   ;	    intdos(&regs,&regs);
   ;	
	lea	ax,word ptr [bp-18]
	push	ax
	lea	ax,word ptr [bp-18]
	push	ax
	call	near ptr _intdos
	pop	cx
	pop	cx
   ;	
   ;	
   ;	    return(ax!=regs.x.ax);       /* If different, then MOS, else DOS */
   ;	
	mov	ax,word ptr [bp-2]
	cmp	ax,word ptr [bp-18]
	je	short @6@86
	mov	ax,1
	jmp	short @6@114
@6@86:
	xor	ax,ax
@6@114:
	jmp	short @6@142
@6@142:
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_ismos	endp
   ;	
   ;	int getscan(void)
   ;	
	assume	cs:_TEXT
_getscan	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
	push	di
   ;	
   ;	{
   ;		int k;
   ;		int kpress,mappos;
   ;	
   ;	    if (G_kpstart==G_kpend) return(0);
   ;	
	mov	ax,word ptr DGROUP:_G_kpstart
	cmp	ax,word ptr DGROUP:_G_kpend
	jne	short @7@114
@7@58:
	xor	ax,ax
@7@86:
	jmp	@7@618
@7@114:
   ;	
   ;	    k=G_keybuf[G_kpstart++];
   ;	
	mov	bx,word ptr DGROUP:_G_kpstart
	mov	al,byte ptr DGROUP:_G_keybuf[bx]
	mov	ah,0
	mov	word ptr [bp-2],ax
	inc	word ptr DGROUP:_G_kpstart
   ;	
   ;	    if (G_kpstart>ENDOFBUF) G_kpstart=0;
   ;	
	cmp	word ptr DGROUP:_G_kpstart,128
	jbe	short @7@170
	mov	word ptr DGROUP:_G_kpstart,0
@7@170:
   ;	
   ;	
   ;	    kpress=G_scanmap[((k&0x7F)*5)+0];
   ;	
	mov	ax,word ptr [bp-2]
	and	ax,127
	mov	dx,10
	imul	dx
	mov	bx,word ptr DGROUP:_G_scanmap
	add	bx,ax
	mov	di,word ptr [bx]
   ;	
   ;	    mappos=findkey((k&0x7F));
   ;	
	mov	ax,word ptr [bp-2]
	and	ax,127
	push	ax
	call	near ptr _findkey
	pop	cx
	mov	si,ax
   ;	
   ;	    if (k&0x80) {       // release code
   ;	
	test	word ptr [bp-2],128
	je	short @7@450
   ;	
   ;	        if ((kpress==CR)&&(!G_hadcrdn)) mappos=0;
   ;	
	cmp	di,13
	jne	short @7@282
	cmp	word ptr DGROUP:_G_hadcrdn,0
	jne	short @7@282
	xor	si,si
@7@282:
   ;	
   ;	        if (mappos) markkey(mappos&0x7F,mappos>>8,2,kpress);
   ;	
	or	si,si
	je	short @7@338
	push	di
	mov	ax,2
	push	ax
	mov	ax,si
	mov	cl,8
	sar	ax,cl
	push	ax
	mov	ax,si
	and	ax,127
	push	ax
	call	near ptr _markkey
	add	sp,8
@7@338:
   ;	
   ;	        if ((kpress==CR)&&(G_hadcrdn)) return(1);
   ;	
	cmp	di,13
	jne	short @7@422
	cmp	word ptr DGROUP:_G_hadcrdn,0
	je	short @7@422
	mov	ax,1
	jmp	@7@86
@7@422:
   ;	
   ;	    }
   ;	
	jmp	short @7@590
@7@450:
   ;	
   ;	    else {                  // press code
   ;	        if (mappos) markkey(mappos&0x7F,mappos>>8,1,kpress);
   ;	
	or	si,si
	je	short @7@506
	push	di
	mov	ax,1
	push	ax
	mov	ax,si
	mov	cl,8
	sar	ax,cl
	push	ax
	mov	ax,si
	and	ax,127
	push	ax
	call	near ptr _markkey
	add	sp,8
@7@506:
   ;	
   ;	        if (kpress==CR) G_hadcrdn=1;
   ;	
	cmp	di,13
	jne	short @7@562
	mov	word ptr DGROUP:_G_hadcrdn,1
@7@562:
   ;	
   ;	        G_keypress=1;
   ;	
	mov	word ptr DGROUP:_G_keypress,1
@7@590:
	jmp	@7@58
@7@618:
   ;	
   ;	    }
   ;		return(0);
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_getscan	endp
   ;	
   ;	int kbd_startup(void)
   ;	
	assume	cs:_TEXT
_kbd_startup	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		if (!ismos()) {
   ;	
	call	near ptr _ismos
	or	ax,ax
	jne	short @8@86
   ;	
   ;		    oldkeyb=getvect(0x09);
   ;	
	mov	ax,9
	push	ax
	call	near ptr _getvect
	pop	cx
	mov	word ptr DGROUP:_oldkeyb+2,dx
	mov	word ptr DGROUP:_oldkeyb,ax
   ;	
   ;		    setvect(0x09,mykeyb);
   ;	
	mov	ax,seg _mykeyb
	push	ax
	mov	ax,offset _mykeyb
	push	ax
	mov	ax,9
	push	ax
	call	near ptr _setvect
	add	sp,6
   ;	
   ;		} else {
   ;	
	jmp	short @8@310
@8@86:
   ;	
   ;			asm mov ah,2
   ;	
 	mov	 ah,2
   ;	
   ;			asm int 0xD4
   ;	
 	int	 0D4H
   ;	
   ;			asm mov AX,word ptr es:[bx+0x02b2]
   ;	
 	mov	 AX,word ptr es:[bx+002b2H]
   ;	
   ;			asm mov G_ofs,AX
   ;	
 	mov	 DGROUP:_G_ofs,AX
   ;	
   ;			asm mov AX,word ptr es:[bx+0x02b4]
   ;	
 	mov	 AX,word ptr es:[bx+002b4H]
   ;	
   ;			asm mov G_seg,AX
   ;	
 	mov	 DGROUP:_G_seg,AX
   ;	
   ;			asm mov word ptr es:[bx+0x02b2],offset prockey
   ;	
 	mov	 word ptr es:[bx+002b2H],offset _prockey
   ;	
   ;			asm mov word ptr es:[bx+0x02b4],cs
   ;	
 	mov	 word ptr es:[bx+002b4H],cs
@8@310:
   ;	
   ;		}
   ;	    G_scanmap=scanmap;
   ;	
	mov	word ptr DGROUP:_G_scanmap,offset DGROUP:_scanmap
   ;	
   ;	    return(1);
   ;	
	mov	ax,1
	jmp	short @8@338
@8@338:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_kbd_startup	endp
   ;	
   ;	int kbd_shutdown(void)
   ;	
	assume	cs:_TEXT
_kbd_shutdown	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		if (!ismos()) {
   ;	
	call	near ptr _ismos
	or	ax,ax
	jne	short @9@86
   ;	
   ;		    setvect(0x09,oldkeyb);
   ;	
	push	word ptr DGROUP:_oldkeyb+2
	push	word ptr DGROUP:_oldkeyb
	mov	ax,9
	push	ax
	call	near ptr _setvect
	add	sp,6
   ;	
   ;		} else {
   ;	
	jmp	short @9@254
@9@86:
   ;	
   ;			asm mov ah,2
   ;	
 	mov	 ah,2
   ;	
   ;			asm int 0xD4
   ;	
 	int	 0D4H
   ;	
   ;			asm mov AX,G_ofs
   ;	
 	mov	 AX,DGROUP:_G_ofs
   ;	
   ;			asm mov word ptr es:[bx+0x02b2],AX
   ;	
 	mov	 word ptr es:[bx+002b2H],AX
   ;	
   ;			asm mov AX,G_seg
   ;	
 	mov	 AX,DGROUP:_G_seg
   ;	
   ;			asm mov word ptr es:[bx+0x02b4],AX
   ;	
 	mov	 word ptr es:[bx+002b4H],AX
@9@254:
   ;	
   ;		}
   ;	    return(1);
   ;	
	mov	ax,1
	jmp	short @9@282
@9@282:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_kbd_shutdown	endp
   ;	
   ;	void displaykbd(void)
   ;	
	assume	cs:_TEXT
_displaykbd	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
   ;	
   ;	{
   ;	    int i,j;
   ;	    char tmp[20];
   ;	    prline(8,4,G_tl);
   ;	
	mov	ax,offset DGROUP:_G_tl
	push	ax
	mov	ax,4
	push	ax
	mov	ax,8
	push	ax
	call	near ptr _prline
	add	sp,6
   ;	
   ;	    G_m1[1]='1';
   ;	
	mov	byte ptr DGROUP:_G_m1+1,49
   ;	
   ;	    prline(8,5,G_m1);
   ;	
	mov	ax,offset DGROUP:_G_m1
	push	ax
	mov	ax,5
	push	ax
	mov	ax,8
	push	ax
	call	near ptr _prline
	add	sp,6
   ;	
   ;	    for (i=0;i<6;i++) {
   ;	
	mov	word ptr [bp-2],0
	jmp	short @10@114
@10@58:
   ;	
   ;	        prline(8,6+i*2,G_m2);
   ;	
	mov	ax,offset DGROUP:_G_m2
	push	ax
	mov	ax,word ptr [bp-2]
	shl	ax,1
	add	ax,6
	push	ax
	mov	ax,8
	push	ax
	call	near ptr _prline
	add	sp,6
   ;	
   ;	        G_m1[1]='2'+i;
   ;	
	mov	al,byte ptr [bp-2]
	add	al,50
	mov	byte ptr DGROUP:_G_m1+1,al
   ;	
   ;	        prline(8,7+i*2,G_m1);
   ;	
	mov	ax,offset DGROUP:_G_m1
	push	ax
	mov	ax,word ptr [bp-2]
	shl	ax,1
	add	ax,7
	push	ax
	mov	ax,8
	push	ax
	call	near ptr _prline
	add	sp,6
	inc	word ptr [bp-2]
@10@114:
	cmp	word ptr [bp-2],6
	jl	short @10@58
   ;	
   ;	    }
   ;	    prline(8,6+i*2,G_bl);
   ;	
	mov	ax,offset DGROUP:_G_bl
	push	ax
	mov	ax,word ptr [bp-2]
	shl	ax,1
	add	ax,6
	push	ax
	mov	ax,8
	push	ax
	call	near ptr _prline
	add	sp,6
   ;	
   ;	    prline(25,4+i*2,"ÊÍÍÍÊ");
   ;	
	mov	ax,offset DGROUP:s@+56
	push	ax
	mov	ax,word ptr [bp-2]
	shl	ax,1
	add	ax,4
	push	ax
	mov	ax,25
	push	ax
	call	near ptr _prline
	add	sp,6
   ;	
   ;	    prline(25,5+i*2,"     ");
   ;	
	mov	ax,offset DGROUP:s@+62
	push	ax
	mov	ax,word ptr [bp-2]
	shl	ax,1
	add	ax,5
	push	ax
	mov	ax,25
	push	ax
	call	near ptr _prline
	add	sp,6
   ;	
   ;	    prline(25,6+i*2,"ÍÍÍÍÍ");
   ;	
	mov	ax,offset DGROUP:s@+68
	push	ax
	mov	ax,word ptr [bp-2]
	shl	ax,1
	add	ax,6
	push	ax
	mov	ax,25
	push	ax
	call	near ptr _prline
	add	sp,6
   ;	
   ;	    prline(65,4+i*2,"¹   º");
   ;	
	mov	ax,offset DGROUP:s@+74
	push	ax
	mov	ax,word ptr [bp-2]
	shl	ax,1
	add	ax,4
	push	ax
	mov	ax,65
	push	ax
	call	near ptr _prline
	add	sp,6
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_displaykbd	endp
   ;	
   ;	int main(int argc)
   ;	
	assume	cs:_TEXT
_main	proc	near
	push	bp
	mov	bp,sp
	sub	sp,12
	push	si
	push	di
   ;	
   ;	{
   ;	    int i,j,err=0;
   ;	
	mov	word ptr [bp-4],0
   ;	
   ;	    FILE *fp;
   ;	    time_t stop,start;
   ;	
   ;	    if (argc<2) Location=PC; else Location=CT;
   ;	
	cmp	word ptr [bp+4],2
	jge	short @11@86
	mov	word ptr DGROUP:_Location,0
	jmp	short @11@114
@11@86:
	mov	word ptr DGROUP:_Location,1
@11@114:
   ;	
   ;	    memset(G_keystat,0,sizeof(G_keystat));
   ;	
	mov	ax,105
	push	ax
	xor	ax,ax
	push	ax
	mov	ax,offset DGROUP:_G_keystat
	push	ax
	call	near ptr _memset
	add	sp,6
   ;	
   ;	    G_keystat[6][3]=2;
   ;	
	mov	byte ptr DGROUP:_G_keystat+93,2
   ;	
   ;	    G_keystat[6][5]=2;
   ;	
	mov	byte ptr DGROUP:_G_keystat+95,2
   ;	
   ;	    G_keystat[5][14]=2;
   ;	
	mov	byte ptr DGROUP:_G_keystat+89,2
   ;	
   ;	    kbd_startup();
   ;	
	call	near ptr _kbd_startup
   ;	
   ;	    displaykbd();
   ;	
	call	near ptr _displaykbd
   ;	
   ;	    time(&start);
   ;	
	lea	ax,word ptr [bp-12]
	push	ax
	call	near ptr _time
	pop	cx
	jmp	short @11@310
@11@142:
   ;	
   ;	    while ((!getscan())&&(!err)) {
   ;	        time(&stop);
   ;	
	lea	ax,word ptr [bp-8]
	push	ax
	call	near ptr _time
	pop	cx
   ;	
   ;	        if ((stop-start)>=20) err=1;
   ;	
	mov	ax,word ptr [bp-6]
	mov	dx,word ptr [bp-8]
	sub	dx,word ptr [bp-12]
	sbb	ax,word ptr [bp-10]
	or	ax,ax
	jl	short @11@254
	jne	short @11@226
	cmp	dx,20
	jb	short @11@254
@11@226:
	mov	word ptr [bp-4],1
@11@254:
   ;	
   ;	        if (G_keypress) {
   ;	
	cmp	word ptr DGROUP:_G_keypress,0
	je	short @11@310
   ;	
   ;	            G_keypress=0;
   ;	
	mov	word ptr DGROUP:_G_keypress,0
   ;	
   ;	            time(&start);
   ;	
	lea	ax,word ptr [bp-12]
	push	ax
	call	near ptr _time
	pop	cx
@11@310:
	call	near ptr _getscan
	or	ax,ax
	jne	short @11@366
	cmp	word ptr [bp-4],0
	je	short @11@142
@11@366:
   ;	
   ;	        }
   ;	    }
   ;	    kbd_shutdown();
   ;	
	call	near ptr _kbd_shutdown
   ;	
   ;	    unlink("KBDERR.LOG");
   ;	
	mov	ax,offset DGROUP:s@+80
	push	ax
	call	near ptr _unlink
	pop	cx
   ;	
   ;	    fp=fopen("KBDERR.LOG","w");
   ;	
	mov	ax,offset DGROUP:s@+102
	push	ax
	mov	ax,offset DGROUP:s@+91
	push	ax
	call	near ptr _fopen
	pop	cx
	pop	cx
	mov	si,ax
   ;	
   ;	    if (fp==NULL) return(0);
   ;	
	or	si,si
	jne	short @11@450
	xor	ax,ax
@11@422:
	jmp	@11@954
@11@450:
   ;	
   ;	    if (err) {
   ;	
	cmp	word ptr [bp-4],0
	je	short @11@506
   ;	
   ;	        fprintf(fp,"Skipped\n");
   ;	
	mov	ax,offset DGROUP:s@+104
	push	ax
	push	si
	call	near ptr _fprintf
	pop	cx
	pop	cx
	jmp	short @11@926
@11@506:
   ;	
   ;	        fclose(fp);
   ;	        return(1);
   ;	    }
   ;	    for (i=0;i<7;i++) {
   ;	
	xor	di,di
	jmp	short @11@842
@11@534:
   ;	
   ;	        for (j=0;j<15;j++) {
   ;	
	mov	word ptr [bp-2],0
	jmp	short @11@786
@11@562:
   ;	
   ;	            switch (G_keystat[i][j]) {
   ;	
	mov	ax,di
	mov	dx,15
	imul	dx
	add	ax,word ptr [bp-2]
	mov	bx,ax
	mov	al,byte ptr DGROUP:_G_keystat[bx]
	mov	ah,0
	or	ax,ax
	je	short @11@674
	cmp	ax,1
	je	short @11@730
	jmp	short @11@758
@11@674:
   ;	
   ;	                case 0 :
   ;	                    fprintf(fp,"Error KEY [%c%c]\n",'1'+i,'A'+j);
   ;	
	mov	ax,word ptr [bp-2]
	add	ax,65
	push	ax
	mov	ax,di
	add	ax,49
	push	ax
	mov	ax,offset DGROUP:s@+113
@11@702:
	push	ax
	push	si
	call	near ptr _fprintf
	add	sp,8
   ;	
   ;	                    err=1;
   ;	
	mov	word ptr [bp-4],1
   ;	
   ;	                    break;
   ;	
	jmp	short @11@758
@11@730:
   ;	
   ;	                case 1 :
   ;	                    fprintf(fp,"Error KEY [%c%c] Stuck\n",'1'+i,'A'+j);
   ;	
	mov	ax,word ptr [bp-2]
	add	ax,65
	push	ax
	mov	ax,di
	add	ax,49
	push	ax
	mov	ax,offset DGROUP:s@+131
	jmp	short @11@702
@11@758:
	inc	word ptr [bp-2]
@11@786:
	cmp	word ptr [bp-2],15
	jl	short @11@562
	inc	di
@11@842:
	cmp	di,7
	jl	short @11@534
   ;	
   ;	                    err=1;
   ;	                    break;
   ;	            }
   ;	        }
   ;	    }
   ;	    if (!err) fprintf(fp,"Passed\n");
   ;	
	cmp	word ptr [bp-4],0
	jne	short @11@926
	mov	ax,offset DGROUP:s@+155
	push	ax
	push	si
	call	near ptr _fprintf
	pop	cx
	pop	cx
@11@926:
   ;	
   ;	    fclose(fp);
   ;	
	push	si
	call	near ptr _fclose
	pop	cx
   ;	
   ;	    return(1);
   ;	
	mov	ax,1
	jmp	@11@422
@11@954:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_main	endp
_TEXT	ends
_BSS	segment word public 'BSS'
_G_keystat	label	byte
	db	105 dup (?)
_G_seg	label	word
	db	2 dup (?)
_G_ofs	label	word
	db	2 dup (?)
_Location	label	word
	db	2 dup (?)
_G_scanmap	label	word
	db	2 dup (?)
_G_keybuf	label	byte
	db	129 dup (?)
_oldkeyb	label	dword
	db	4 dup (?)
	?debug	C E9
	?debug	C FA00000000
_BSS	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	-36
	db	-36
	db	-36
	db	-36
	db	-36
	db	-36
	db	-36
	db	-36
	db	-36
	db	-36
	db	-36
	db	0
	db	-37
	db	-37
	db	-37
	db	-37
	db	-37
	db	-37
	db	-37
	db	-37
	db	-37
	db	-37
	db	-37
	db	0
	db	'   '
	db	0
	db	-36
	db	-36
	db	-36
	db	0
	db	-37
	db	-37
	db	-37
	db	0
	db	-37
	db	-37
	db	-37
	db	0
	db	-37
	db	-37
	db	-37
	db	0
	db	-37
	db	-37
	db	-37
	db	0
	db	-36
	db	-36
	db	-36
	db	0
	db	-37
	db	-37
	db	-37
	db	0
	db	-54
	db	-51
	db	-51
	db	-51
	db	-54
	db	0
	db	'     '
	db	0
	db	-51
	db	-51
	db	-51
	db	-51
	db	-51
	db	0
	db	-71
	db	'   '
	db	-70
	db	0
	db	'KBDERR.LOG'
	db	0
	db	'KBDERR.LOG'
	db	0
	db	'w'
	db	0
	db	'Skipped'
	db	10
	db	0
	db	'Error KEY [%c%c]'
	db	10
	db	0
	db	'Error KEY [%c%c] Stuck'
	db	10
	db	0
	db	'Passed'
	db	10
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
	extrn	DGROUP@:word
_TEXT	ends
	extrn	__setargv__:far
	public	_main
	public	_displaykbd
	public	_kbd_shutdown
	public	_kbd_startup
	public	_getscan
	public	_ismos
	public	_prockey
	public	_mykeyb
	public	_markkey
	public	_findkey
	public	_prline
	public	_G_keystat
	public	_G_scanpos
	public	_G_scanlyt
	public	_G_bl
	public	_G_m2
	public	_G_m1
	public	_G_tl
	public	_G_seg
	public	_G_ofs
	public	_G_hadcrdn
	public	_Location
	public	_G_scanmap
	public	_G_keypress
	public	_G_kpend
	public	_G_kpstart
	public	_G_keybuf
	public	_G_extnext
	public	_G_shiftstat
	public	_oldkeyb
	public	_scanmap
	extrn	_setvect:near
	extrn	_getvect:near
	extrn	_intdos:near
	extrn	_memset:near
	extrn	_time:near
	extrn	_unlink:near
	extrn	_fprintf:near
	extrn	_fopen:near
	extrn	_fclose:near
_s@	equ	s@
	end
