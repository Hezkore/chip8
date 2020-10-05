SuperStrict

Import brl.standardio
Import brl.retro

Type TInput
	
	Field Keycodes:Int[] = [ ..
		88,  .. ' X
		49,  .. ' 1
		50,  .. ' 2
		51,  .. ' 3
		81,  .. ' Q
		87,  .. ' W
		69,  .. ' E
		65,  .. ' A
		83,  .. ' S
		68,  .. ' D
		90,  .. ' Z
		67,  .. ' C
		52,  .. ' 4
		70,  .. ' F
		86 .. ' V
	]
	Field KeysDown:Int[Keycodes.Length]
	Field LastKeyHit:Int = -1
	
	Method IsKeyDown:Int(code:Int)
		Return Self.KeysDown[code]
	EndMethod
	
	Method IsAnyKeyDown:Int()
		For Local i:Int = 0 Until Self.KeysDown.Length
			If Self.KeysDown[i] Return True
		Next
	EndMethod
	
	Method SetKeyStates()
		For Local i:Byte = 0 Until Self.Keycodes.Length
			If KeyDown(Self.Keycodes[i]) Then
				If Self.KeysDown[i] Continue
				Self.KeysDown[i] = True
				Self.LastKeyHit = i
			Else
				Self.KeysDown[i] = False
			EndIf
		Next
	EndMethod
EndType