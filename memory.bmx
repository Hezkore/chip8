SuperStrict

Import brl.collections
Import brl.filesystem

Type TMemory
	
	Field Stack:TStack < Int >= New TStack < Int >
	Field Memory:Byte[4096]
	Field V:Byte[16]
	Field I:Int
	
	Method GetOpcodeAtIndex:Int(index:Int)
		Return Self.Memory[$200 + index] Shl 8 | Self.Memory[$200 + index + 1]
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
EndType