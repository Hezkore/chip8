SuperStrict

Import brl.retro
Import brl.collections
Import brl.objectlist
Import brl.randomdefault

Import "renderer.bmx"
Import "input.bmx"
Import "audio.bmx"

Type TCPU
	Field Renderer:TRenderer
	Field Input:TInput
	Field Audio:TAudio
	Field Memory:Byte[4096]
	Field V:Byte[16]
	Field I:Int
	Field DelayTimer:Int
	Field ProgramCounter:Int
	Field Stack:TStack < Int >= New TStack < Int >
	Field Paused:Int
	Field IsWatingForKey:Int
	Field WaitForKeyX:Int
	Field Speed:Int
	
	Field LogOpcodes:Int = False
	Field OpcodeLog:TObjectList = New TObjectList
	
	Method New(renderer:TRenderer, input:TInput, audio:TAudio)
		Self.Renderer = renderer
		Self.Input = input
		Self.Audio = audio
		
		Self.CreateSpritesInMemory()
	EndMethod
	
	Method LoadROM(path:String)
		Self.LoadProgram(LoadString(path))
	EndMethod
	
	Method LoadProgram(data:String)
		Reset()
		For Local i:Int = 0 Until data.Length
			Self.Memory[$200 + i] = data[i]
		Next
	EndMethod
	
	Method Reset()
		Self.DelayTimer = 0
		Self.Audio.SoundTimer = 0
		Self.Paused = False
		Self.IsWatingForKey = False
		Self.WaitForKeyX = 0
		Self.Speed = 10
		Self.ProgramCounter = $200
		Self.Renderer.Clear()
	EndMethod
	
	Method Cycle()
		If Self.Paused Then
			If Self.IsWatingForKey And Self.Input.LastKeyHit >= 0 Then
				Self.V[Self.WaitForKeyX] = Self.Input.LastKeyHit
				Self.Paused = False
				Self.IsWatingForKey = False
			EndIf
			Return
		EndIf
		
		Local opcode:Int
		For Local i:Int = 0 Until Self.Speed
			opcode = Self.Memory[Self.ProgramCounter] Shl 8 | Self.Memory[Self.ProgramCounter + 1]
			Self.ProgressProgramCounter()
			Self.ExecuteInstruction(opcode)
			If Self.Paused Return
		Next
		
		If Self.DelayTimer > 0 Self.DelayTimer:-1
		Self.Audio.Update()
	EndMethod
	
	Method ProgressProgramCounter()
		Self.ProgramCounter:+2
	EndMethod
	
	Method ExecuteInstruction(opcode:Int)
		
		Local x:Int = (opcode & $0F00) Shr 8
		Local y:Int = (opcode & $00F0) Shr 4
		
		'Print Hex(opcode & $F000) + "(" + Hex(opcode) + ")"
		
		' Standard Chip-8 Instructions
		Select opcode & $F000
			Case $0000
				Select opcode & $F0
					Case $10 ' Exit emulator with a return value of N
						Print("Exit " + (opcode & $F))
						Self.Reset()
						
					Case $B0 ' Scroll display N lines up
						Self.Renderer.ScrollV((opcode & $F))
						
					Case $C0 ' Scroll display N lines down
						Self.Renderer.ScrollV(-(opcode & $F))
						
					Case $E0
						Select opcode & $F
							Case $0 ' CLS Clear the display
								Self.LogOpcode("CLS")
								Self.Renderer.Clear()
								
							Case $E ' RET Return from a subroutine
								Self.LogOpcode("RET", Self.Stack.Peek())
								Self.ProgramCounter = Self.Stack.Pop()
								
							Default
								Self.UnknownOpcode(opcode)
						EndSelect
						
					Case $F0
						Select opcode & $F
							'Case $B ' Scroll display 4 pixels to the right
							'	Self.Renderer.ScrollH(4)
								
							'Case $C ' Scroll display 4 pixels to the left
							'	Self.Renderer.ScrollH(-4)
								
							Case $D ' Exit the interpreter
								Print("Exit")
								Self.Reset()
								
							Case $E ' Enable low-res (64x32) mode
								Self.Renderer.ChangeResolution(64, 32)
								
							Case $F ' Enable high-res (128x64) mode
								Self.Renderer.ChangeResolution(128, 64)
								
							Default
								Self.UnknownOpcode(opcode)
						EndSelect
					
					Default
						Self.UnknownOpcode(opcode)
				EndSelect
				
			Case $1000 ' JP addr Jump to location nnn
				Self.LogOpcode("JP", "addr(" + (opcode & $FFF) + ")")
				Self.ProgramCounter = opcode & $FFF
				
			Case $2000 ' CALL addr Call subroutine at nnn
				Self.LogOpcode("CALL", "addr(" + (opcode & $FFF) + ")")
				Self.Stack.Push(Self.ProgramCounter)
				Self.ProgramCounter = opcode & $FFF
				
			Case $3000 ' SE Vx, byte Skip next instruction if Vx = kk
				Self.LogOpcode("SE", "Vx(" + Self.V[x] + "), byte(" + (opcode & $FF) + ")")
				If Self.V[x] = opcode & $FF Self.ProgressProgramCounter()
				
			Case $4000 ' SNE Vx, byte Skip next instruction if Vx != kk
				Self.LogOpcode("SNE", "Vx(" + Self.V[x] + "), Vy(" + Self.V[y] + ")")
				If Self.V[x] <> opcode & $FF Self.ProgressProgramCounter()
				
			Case $5000 ' SE Vx, Vy Skip next instruction if Vx = Vy
				Self.LogOpcode("SE", "Vx(" + Self.V[x] + "), Vy(" + Self.V[y] + ")")
				If Self.V[x] = Self.V[y] Self.ProgressProgramCounter()
				
			Case $6000 ' LD Vx, byte Set Vx = kk
				Self.LogOpcode("LD", "Vx(" + Self.V[x] + "), byte(" + (opcode & $FF) + ")")
				Self.V[x] = opcode & $FF
				
			Case $7000 ' ADD Vx, byte Set Vx = Vx + kk
				Self.LogOpcode("ADD", "Vx(" + Self.V[x] + "), byte(" + (opcode & $FF) + ")")
				Self.V[x]:+opcode & $FF
				
			Case $8000
				Select opcode & $F
					Case $0 ' LD Vx, Vy Set Vx = Vy
						Self.LogOpcode("LD", "Vx(" + Self.V[x] + "), Vy(" + Self.V[y] + ")")
						Self.V[x] = Self.V[y]
						
					Case $1 ' OR Vx, Vy Set Vx = Vx OR Vy
						Self.LogOpcode("OR", "Vx(" + Self.V[x] + "), Vy(" + Self.V[y] + ")")
						Self.V[x]:|Self.V[y]
						
					Case $2 ' AND Vx, Vy Set Vx = Vx AND Vy
						Self.LogOpcode("AND", "Vx(" + Self.V[x] + "), Vy(" + Self.V[y] + ")")
						Self.V[x]:&Self.V[y]
						
					Case $3 ' XOR Vx, Vy Set Vx = Vx XOR Vy
						Self.LogOpcode("XOR", "Vx(" + Self.V[x] + "), Vy(" + Self.V[y] + ")")
						Self.V[x]:~Self.V[y]
						
					Case $4 ' ADD Vx, Vy Set Vx = Vx + Vy, set VF = carry
						Self.LogOpcode("ADD", "Vx(" + Self.V[x] + "), Vy(" + Self.V[y] + ")")
						Self.V[x]:+Self.V[y]
						Self.V[$F] = Self.v[x] > $FF
						
					Case $5 ' SUB Vx, Vy Set Vx = Vx - Vy, set VF = NOT borrow
						Self.LogOpcode("SUB", "Vx(" + Self.V[x] + "), Vy(" + Self.V[y] + ")")
						Self.V[$F] = Self.V[x] > Self.V[y]
						Self.V[x]:-Self.V[y]
						
					Case $6 ' SHR Vx {, Vy} Set Vx = Vx SHR 1
						Self.LogOpcode("SHR", "Vx(" + Self.V[x] + ")")
						Self.V[$F] = Self.v[x] & $1 > 0
						Self.V[x]:SHR 1
						
					Case $7 ' SUBN Vx, Vy Set Vx = Vy - Vx, set VF = NOT borrow
						Self.LogOpcode("SUBN", "Vx(" + Self.V[x] + "), Vy(" + Self.V[y] + ")")
						Self.V[$F] = Self.V[y] > Self.V[x]
						Self.V[x] = Self.V[y] - Self.V[x]
						
					Case $E ' SHL Vx {, Vy} Set Vx = Vx SHL 1
						Self.LogOpcode("SHL", "Vx(" + Self.V[x] + ")")
						Self.v[$F] = Self.v[x] & $80 > 0
						Self.v[x]:SHL 1
						
					Default
						Self.UnknownOpcode(opcode)
				EndSelect
				
			Case $9000 ' SNE Vx, Vy Skip next instruction if Vx != Vy
				Self.LogOpcode("SNE", "Vx(" + Self.V[x] + "), Vy(" + Self.V[y] + ")")
				If Self.V[x] <> Self.V[y] Self.ProgressProgramCounter()
				
			Case $A000 ' LD I, addr Set I = nnn
				Self.LogOpcode("LD", "I(" + Self.I + "), addr(" + (opcode & $FFF) + ")")
				Self.I = opcode & $FFF
				
			Case $B000 ' JP V0, addr Jump to location nnn + V0
				Self.LogOpcode("JP", "V0(" + Self.V[0] + "), addr(" + (opcode & $FFF) + ")")
				Self.ProgramCounter = (opcode & $FFF) + Self.V[0]
				
			Case $C000 ' RND Vx, byte Set Vx = random byte AND kk
				Self.LogOpcode("RND", "Vx(" + Self.V[x] + "), byte(" + (opcode & $FF) + ")")
				Self.V[x] = Floor(Rnd() * $FF) & (opcode & $FF)
				
			Case $D000 'DRW Vx, Vy, nibble Display n-byte sprite starting at memory location I at (Vx, Vy), set VF = collision 
				Local width:Int = 8
				Local height:Int = opcode & $F
				Local sprite:Int
				
				Self.V[$F] = 0
				
				For Local row:Int = 0 Until height
					sprite = Self.Memory[Self.I + row]
					
					For Local col:Int = 0 Until width
						If sprite & $80 ..
							Self.V[$F] = Self.Renderer.TogglePixel(Self.V[x] + col, Self.V[y] + row)
						sprite:SHL 1
					Next
				Next
				
				Self.LogOpcode("DRW")
				
			Case $E000
				Select opcode & $FF
					Case $9E ' SKP Vx Skip next instruction if key with the value of Vx is pressed
						Self.LogOpcode("SKP", "Vx(" + Self.V[x] + ")")
						If Self.Input.IsKeyDown(Self.V[x]) Self.ProgressProgramCounter()
						
					Case $A1 ' SKNP Vx Skip next instruction if key with the value of Vx is not pressed
						Self.LogOpcode("SKNP", "Vx(" + Self.V[x] + ")")
						If Not Self.Input.IsKeyDown(Self.V[x]) Self.ProgressProgramCounter()
						
					Default
						Self.UnknownOpcode(opcode)
				EndSelect
				
			Case $F000
				Select opcode & $FF
					Case $07 ' LD Vx, DT Set Vx = delay timer value
						Self.LogOpcode("LD", "Vx(" + Self.V[x] + "), DT(" + Self.DelayTimer + ")")
						Self.V[x] = Self.DelayTimer
						
					Case $0A ' LD Vx, K Wait for a key press, store the value of the key in Vx
						Self.LogOpcode("LD", "Vx(" + x + "), K")
						Self.Paused = True
						Self.Input.LastKeyHit = -1
						Self.IsWatingForKey = True
						Self.WaitForKeyX = x
						
					Case $15 ' LD DT, Vx Set delay timer = Vx
						Self.LogOpcode("LD", "DT(" + Self.DelayTimer + "), Vx(" + Self.V[x] + ")")
						Self.DelayTimer = Self.V[x]
						
					Case $18 ' LD ST, Vx Set sound timer = Vx
						Self.LogOpcode("LD", "ST(" + Self.Audio.SoundTimer + "), Vx(" + Self.V[x] + ")")
						Self.Audio.Play(Self.V[x])
						
					Case $1E ' ADD I, Vx Set I = I + Vx
						Self.LogOpcode("ADD", "I, Vx(" + Self.V[x] + ")")
						Self.I:+Self.V[x]
						
					Case $29 ' LD F, Vx Set I = location of sprite for digit Vx
						Self.LogOpcode("LD", "F, Vx(" + Self.V[x] + ")")
						Self.I = Self.V[x] * 5 ' Sprite size is 5
						
					Case $30 ' Set I to the address of the SCHIP-8 16x10 font sprite representing the value in VX
						Self.I = $200 + Self.V[x] * 10
						
					Case $33 ' LD B, Vx Store BCD representation of Vx in memory locations I, I+1, and I+2
						Self.LogOpcode("LD", "B, Vx(" + Self.v[x] + ")")
						Self.Memory[Self.I] = Self.v[x] / 100
						Self.Memory[Self.I + 1] = (Self.V[x] Mod 100) / 10
						Self.Memory[Self.I + 2] = Self.V[x] Mod 10
						
					Case $55 ' LD [I], Vx Store registers V0 through Vx in memory starting at location I
						Self.LogOpcode("LD", "[I], Vx(" + x + ")")
						For Local index:Int = 0 To x
							Self.Memory[Self.I + index] = Self.V[index]
						Next
						
					Case $65 ' LD Vx, [I] Read registers V0 through Vx from memory starting at location I
						Self.LogOpcode("LD", "Vx(" + x + "), [I]")
						For Local index:Int = 0 To x
							Self.V[index] = Self.memory[Self.I + index]
						Next
						
					Default
						Self.UnknownOpcode(opcode)
				EndSelect
				
			Default
				Self.UnknownOpcode(opcode)
		EndSelect
	EndMethod
	
	Method UnknownOpcode(opcode:Int)
		Print("Unknown opcode: 0x" + Right(Hex(opcode), 4))
	EndMethod
	
	Method LogOpcode(call:String, data:String = Null)
		If Not Self.LogOpcodes Return
		Print call + " " + data
		Self.OpcodeLog.AddLast(New TOpcodeLogItem(call, data))
	EndMethod
	
	Method CreateSpritesInMemory()
		' Seems the CHIP-8 has some built-in sprites we should generate
		' 0
		Self.Memory[0] = $F0; Self.Memory[1] = $90; Self.Memory[2] = $90; Self.Memory[3] = $90; Self.Memory[4] = $F0
		' 1
		Self.Memory[5] = $20; Self.Memory[6] = $60; Self.Memory[7] = $20; Self.Memory[8] = $20; Self.Memory[9] = $70
		' 2
		Self.Memory[10] = $F0; Self.Memory[11] = $10; Self.Memory[12] = $F0; Self.Memory[13] = $80; Self.Memory[14] = $F0
		' 3
		Self.Memory[15] = $F0; Self.Memory[16] = $10; Self.Memory[17] = $F0; Self.Memory[18] = $10; Self.Memory[19] = $F0
		' 4
		Self.Memory[20] = $90; Self.Memory[21] = $90; Self.Memory[22] = $F0; Self.Memory[23] = $10; Self.Memory[24] = $10
		' 5
		Self.Memory[25] = $F0; Self.Memory[26] = $80; Self.Memory[27] = $F0; Self.Memory[28] = $10; Self.Memory[29] = $F0
		' 6
		Self.Memory[30] = $F0; Self.Memory[31] = $80; Self.Memory[32] = $F0; Self.Memory[33] = $90; Self.Memory[34] = $F0
		' 7
		Self.Memory[35] = $F0; Self.Memory[36] = $10; Self.Memory[37] = $20; Self.Memory[38] = $40; Self.Memory[39] = $40
		' 8
		Self.Memory[40] = $F0; Self.Memory[41] = $90; Self.Memory[42] = $F0; Self.Memory[43] = $90; Self.Memory[44] = $F0
		' 9
		Self.Memory[45] = $F0; Self.Memory[46] = $90; Self.Memory[47] = $F0; Self.Memory[48] = $10; Self.Memory[49] = $F0
		' A
		Self.Memory[50] = $F0; Self.Memory[51] = $90; Self.Memory[52] = $F0; Self.Memory[53] = $90; Self.Memory[54] = $90
		' B
		Self.Memory[55] = $E0; Self.Memory[56] = $90; Self.Memory[57] = $E0; Self.Memory[58] = $90; Self.Memory[59] = $E0
		' C
		Self.Memory[60] = $F0; Self.Memory[61] = $80; Self.Memory[62] = $80; Self.Memory[63] = $80; Self.Memory[64] = $F0
		' D
		Self.Memory[65] = $E0; Self.Memory[66] = $90; Self.Memory[67] = $90; Self.Memory[68] = $90; Self.Memory[69] = $E0
		' E
		Self.Memory[70] = $F0; Self.Memory[71] = $80; Self.Memory[72] = $F0; Self.Memory[73] = $80; Self.Memory[74] = $F0
		' F
		Self.Memory[75] = $F0; Self.Memory[76] = $80; Self.Memory[77] = $F0; Self.Memory[78] = $80; Self.Memory[79] = $80
	EndMethod
EndType

Type TOpcodeLogItem
	Field Call:String
	Field Data:String
	
	Method New(call:String, data:String)
		Self.Call = call
		Self.Data = data
	EndMethod
EndType