SuperStrict

Import "base.bmx"

New TCHIP8CPU
Type TCHIP8CPU Extends TBaseCPU
	
	Method New()
		' Register Self
		Self.RegisterAsCPU("CHIP-8")
		
		' Setup
		Self.Speed = 10 ' Instructions per cycle
		Self.ProgressOnInstruction  = True ' Auto progress forward after every instruction
		
		' Register opcodes
		Self.RegisterOpcode($0000, $F000, OP_SYSa,		"SYS addr",			"Jump to a machine code routine at nnn")
		Self.RegisterOpcode($00E0, $FFFF, OP_CLS,		"CLS",				"Clear the display")
		Self.RegisterOpcode($00EE, $FFFF, OP_RET,		"RET",				"Return from a subroutine")
		Self.RegisterOpcode($1000, $F000, OP_JPa,		"JP addr",			"Jump to location nnn")
		Self.RegisterOpcode($2000, $F000, OP_CALLa,		"CALL addr",		"Call subroutine at nnn")
		Self.RegisterOpcode($3000, $F000, OP_SEVxb,		"SE Vx, byte",		"Skip next instruction if Vx = kk")
		Self.RegisterOpcode($4000, $F000, OP_SNEVxb,	"SNE Vx, byte",		"Skip next instruction if Vx != kk")
		Self.RegisterOpcode($5000, $F00F, OP_SEVxVy,	"SE Vx, Vy",		"Skip next instruction if Vx = Vy")
		Self.RegisterOpcode($6000, $F000, OP_LDVxb,		"LD Vx, byte",		"Set Vx = kk")
		Self.RegisterOpcode($7000, $F000, OP_ADDVxb,	"ADD Vx, byte",		"Set Vx = Vx + kk")
		Self.RegisterOpcode($8000, $F00F, OP_LDVxVy,	"LD Vx, Vy",		"Set Vx = Vy")
		Self.RegisterOpcode($8001, $F00F, OP_ORVxVy,	"OR Vx, Vy",		"Set Vx = Vx OR Vy")
		Self.RegisterOpcode($8002, $F00F, OP_ANDVxVy,	"AND Vx, Vy",		"Set Vx = Vx AND Vy")
		Self.RegisterOpcode($8003, $F00F, OP_XORVxVy,	"XOR Vx, Vy",		"Set Vx = Vx XOR Vy")
		Self.RegisterOpcode($8004, $F00F, OP_ADDVxVy,	"ADD Vx, Vy",		"Set Vx = Vx + Vy, set VF = carry")
		Self.RegisterOpcode($8005, $F00F, OP_SUBVxVy,	"SUB Vx, Vy",		"Set Vx = Vx - Vy, set VF = NOT borrow")
		Self.RegisterOpcode($8006, $F00F, OP_SHRVxVy,	"SHR Vx {, Vy}",	"Set Vx = Vx SHR 1")
		Self.RegisterOpcode($8007, $F00F, OP_SUBNVxVy,	"SUBN Vx, Vy",		"Set Vx = Vy - Vx, set VF = NOT borrow")
		Self.RegisterOpcode($800E, $F00F, OP_SHLVxVy,	"SHL Vx {, Vy}",	"Set Vx = Vx SHL 1")
		Self.RegisterOpcode($9000, $F00F, OP_SNEVxVy,	"SNE Vx, Vy",		"Skip next instruction if Vx != Vy")
		Self.RegisterOpcode($A000, $F000, OP_LDIa,		"LD I, addr",		"Set I = nnn")
		Self.RegisterOpcode($B000, $F000, OP_JPV0a,		"JP V0, addr",		"Jump to location nnn + V0")
		Self.RegisterOpcode($C000, $F000, OP_RNDVxb,	"RND Vx, byte",		"Set Vx = random byte AND kk")
		Self.RegisterOpcode($D000, $F000, OP_DRWVxVyn,	"DRW Vx, Vy, n",	"Display n-byte sprite starting at memory location I at (Vx, Vy), set VF = collision")
		Self.RegisterOpcode($E09E, $F0FF, OP_SKPVx,		"SKP Vx",			"Skip next instruction if key with the value of Vx is pressed")
		Self.RegisterOpcode($E0A1, $F0FF, OP_SKNPVx,	"SKNP Vx",			"Skip next instruction if key with the value of Vx is not pressed")
		Self.RegisterOpcode($F007, $F0FF, OP_LDVxDT,	"LD Vx, DT",		"Set Vx = delay timer value")
		Self.RegisterOpcode($F00A, $F0FF, OP_LDVxK,		"LD Vx, K",			"Wait for a key press, store the value of the key in Vx")
		Self.RegisterOpcode($F015, $F0FF, OP_LDDTVx,	"LD DT, Vx",		"Set delay timer = Vx")
		Self.RegisterOpcode($F018, $F0FF, OP_LDSTVx,	"LD ST, Vx",		"Set sound timer = Vx")
		Self.RegisterOpcode($F01E, $F0FF, OP_ADDIVx,	"ADD I, Vx",		"Set I = I + Vx")
		Self.RegisterOpcode($F029, $F0FF, OP_LDFVx,		"LD F, Vx",			"Set I = location of sprite for digit Vx")
		Self.RegisterOpcode($F033, $F0FF, OP_LDBVx,		"LD B, Vx",			"Store BCD representation of Vx in memory locations I, I+1, and I+2")
		Self.RegisterOpcode($F055, $F0FF, OP_LDIVx,		"LD [I], Vx",		"Store registers V0 through Vx in memory starting at location I")
		Self.RegisterOpcode($F065, $F0FF, OP_LDVxI,		"LD Vx, [I]",		"Read registers V0 through Vx from memory starting at location I")
	EndMethod
	
	Function OP_SYSa(opcode:Int, cpu:TBaseCPU)
		End
	EndFunction
	
	Function OP_CLS(opcode:Int, cpu:TBaseCPU)
		cpu.RendererPtr.Clear()
	EndFunction
	
	Function OP_RET(opcode:Int, cpu:TBaseCPU)
		If cpu.MemoryPtr.Stack.Count() <= 0 Return
		cpu.ProgramCounter = cpu.MemoryPtr.Stack.Pop()
	EndFunction
	
	Function OP_JPa(opcode:Int, cpu:TBaseCPU)
		cpu.ProgramCounter = opcode & $FFF
	EndFunction
	
	Function OP_CALLa(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.Stack.Push(cpu.ProgramCounter)
		cpu.ProgramCounter = opcode & $FFF
	EndFunction
	
	Function OP_SEVxb(opcode:Int, cpu:TBaseCPU)
		If cpu.MemoryPtr.V[cpu.GetX(opcode)] = opcode & $FF cpu.ProgressProgramCounter()
	EndFunction
	
	Function OP_SNEVxb(opcode:Int, cpu:TBaseCPU)
		If cpu.MemoryPtr.V[cpu.GetX(opcode)] <> opcode & $FF cpu.ProgressProgramCounter()
	EndFunction
	
	Function OP_SEVxVy(opcode:Int, cpu:TBaseCPU)
		If cpu.MemoryPtr.V[cpu.GetX(opcode)] = cpu.MemoryPtr.V[cpu.GetY(opcode)] cpu.ProgressProgramCounter()
	EndFunction
	
	Function OP_LDVxb(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[cpu.GetX(opcode)] = opcode & $FF
	EndFunction
	
	Function OP_ADDVxb(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[cpu.GetX(opcode)]:+opcode & $FF
	EndFunction
	
	Function OP_LDVxVy(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[cpu.GetX(opcode)] = cpu.MemoryPtr.V[cpu.GetY(opcode)]
	EndFunction
	
	Function OP_ORVxVy(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[cpu.GetX(opcode)]:|cpu.MemoryPtr.V[cpu.GetY(opcode)]
	EndFunction
	
	Function OP_ANDVxVy(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[cpu.GetX(opcode)]:&cpu.MemoryPtr.V[cpu.GetY(opcode)]
	EndFunction
	
	Function OP_XORVxVy(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[cpu.GetX(opcode)]:~cpu.MemoryPtr.V[cpu.GetY(opcode)]
	EndFunction
	
	Function OP_ADDVxVy(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[cpu.GetX(opcode)]:+cpu.MemoryPtr.V[cpu.GetY(opcode)]
		cpu.MemoryPtr.V[$F] = cpu.MemoryPtr.v[cpu.GetX(opcode)] > $FF
	EndFunction
	
	Function OP_SUBVxVy(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[$F] = cpu.MemoryPtr.V[cpu.GetX(opcode)] > cpu.MemoryPtr.V[cpu.GetY(opcode)]
		cpu.MemoryPtr.V[cpu.GetX(opcode)]:-cpu.MemoryPtr.V[cpu.GetY(opcode)]
	EndFunction
	
	Function OP_SHRVxVy(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[$F] = cpu.MemoryPtr.V[cpu.GetX(opcode)] & $1 > 0
		cpu.MemoryPtr.V[cpu.GetX(opcode)]:SHR 1
	EndFunction
	
	Function OP_SUBNVxVy(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[$F] = cpu.MemoryPtr.V[cpu.GetY(opcode)] > cpu.MemoryPtr.V[cpu.GetX(opcode)]
		cpu.MemoryPtr.V[cpu.GetX(opcode)] = cpu.MemoryPtr.V[cpu.GetY(opcode)] - cpu.MemoryPtr.V[cpu.GetX(opcode)]
	EndFunction
	
	Function OP_SHLVxVy(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[$F] = cpu.MemoryPtr.V[cpu.GetX(opcode)] & $80 > 0
		cpu.MemoryPtr.V[cpu.GetX(opcode)]:SHL 1
	EndFunction
	
	Function OP_SNEVxVy(opcode:Int, cpu:TBaseCPU)
		If cpu.MemoryPtr.V[cpu.GetX(opcode)] <> cpu.MemoryPtr.V[cpu.GetY(opcode)] cpu.ProgressProgramCounter()
	EndFunction
	
	Function OP_LDIa(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.I = opcode & $FFF
	EndFunction
	
	Function OP_JPV0a(opcode:Int, cpu:TBaseCPU)
		cpu.ProgramCounter = (opcode & $FFF) + cpu.MemoryPtr.V[0]
	EndFunction
	
	Function OP_RNDVxb(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[cpu.GetX(opcode)] = Floor(Rnd() * $FF) & (opcode & $FF)
	EndFunction
	
	Function OP_DRWVxVyn(opcode:Int, cpu:TBaseCPU)
		Local width:Int = 8
		Local height:Int = opcode & $F
		Local sprite:Int
		
		cpu.MemoryPtr.V[$F] = 0
		
		For Local row:Int = 0 Until height
			sprite = cpu.MemoryPtr.Memory[cpu.MemoryPtr.I + row]
			
			For Local col:Int = 0 Until width
				If sprite & $80 ..
					cpu.MemoryPtr.V[$F] = cpu.RendererPtr.TogglePixel(cpu.MemoryPtr.V[cpu.GetX(opcode)] + col, cpu.MemoryPtr.V[cpu.GetY(opcode)] + row)
				sprite:SHL 1
			Next
		Next
	EndFunction
	
	Function OP_SKPVx(opcode:Int, cpu:TBaseCPU)
		If cpu.InputPtr.IsKeyDown(cpu.MemoryPtr.V[cpu.GetX(opcode)]) cpu.ProgressProgramCounter()
	EndFunction
	
	Function OP_SKNPVx(opcode:Int, cpu:TBaseCPU)
		If Not cpu.InputPtr.IsKeyDown(cpu.MemoryPtr.V[cpu.GetX(opcode)]) cpu.ProgressProgramCounter()
	EndFunction
	
	Function OP_LDVxDT(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.V[cpu.GetX(opcode)] = cpu.DelayTimer
	EndFunction
	
	Function OP_LDVxK(opcode:Int, cpu:TBaseCPU)
		cpu.Paused = True
		cpu.InputPtr.LastKeyHit = -1
		cpu.InputPtr.WaitingForKey = True
		cpu.InputPtr.WaitingForKeyToX = cpu.GetX(opcode)
	EndFunction
	
	Function OP_LDDTVx(opcode:Int, cpu:TBaseCPU)
		cpu.DelayTimer = cpu.MemoryPtr.V[cpu.GetX(opcode)]
	EndFunction
	
	Function OP_LDSTVx(opcode:Int, cpu:TBaseCPU)
		cpu.AudioPtr.Play(cpu.MemoryPtr.V[cpu.GetX(opcode)])
	EndFunction
	
	Function OP_ADDIVx(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.I:+cpu.MemoryPtr.V[cpu.GetX(opcode)]
	EndFunction
	
	Function OP_LDFVx(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.I = cpu.MemoryPtr.V[cpu.GetX(opcode)] * 5 ' Sprite size is 5
	EndFunction
	
	Function OP_LDBVx(opcode:Int, cpu:TBaseCPU)
		cpu.MemoryPtr.Memory[cpu.MemoryPtr.I] = cpu.MemoryPtr.v[cpu.GetX(opcode)] / 100
		cpu.MemoryPtr.Memory[cpu.MemoryPtr.I + 1] = (cpu.MemoryPtr.V[cpu.GetX(opcode)] Mod 100) / 10
		cpu.MemoryPtr.Memory[cpu.MemoryPtr.I + 2] = cpu.MemoryPtr.V[cpu.GetX(opcode)] Mod 10
	EndFunction
	
	Function OP_LDIVx(opcode:Int, cpu:TBaseCPU)
		For Local index:Int = 0 To cpu.GetX(opcode)
			cpu.MemoryPtr.Memory[cpu.MemoryPtr.I + index] = cpu.MemoryPtr.V[index]
		Next
	EndFunction
	
	Function OP_LDVxI(opcode:Int, cpu:TBaseCPU)
		For Local index:Int = 0 To cpu.GetX(opcode)
			cpu.MemoryPtr.V[index] = cpu.MemoryPtr.Memory[cpu.MemoryPtr.I + index]
		Next
	EndFunction
EndType