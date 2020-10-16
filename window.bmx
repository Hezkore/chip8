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
					'If EventData() = KEY_SPACE Then
					'	Local txt:String
					'	For Local o:TOpcode = EachIn machine.CPU.RegisteredOpcodes
					'		txt:+o.PseudoCode
					'		txt:+" (" + o.Uses + ")"
					'		txt:+"~n"
					'	Next
					'	Print txt
					'EndIf
					
				Case EVENT_KEYUP
					machine.SetKeyState(EventData(), False)
					
				Case EVENT_GADGETPAINT
					SetGraphics(CanvasGraphics(Self.Canvas))
					SetViewport(0,0, ClientWidth(Self.Canvas), ClientHeight(Self.Canvas))
					SetBlend(ALPHABLEND)
					Cls()
					machine.Render()
					
					' Shadow
					SetAlpha(0.45)
					SetColor(machine.Renderer.Foreground[0]*.5, machine.Renderer.Foreground[1]*.5, machine.Renderer.Foreground[2]*.5)
					DrawImageRect(machine.Renderer.ImageBlur, GraphicsWidth()*.004, GraphicsHeight()*.0065, GraphicsWidth(), GraphicsHeight())
					
					' Cell
					machine.Renderer.SetColor()
					SetAlpha(1)
					DrawImageRect(machine.Renderer.Image, 0, 0, GraphicsWidth(), GraphicsHeight())
					
					' Scanlines
					SetAlpha(0.2)
					SetColor(machine.Renderer.Background[0], machine.Renderer.Background[1], machine.Renderer.Background[2])
					Local scanStep:Float = GraphicsHeight() / machine.Renderer.Height
					For Local y:Int = 0 Until GraphicsHeight() / scanStep
						DrawLine(0, y * scanStep, GraphicsWidth(), y * scanStep)
					Next
					scanStep = GraphicsWidth() / machine.Renderer.Width
					For Local x:Int = 0 Until GraphicsWidth() / scanStep
						DrawLine(x * scanStep, 0, x * scanStep, GraphicsHeight())
					Next
					
					' Bleed
					machine.Renderer.SetColor()
					SetAlpha(0.5)
					DrawImageRect(machine.Renderer.ImageBlur, 0, 0, GraphicsWidth(), GraphicsHeight())
					
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