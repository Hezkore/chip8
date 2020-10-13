SuperStrict

Import brl.collections
Import brl.filesystem

Type TMemory
	
	Field Stack:TStack < Int >= New TStack < Int >
	Field Memory:Byte[4096]
	Field V:Byte[16]
	Field I:Int
	
	Method New()
		Self.Reset()
	EndMethod
	
	Method GetOpcodeAtIndex:Int(index:Int)
		If index >= Self.Memory.Length Return -1
		Return Self.Memory[index] Shl 8 | Self.Memory[index + 1]
	EndMethod
	
	Method LoadROM:Int(path:String)
		If Not FileType(path) Return False
		Self.LoadProgram(LoadString(path))
		Return True
	EndMethod
	
	Method LoadProgram(data:String)
		For Local i:Int = 0 Until data.Length
			Self.Memory[$200 + i] = data[i]
		Next
	EndMethod
	
	Method CreateSpritesInMemory()
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
	
	Method Reset()
		For Local i:Int = 0 Until Self.Memory.Length
			Self.Memory[i] = 0
		Next
		Self.CreateSpritesInMemory()
	EndMethod
EndType