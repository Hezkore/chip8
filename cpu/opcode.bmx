Type TOpcode
	
	Field Code:Int
	Field CodeLen:Int
	Field CodeHex:String
	Field PseudoCode:String
	Field FunctionPtr(opcode:Int, cpu:TBaseCPU)
	
	Method New(code:String, funcPtr(opcode:Int, cpu:TBaseCPU), pseudo:String = "UNK")
		Self.CodeHex = code
		For Local i:Int = Len(code) Until 4
			Self.CodeHex:+"0"
		Next
		Self.Code = Int("$"+Self.CodeHex)
		Self.CodeLen = Len(code)
		Self.FunctionPtr = funcPtr
		Self.PseudoCode = pseudo
		Print("0x" + Self.CodeHex + " ("+Len(code)+") " + pseudo)
	EndMethod
EndType