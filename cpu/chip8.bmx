SuperStrict

Import "base.bmx"

New TCHIP8CPU
Type TCHIP8CPU Extends TBaseCPU
	
	Method New()
		' Register Self
		Self.RegisterAsCPU("CHIP-8")
		
		' Setup
		Self.Speed = 10 ' 10 instructions
		Self.ProgressOnInstruction  = True ' Auto progress forward after every instruction
		
		' Register opcodes
		' First is operational instruction code
		' Second is the match pattern where, for example, $F0F0 means that the first and third value must be exact
		' Third is the function to call for this opcode
		' Forth is the pseudo code name (used for debugging)
		'Self.RegisterOpcode($0000,	$F000,	OP_SYS,		"SYS")
		'Self.RegisterOpcode($00E0,	$FFFF,	OP_CLS,		"CLS")
		'Self.RegisterOpcode($00EE,	$FFFF,	OP_RET,		"RET")
		'Self.RegisterOpcode($1000,	$F000,	OP_JP,		"JP")
		'Self.RegisterOpcode($2000,	$F000,	OP_CALL,	"CALL")
		'Self.RegisterOpcode($4000,	$F000,	OP_SNE,		"SNE")
		'Self.RegisterOpcode($7000,	$F000,	OP_ADDVx,	"ADD Vx")
		'Self.RegisterOpcode($8000,	$F00F,	OP_LDVxVy,	"LD Vx, Vy")
		'Self.RegisterOpcode($A000,	$F000,	OP_LD,		"LD")
		'Self.RegisterOpcode($F065,	$F0FF,	OP_LDVxI,	"LD Vx, [I]")
		
0nnn - SYS addr
Jump to a machine code routine at nnn.

00E0 - CLS
Clear the display.

00EE - RET
Return from a subroutine.

1nnn - JP addr
Jump to location nnn.

2nnn - CALL addr
Call subroutine at nnn.

3xkk - SE Vx, byte
Skip next instruction if Vx = kk.

4xkk - SNE Vx, byte
Skip next instruction if Vx != kk.

5xy0 - SE Vx, Vy
Skip next instruction if Vx = Vy.

6xkk - LD Vx, byte
Set Vx = kk.

7xkk - ADD Vx, byte
Set Vx = Vx + kk.

8xy0 - LD Vx, Vy
Set Vx = Vy.

8xy1 - OR Vx, Vy
Set Vx = Vx OR Vy.

8xy2 - AND Vx, Vy
Set Vx = Vx AND Vy.

8xy3 - XOR Vx, Vy
Set Vx = Vx XOR Vy.

8xy4 - ADD Vx, Vy
Set Vx = Vx + Vy, set VF = carry.

8xy5 - SUB Vx, Vy
Set Vx = Vx - Vy, set VF = NOT borrow.

8xy6 - SHR Vx {, Vy}
Set Vx = Vx SHR 1.

8xy7 - SUBN Vx, Vy
Set Vx = Vy - Vx, set VF = NOT borrow.

8xyE - SHL Vx {, Vy}
Set Vx = Vx SHL 1.

9xy0 - SNE Vx, Vy
Skip next instruction if Vx != Vy.

Annn - LD I, addr
Set I = nnn.

Bnnn - JP V0, addr
Jump to location nnn + V0.

Cxkk - RND Vx, byte
Set Vx = random byte AND kk.

Dxyn - DRW Vx, Vy, nibble
Display n-byte sprite starting at memory location I at (Vx, Vy), set VF = collision.

Ex9E - SKP Vx
Skip next instruction if key with the value of Vx is pressed.

ExA1 - SKNP Vx
Skip next instruction if key with the value of Vx is not pressed.

Fx07 - LD Vx, DT
Set Vx = delay timer value.

Fx0A - LD Vx, K
Wait for a key press, store the value of the key in Vx.

Fx15 - LD DT, Vx
Set delay timer = Vx.

Fx18 - LD ST, Vx
Set sound timer = Vx.

Fx1E - ADD I, Vx
Set I = I + Vx.

Fx29 - LD F, Vx
Set I = location of sprite for digit Vx.

Fx33 - LD B, Vx
Store BCD representation of Vx in memory locations I, I+1, and I+2.

Fx55 - LD [I], Vx
Store registers V0 through Vx in memory starting at location I.

The interpreter copies the values of registers V0 through Vx into memory, starting at the address in I.

Fx65 - LD Vx, [I]
Read registers V0 through Vx from memory starting at location I.

The interpreter reads values from memory starting at location I into registers V0 through Vx.
	EndMethod
	
	Function OP_SYS(opcode:Int, cpu:TBaseCPU)
		Print "SYS 0x" + Right(Hex(opcode), 4)
	EndFunction
	
	Function OP_CLS(opcode:Int, cpu:TBaseCPU)
		Print "CLEARING!"
	EndFunction
	
	Function OP_RET(opcode:Int, cpu:TBaseCPU)
		cpu.ProgramCounter = cpu.MemoryPtr.Stack.Pop()
	EndFunction
	
	Function OP_JP(opcode:Int, cpu:TBaseCPU)
		cpu.ProgramCounter = opcode & $FFF
	EndFunction
	
	Function OP_CALL(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.Stack.Push(cpu.ProgramCounter)
		cpu.ProgramCounter = opcode & $FFF
	EndFunction
	
	Function OP_SNE(opcode:Int, cpu:TBaseCPU)
		If cpu.MemoryPtr.V[Self.GetX(opcode)] <> opcode & $FF cpu.ProgressProgramCounter()
	EndFunction
	
	Function OP_LD(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.I = opcode & $FFF
	EndFunction
	
	Function OP_ADDVx(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[cpu.GetX(opcode)]:+opcode & $FF
	EndFunction
	
	Function OP_LDVxI(opcode:Int, cpu:TBaseCPU)
		For Local index:Int = 0 To cpu.GetX(opcode)
			cpu.MemoryPtr.V[index] = cpu.MemoryPtr.Memory[cpu.MemoryPtr.I + index]
		Next
	EndFunction
	
	Function OP_LDVxVy(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[cpu.GetX(opcode)] = cpu.MemoryPtr.V[cpu.GetY(opcode)]
	EndFunction
EndType