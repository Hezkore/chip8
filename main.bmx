SuperStrict

Framework brl.standardio

Import "window.bmx"
Import "machine.bmx"

' Create the Window
Local MainWindow:TWindow = New TWindow

' Create the CHIP-8 machine
Local Machine:TCHIP8Machine = New TCHIP8Machine
'Machine.ChangeCPU("CHIP-8")

' Wait for ROM
Repeat 
	MainWindow.Update(Machine)
Until Machine.Running()

' Main loop
While Machine.Running()
	Machine.Update()
	MainWindow.Update(Machine)
WEnd