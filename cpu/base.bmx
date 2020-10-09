SuperStrict

Import brl.objectlist
Import brl.standardio

Import "..\memory.bmx"
Import "..\renderer.bmx"
Import "..\audio.bmx"
Import "..\input.bmx"
Import "opcode.bmx"

Type TBaseCPU
	
	Global RegisteredCPUs:TObjectList = New TObjectList()
	
	' Identity
	Field Name:String = "Unknown CPU"
	Field RegisteredOpcodes:TOpcode[] ' Wanted TStack, but crashes
	
	' Flow
	Field Speed:Int = 10
	Field Paused:Int
	Field DelayTimer:Int
	Field ProgramCounter:Int
	
	' Pointers
	Field AudioPtr:TAudio
	Field InputPtr:TInput
	Field MemoryPtr:TMemory
	Field RendererPtr:TRenderer
	
	Method RegisterAsCPU(name:String)
		Self.Name = name
		TBaseCPU.RegisteredCPUs.AddLast(Self)
		Print("Registered CPU " + Self.Name)
	EndMethod
	
	Method RegisterOpcode(code:String, desc:String, funcPtr(opcode:Int))
		' Cleanup
		code = Upper(code)
		
		' Is this already registered?
		For Local op:TOpcode = EachIn Self.RegisteredOpcodes
			If op.CodeHex = code Then
				' Update
				op.Description = desc
				op.FunctionPtr = funcPtr
				Return
			EndIf
		Next
		
		' Add new
		Self.RegisteredOpcodes = RegisteredOpcodes[..RegisteredOpcodes.Length+1]
		Self.RegisteredOpcodes[Self.RegisteredOpcodes.Length-1] = New TOpcode(code, desc, funcPtr)
	EndMethod
	
	Function GetCPU:TBaseCPU(name:String)
		For Local c:TBaseCPU = EachIn Self.RegisteredCPUs
			If c.Name = name Return c
		Next
	EndFunction
	
	Method GetOpcode:TOpcode(code:String)
		Local rawCode:Int = Int("$"+code)
		
		' Attempt exact match
		For Local o:TOpcode = EachIn Self.RegisteredOpcodes
			If o.Code = rawCode Return o
		Next
		
		' Match against the information we've got registered
		For Local o:TOpcode = EachIn Self.RegisteredOpcodes
			If o.CodeHex = Left(code,o.CodeLen) Return o
		Next
	EndMethod
	
	Method Execute(code:String)
		Local opcode:TOpcode = Self.GetOpcode(code)
		If opcode And opcode.FunctionPtr opcode.FunctionPtr(Int("$"+code))
	EndMethod
	
	Method CopyOpcodesFrom(cpu:TBaseCPU)
		Self.RegisteredOpcodes[] = cpu.RegisteredOpcodes[..]
	EndMethod
	
	Method Cycle()
		If Self.Paused Then
			'If Self.IsWatingForKey And Self.Input.LastKeyHit >= 0 Then
			'	Self.V[Self.WaitForKeyX] = Self.Input.LastKeyHit
			'	Self.Paused = False
			'	Self.IsWatingForKey = False
			'EndIf
			Return
		EndIf
		
		Local opcode:Int
		For Local i:Int = 0 Until Self.Speed
			'opcode = Self.Memory[Self.ProgramCounter] Shl 8 | Self.Memory[Self.ProgramCounter + 1]
			opcode = Self.MemoryPtr.GetOpcodeAtIndex(Self.ProgramCounter)
			Print Right(Hex(opcode),4)
			'Self.ProgressProgramCounter()
			'Self.ExecuteInstruction(opcode)
			If Self.Paused Return
		Next
		
		If Self.DelayTimer > 0 Self.DelayTimer:-1
		'Self.Audio.Update()
	EndMethod
EndType