Type TOpcode
	
	Field Code:Int
	Field Match:Int
	Field PseudoCode:String
	Field Description:String
	Field FunctionPtr(opcode:Int, cpu:TBaseCPU)
	
	Method New(code:Int, match:Int, funcPtr(opcode:Int, cpu:TBaseCPU), pseudo:String = "UNK", desc:String = "Unknown")
		Self.Code = code
		Self.Match = match
		Self.FunctionPtr = funcPtr
		Self.PseudoCode = pseudo
		Self.Description = desc
	EndMethod
EndType