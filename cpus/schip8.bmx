SuperStrict

Import "base.bmx"

New TSCHIP8CPU
Type TSCHIP8CPU Extends TBaseCPU
	
	Method New()
		Self.RegisterAsCPU("Super CHIP-8")
		Self.CopyOpcodesFrom(Self.GetCPU("CHIP-8"))
		' Insert Super CHIP-8 specific instructions here!
	EndMethod
EndType