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
		Self.RegisterOpcode("0",	OP_SYS,		"SYS")
		Self.RegisterOpcode("00E0",	OP_CLS,		"CLS")
		Self.RegisterOpcode("00EE",	OP_RET,		"RET")
		Self.RegisterOpcode("1",	OP_JP,		"JP")
		Self.RegisterOpcode("2",	OP_CALL,	"CALL")
		Self.RegisterOpcode("4",	OP_SNE,		"SNE")
		Self.RegisterOpcode("A",	OP_LD,		"LD")
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
EndType