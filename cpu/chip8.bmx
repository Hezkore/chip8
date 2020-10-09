SuperStrict

Import "base.bmx"

New TCHIP8CPU
Type TCHIP8CPU Extends TBaseCPU
	
	Method New()
		' Register Self
		Self.RegisterAsCPU("CHIP-8")
		
		' Setup
		Self.Speed = 10 ' 10 instructions
		
		' Register opcodes
		Self.RegisterOpcode($0, "SYS addr", OP_SYS)
		Self.RegisterOpcode($00E0, "CLS", OP_CLS)
		Self.RegisterOpcode($00EE, "RET", OP_RET)
	EndMethod
	
	Function OP_SYS(opcode:Int)
		Print "SYS addr"
	EndFunction
	
	Function OP_CLS(opcode:Int)
		Print "CLEARING!"
	EndFunction
	
	Function OP_RET(opcode:Int)
		Print "RETUIRNTNIG!"
	EndFunction
EndType