SuperStrict

Import maxgui.drivers
Import brl.eventqueue

Import "machine.bmx"

Type TWindow
	
	Field Title:String = "BlitzMax CHIP-8 Emulator"
	Field Window:TGadget
	Field Canvas:TGadget
	
	Method New()	
		Self.Window = CreateWindow(Self.Title,..
		0,0,64*14,32*14,Null,..
		WINDOW_RESIZABLE|WINDOW_CENTER|WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS|WINDOW_ACCEPTFILES)
		
		Self.Canvas = CreateCanvas(0,0,ClientWidth(window),ClientHeight(window),window)
		SetGadgetLayout(canvas, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED)
		ActivateGadget(canvas)
	EndMethod
	
	Method Update(machine:TCHIP8Machine)
		While PollEvent()
			Select EventID()
				Case EVENT_KEYDOWN
					machine.SetKeyState(EventData(), True)
					
				Case EVENT_KEYUP
					machine.SetKeyState(EventData(), False)
					
				Case EVENT_GADGETPAINT
					SetGraphics(CanvasGraphics(Self.Canvas))
					SetViewport(0,0, ClientWidth(Self.Canvas), ClientHeight(Self.Canvas))
					Cls()
					machine.Render()
					DrawImageRect(machine.Renderer.Image, 0, 0, GraphicsWidth(), GraphicsHeight())
					Flip(1)
					
				Case EVENT_WINDOWACCEPT
					If Not Machine.LoadROM(EventText()) Then
						Notify("Unable to load ~q"+EventText()+"~q")
					EndIf
					
				Case EVENT_WINDOWCLOSE
					FreeGadget(Self.Canvas)
					End
					
				Case EVENT_APPTERMINATE
					End
			EndSelect
		Wend
		
		RedrawGadget(Self.Canvas)
	EndMethod
EndType