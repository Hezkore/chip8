SuperStrict

Import brl.objectlist
Import brl.standardio

Import "..\memory.bmx"
Import "..\renderer.bmx"
Import "..\audio.bmx"
Import "..\input.bmx"

Include "opcode.bmx"

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
	Field ProgressOnInstruction:Int = True
	
	' Pointers
	Field AudioPtr:TAudio
	Field InputPtr:TInput
	Field MemoryPtr:TMemory
	Field RendererPtr:TRenderer
	
	Method New()
		Self.Reset()
	EndMethod
	
	Method Reset()
		Self.ProgramCounter = $200
	EndMethod
	
	Method RegisterAsCPU(name:String)
		Self.Name = name
		TBaseCPU.RegisteredCPUs.AddLast(Self)
		Print("Registered CPU " + Self.Name)
	EndMethod
	
	Method RegisterOpcode(code:String, funcPtr(opcode:Int, cpu:TBaseCPU), pseudo:String)
		' Code is sent as a string so that we can detect the expected length
		Local rawCode:Int = Int("$"+code)
		
		' Is this already registered?
		For Local op:TOpcode = EachIn Self.RegisteredOpcodes
			If op.Code = rawCode Then
				' Update
				op.PseudoCode = pseudo
				op.FunctionPtr = funcPtr
				Return
			EndIf
		Next
		
		' Add new
		Self.RegisteredOpcodes = RegisteredOpcodes[..RegisteredOpcodes.Length+1]
		Self.RegisteredOpcodes[Self.RegisteredOpcodes.Length-1] = New TOpcode(code, funcPtr, pseudo)
	EndMethod
	
	Function GetCPU:TBaseCPU(name:String)
		For Local c:TBaseCPU = EachIn Self.RegisteredCPUs
			If c.Name = name Return c
		Next
	EndFunction
	
	Function GetX:Int(opcode:Int)
		Return (opcode & $0F00) Shr 8
	EndFunction
	
	Function GetY:Int(opcode:Int)
		Return (opcode & $00F0) Shr 4
	EndFunction
	
	Method GetOpcode:TOpcode(code:Int)
		'Print "Looking for opcode 0x" + Right(Hex(code),4)
		Local matches:TOpcode[3]
		For Local o:TOpcode = EachIn Self.RegisteredOpcodes
			' TODO make this pretty, please
			'Print "0x"+Right(Hex(code),4)+"/0x"+Right(Hex(o.Code),4)
			Select o.CodeLen
				' Return exact matches
				Case 4 If o.Code & $FFFF = code & $FFFF Return o
				' Store similar matches
				Case 3 If o.Code & $FFF0 = code & $FFF0 matches[0] = o
				Case 2 If o.Code & $FF00 = code & $FF00 matches[1] = o
				Case 1 If o.Code & $F000 = code & $F000 matches[2] = o
			EndSelect
		Next
		' Return the best match
		If matches[0] Return matches[0]
		If matches[1] Return matches[1]
		If matches[2] Return matches[2]
	EndMethod
	
	Method Execute(code:Int)
		Local opcode:TOpcode = Self.GetOpcode(code)
		If opcode Then
			If opcode.FunctionPtr opcode.FunctionPtr(code, Self)
			Print("Executing 0x"+Right(Hex(code), 4) + " - " + opcode.PseudoCode)
		Else
			Local err:String = "Unknown opcode 0x" + Right(Hex(code), 4)
			Print(err)
			Notify(err, True)
			End
		EndIf
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
			Self.Execute(opcode)
			If Self.ProgressOnInstruction Self.ProgressProgramCounter()
			'Self.ExecuteInstruction(opcode)
			If Self.Paused Return
		Next
		
		If Self.DelayTimer > 0 Self.DelayTimer:-1
		'Self.Audio.Update()
	EndMethod
	
	Method ProgressProgramCounter()
		Self.ProgramCounter:+2
	EndMethod
EndType