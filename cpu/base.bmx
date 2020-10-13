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
	
	Method RegisterOpcode(code:Int, match:Int, funcPtr(opcode:Int, cpu:TBaseCPU), pseudo:String, desc:String)
		' Is this already registered?
		For Local op:TOpcode = EachIn Self.RegisteredOpcodes
			If op.Code = code And op.Match = match Then
				' Update
				op.FunctionPtr = funcPtr
				op.PseudoCode = pseudo
				op.Description = desc
				Return
			EndIf
		Next
		
		' Add new
		Self.RegisteredOpcodes = RegisteredOpcodes[..RegisteredOpcodes.Length+1]
		Self.RegisteredOpcodes[Self.RegisteredOpcodes.Length-1] = New TOpcode(code, match, funcPtr, pseudo)
	EndMethod
	
	Function GetCPU:TBaseCPU(name:String)
		For Local c:TBaseCPU = EachIn Self.RegisteredCPUs
			If c.Name = name Return c
		Next
	EndFunction
	
	Function GetX:Int(opcode:Int)
		Return (opcode & $0F00) SHR 8
	EndFunction
	
	Function GetY:Int(opcode:Int)
		Return (opcode & $00F0) SHR 4
	EndFunction
	
	Method GetOpcode:TOpcode(code:Int)
		Local matchScore:Int
		Local bestMatchScore:Int
		Local bestMatch:TOpcode
		For Local o:TOpcode = EachIn Self.RegisteredOpcodes
			matchScore = 0
			If o.Match = $FFFF Then
				' Return exact match
				If o.Code = code Return o
			Else
				' Store match
				If o.Code & o.Match = code & o.Match Then
					' TODO Make this prettier
					For Local i:int = 0 Until 4
						If (o.Match SHR (4*i)) & $000F matchScore:+1
					Next
					If matchScore > 0 And bestMatchScore <= matchScore Then
						bestMatchScore = matchScore
						bestMatch = o
					EndIf
				EndIf
			EndIf
		Next
		Return bestMatch
	EndMethod
	
	Method ExecuteInstruction(code:Int)
		Local opcode:TOpcode = Self.GetOpcode(code)
		If opcode Then
			'Print(Right(Hex(Self.ProgramCounter), 4) + " - 0x"+Right(Hex(code), 4) + " ~t (0x"+Right(Hex(opcode.Code), 4)+")" + opcode.PseudoCode)
			If opcode.FunctionPtr opcode.FunctionPtr(code, Self)
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
			If Self.InputPtr.WaitingForKey And Self.InputPtr.LastKeyHit >= 0 Then
				Self.MemoryPtr.V[Self.InputPtr.WaitingForKeyToX] = Self.InputPtr.LastKeyHit
				Self.Paused = False
				Self.InputPtr.WaitingForKey = False
			EndIf
			Return
		EndIf
		
		Local opcode:Int
		For Local i:Int = 0 Until Self.Speed
			opcode = Self.MemoryPtr.GetOpcodeAtIndex(Self.ProgramCounter)
			If Self.ProgressOnInstruction Self.ProgressProgramCounter()
			Self.ExecuteInstruction(opcode)
			If Self.Paused Return
		Next
		
		If Self.DelayTimer > 0 Self.DelayTimer:-1
		Self.AudioPtr.Update()
	EndMethod
	
	Method ProgressProgramCounter()
		Self.ProgramCounter:+2
	EndMethod
EndType