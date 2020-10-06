SuperStrict

Import brl.collections

Type TMemory
	
	Field Stack:TStack < Int >= New TStack < Int >
	Field Memory:Byte[4096]
	Field V:Byte[16]
	Field I:Int
EndType