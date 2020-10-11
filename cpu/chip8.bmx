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
		Self.RegisterOpcode("0", "SYS addr", OP_SYS)
		Self.RegisterOpcode("00E0", "CLS", OP_CLS)
		Self.RegisterOpcode("00EE", "RET", OP_RET)
		Self.RegisterOpcode("1", "JP", OP_JP)
	EndMethod
	
	Function OP_SYS(opcode:Int)
		Print "SYS addr " + opcode
	EndFunction
	
	Function OP_CLS(opcode:Int)
		Print "CLEARING!"
	EndFunction
	
	Function OP_RET(opcode:Int)
		Self.ProgramCounter = Self.Stack.Pop()
	EndFunction
	
	Function OP_JP(opcode:Int)
		Self.ProgramCounter = opcode & $FFF
	EndFunction
EndType