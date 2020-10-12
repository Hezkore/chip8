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
		Self.RegisterOpcode($0000,	$F000,	OP_SYS,		"SYS")
		Self.RegisterOpcode($00E0,	$FFFF,	OP_CLS,		"CLS")
		Self.RegisterOpcode($00EE,	$FFFF,	OP_RET,		"RET")
		Self.RegisterOpcode($1000,	$F000,	OP_JP,		"JP")
		Self.RegisterOpcode($2000,	$F000,	OP_CALL,	"CALL")
		Self.RegisterOpcode($4000,	$F000,	OP_SNE,		"SNE")
		Self.RegisterOpcode($7000,	$F000,	OP_ADDVx,	"ADD Vx")
		Self.RegisterOpcode($8000,	$F00F,	OP_LDVxVy,	"LD Vx, Vy")
		Self.RegisterOpcode($A000,	$F000,	OP_LD,		"LD")
		Self.RegisterOpcode($F065,	$F0FF,	OP_LDVxI,	"LD Vx, [I]")
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