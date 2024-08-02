[M2_ArrayPointer]: 0x807F6000
[M2_ArrayCount]: 0x807F6004
[CurrentMap]: 0x8076A0A8
[GetWorld]: 0x805FF030 // params a0 = currentMap, a1 = 0, Output = v0
[Gamemode]: 0x80755314
[ReturnStorage]: 0x807FFFF0
// Kong pad > behaviour pointer (0x7c) + 0x64 (u32) = 0 for both kong pads

// .org 0x8064D918
// J 	Hook64D918
// NOP

.org 0x805FC164 // retroben's hook but up a few functions
J 	EveryFrame

// .org 0x8064DA1C
// J 	Hook64DA1C
// NOP

// .org 0x8066DFF4
// J 	Hook66DFF4
// NOP

// .org 0x806BE240
// J 	Hook6BE240
// NOP

// .org 0x80667B18
// J 	Hook667B18
// NOP

// .org 0x80667B38
// J 	Hook667B38
// NOP

// .org 0x80667BC4
// J 	Hook667BC4
// NOP

// .org 0x80667BDC
// J 	Hook667BDC
// NOP

.org 0x80000A30 // 0x000A30 > 0x0010BC

Hook64D918:
	// Spare vars
		// $a1 = 1
		// $at = 0x3F80 0000
	LUI 		a1, 0xFFC0
	MFC1 		at, f0
	BEQ 		a1, at, Finish64D918
	NOP
	CVT.D.S 	f8, f0

	Finish64D918:
		ADDIU 	a1, r0, 1
		LUI 	at, 0x3F80
		J 		0x8064D920
		NOP

EveryFrame:
	JAL     0x805FC2B0
	NOP
	InsertKREHook:
		LBU 	a0, @Gamemode
		SLTIU 	a1, a0, 5
		BNEZ 	a1, FixSpiking
		NOP
		LI 		a0, 0x0800028C
		SW 		a0, 0x8064D918
		SW 		r0, 0x8064D91C

	FixSpiking:
		LW 		a0, @CurrentMap
		LI 		a1, 0x2A
		BNE 	a0, a1, FinishSpikeFix
		NOP
		SW 		ra, @ReturnStorage
		JAL 	@GetWorld
		ADDIU 	a1, r0, 1
		LW 		ra, @ReturnStorage
		ORI 	a0, v0, 0
		LI 		a1, 7
		BNE 	a0, a1, FinishSpikeFix
		NOP
		LW 		a0, @M2_ArrayPointer
		BEQZ 	a0, FinishSpikeFix
		NOP
		LW 		a1, @M2_ArrayCount
		BEQZ 	a1, FinishSpikeFix
		NOP

	SpikeLoop:
		LHU 	a2, 0x84(a0)
		LI 		a3, 0x12B
		BNE 	a2, a3, ToNext
		NOP
		LW 		a2, 0x7C(a0)
		BEQZ 	a2, ToNext
		NOP
		SW 		r0, 0x64(a2)

	ToNext:
		ADDI 	a1, a1, -1
		BEQZ 	a1, FinishSpikeFix
		NOP
		ADDIU 	a0, a0, 0x90
		B 		SpikeLoop
		NOP

	FinishSpikeFix:
		J       0x805FC15C // retroben's hook but up a few functions
		NOP

// Hook64DA1C:
// 	// Spare vars
// 		// $a1 = 1
// 		// $at = 0x3F80 0000
// 	LUI 		a1, 0xFFC0
// 	MFC1 		at, f0
// 	BEQ 		a1, at, Finish64D918
// 	NOP
// 	CVT.D.S 	f8, f0

// 	Finish64DA1C:
// 		ADDIU 	t9, sp, 0x2f
// 		ADDIU 	a1, r0, 1
// 		LUI 	at, 0x3F80
// 		J 		0x8064DA24
// 		NOP

// Hook66DFF4:
// 	// Spare vars
// 		// $v0
// 	MFC1 		v0, f0 // Transfers errored float to v0
// 	SRL 		v0, v0, 16 // Gets upper 16 bits of errored float into lower 16 bit slot
// 	ADDIU 		v0, v0, 0x40 // Add 0x40. If this is 0xFFC0 (errored float), this will change to 0x1 0000
// 	ANDI 		v0, v0, 0xFFFF // Get lower 16 bits of error
// 	BEQZ 		v0, Finish66DFF4
// 	NOP
// 	CVT.D.S 	f6, f0

// 	Finish66DFF4:
// 		SWC1 	f0, 0x20(s0)
// 		J 		0x8066DFFC
// 		NOP

// Hook6BE240:
// 	// Spare vars
// 		// $at = 0x3F80 0000
// 		// $a0
// 	LUI 		a0, 0xFFC0
// 	MFC1 		at, f0
// 	BEQ 		a0, at, Finish6BE240
// 	NOP
// 	MFC1 		at, f10
// 	BEQ 		a0, at, Finish6BE240
// 	NOP
// 	C.LT.S 		f0, f10

// 	Finish6BE240:
// 		LUI 	at, 0x3F80
// 		J 		0x806BE248
// 		NOP

// Hook667B18:
// 	// Spare vars
// 		// $at = 0x4F80 0000
// 		// $t4 = 0x8077 0000
// 	LUI 		t4, 0xFFC0
// 	MFC1 		at, f4
// 	BEQ 		t4, at, Finish667B18
// 	NOP
// 	MFC1 		at, f6
// 	BEQ 		t4, at, Finish667B18
// 	NOP
// 	C.LE.S 		f4, f6

// 	Finish667B18:
// 		LUI 	at, 0x4F80
// 		LUI 	t4, 0x8077
// 		J 		0x80667B20
// 		NOP

// Hook667B38:
// 	// Spare vars
// 		// $t5 = 0x8080 0000
// 		// $t4 = 0x8077 0000
// 	LUI 		t4, 0xFFF8
// 	MFC1 		t5, f9
// 	BNE 		t4, t5, CheckOther667B38
// 	NOP
// 	MFC1 		t5, f8
// 	BEQZ 		t5, Finish667B38
// 	NOP
// 	B 			RunInstruction667B38
// 	NOP

// 	CheckOther667B38:
// 		LUI 	t4, 0xFFF8
// 		MFC1 	t5, f1
// 		BNE 	t4, t5, RunInstruction667B38
// 		NOP
// 		MFC1 	t5, f0
// 		BEQZ 	t5, Finish667B38
// 		NOP

// 	RunInstruction667B38:
// 		C.LT.D 	f8, f0

// 	Finish667B38:
// 		LUI 	t5, 0x8080
// 		LUI 	t4, 0x8077
// 		J 		0x80667B40
// 		NOP

// Hook667BC4:
// 	// Spare vars
// 		// $at = 0x4F80 0000
// 		// $t6 = 0x8077 0000
// 	LUI 	t6, 0xFFC0
// 	MFC1 	at, f4
// 	BEQ 	at, t6, Finish667BC4
// 	NOP
// 	MFC1 	at, f8
// 	BEQ 	at, t6, Finish667BC4
// 	NOP
// 	C.LE.S 	f4, f8

// 	Finish667BC4:
// 		LUI 	t6, 0x8077
// 		LUI 	at, 0x4F80
// 		J 		0x80667BCC
// 		NOP

// Hook667BDC:
// 	// Spare vars
// 		// $at = 0x4F80 0000
// 		// $t6 = 0x8077 0000
// 	LUI 	t6, 0xFFC0
// 	MFC1 	at, f4
// 	BEQ 	at, t6, Finish667BDC
// 	NOP
// 	MFC1 	at, f8
// 	BEQ 	at, t6, Finish667BDC
// 	NOP
// 	C.LE.S 	f4, f8

// 	Finish667BDC:
// 		LUI 	t6, 0x8077
// 		LUI 	at, 0x4F80
// 		J 		0x80667BE4
// 		NOP