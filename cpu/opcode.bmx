Type TOpcode
	
	Field Code:Int
	'Field CodeLen:Int
	Field Match:Int
	'Field CodeHex:String
	Field PseudoCode:String
	Field FunctionPtr(opcode:Int, cpu:TBaseCPU)
	
	Method New(code:Int, match:Int, funcPtr(opcode:Int, cpu:TBaseCPU), pseudo:String = "UNK")
		Self.Code = code
		Self.Match = match
		Self.FunctionPtr = funcPtr
		Self.PseudoCode = pseudo
		'Print("0x" + Right(Hex(Self.Code), 4) + " " + pseudo)
	EndMethod
EndType