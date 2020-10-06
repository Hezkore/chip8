SuperStrict

Import brl.objectlist
Import brl.standardio

Import "..\renderer.bmx"
Import "..\audio.bmx"
Import "..\input.bmx"
Import "opcode.bmx"

Type TBaseCPU
	
	Global RegisteredCPUs:TObjectList = New TObjectList()
	
	Field Name:String = "Unknown CPU"
	Field RegisteredOpcodes:TOpcode[] ' Wanted TStack, but crashes
	Field DelayTimer:Int
	Field ProgramCounter:Int
	Field Paused:Int
	
	Field Renderer:TRenderer
	Field Input:TInput
	Field Audio:TAudio
	
	Method RegisterAsCPU(name:String)
		Self.Name = name
		TBaseCPU.RegisteredCPUs.AddLast(Self)
		Print("Registered CPU " + Self.Name)
	EndMethod
	
	Method RegisterOpcode(code:String, desc:String, funcPtr(opcode:Int))
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
		
	EndMethod
EndType