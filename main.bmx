SuperStrict

Framework brl.standardio

Import "window.bmx"
Import "machine.bmx"

' Create the Window
Local MainWindow:TWindow = New TWindow

' Create the CHIP-8 machine
Local Machine:TCHIP8Machine = New TCHIP8Machine
Machine.ChangeCPU("CHIP-8")
If Not Machine.LoadROM("dev/RUSH_HOUR") Print("Unable to load ROM"); End

' Main loop
While Machine.Running()
	Machine.Update()
	MainWindow.Update(Machine)
WEnd