SuperStrict

Import brl.standardio
Import brl.retro

Type TOpcode
	
	Field Code:Int
	Field CodeLen:Int
	Field CodeHex:String
	Field Description:String
	Field FunctionPtr(opcode:Int)
	
	Method New(code:String, desc:String = "Unknown", funcPtr(opcode:Int))
		Self.Code = Int("$"+code)
		Self.CodeLen = Len(code)
		Self.CodeHex = code
		Self.Description = desc
		Self.FunctionPtr = funcPtr
	EndMethod
EndType