SuperStrict

Import "chip8.bmx"

New TSCHIP8CPU
Type TSCHIP8CPU Extends TBaseCPU
	
	Method New()
		Self.RegisterAsCPU("Super CHIP-8")
		Self.CopyOpcodesFrom(Self.GetCPU("CHIP-8"))
	EndMethod
EndType