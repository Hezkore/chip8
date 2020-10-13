SuperStrict

Framework brl.standardio

Import "window.bmx"
Import "machine.bmx"

' Create the Window
Local MainWindow:TWindow = New TWindow

' Create the CHIP-8 machine
Local Machine:TCHIP8Machine = New TCHIP8Machine
Machine.ChangeCPU("CHIP-8")

' Wait for ROM
Repeat 
	MainWindow.Update(Machine)
Until Machine.Running()

' Dump the entire ROM
Rem
Local ROM:String
Local code:Int
Local opcode:TOpcode
For Local i:Int = $200 Until Machine.Memory.Memory.Length Step 2
	code = Machine.Memory.GetOpcodeAtIndex(i)
	ROM:+"0x"+Right(Hex(code), 4)
	opcode = Machine.CPU.GetOpcode(code)
	If opcode Then
		ROM:+" - " + opcode.PseudoCode
	Else
		ROM:+" - UNR"
	EndIf
	ROM:+"~t~t" + Machine.CPU.GetX(code)+", "+Machine.CPU.GetY(code)
	ROM:+"~n"
Next
SaveString(ROM, "ROM_DUMP.txt")
End
EndRem

' Main loop
While Machine.Running()
	Machine.Update()
	MainWindow.Update(Machine)
WEnd