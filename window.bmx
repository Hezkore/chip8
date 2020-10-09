SuperStrict

Import maxgui.drivers
Import brl.eventqueue

Import "machine.bmx"

Type TWindow
	
	Field Title:String = "BlitzMax CHIP-8 Emulator"
	Field Window:TGadget
	Field Canvas:TGadget
	
	Method New()	
		Self.Window = CreateWindow( Self.Title,..
		0,0,64*14,32*14,Null,..
		WINDOW_RESIZABLE|WINDOW_CENTER|WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS)
		
		Self.Canvas = CreateCanvas(0,0,ClientWidth(window),ClientHeight(window),window)
		SetGadgetLayout( canvas, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		ActivateGadget( canvas )
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
					SetViewport( 0,0, ClientWidth(Self.Canvas), ClientHeight(Self.Canvas) )
					
					'SetBlend(ALPHABLEND)
					'testRenderer.SetColor()
					Cls()
					machine.Render()
					rem
					testRenderer.Render()
					
					' Cell shadow
					SetAlpha(0.5)
					DrawImageRect(testRenderer.ImageBlur, GraphicsWidth() *.005, GraphicsHeight() *.0075, GraphicsWidth(), GraphicsHeight())
					
					' Cell spread
					SetAlpha(0.5)
					DrawImageRect(testRenderer.ImageBlur, 0, 0, GraphicsWidth(), GraphicsHeight())
					
					' Scanlines
					Local scanStep:Float = GraphicsHeight() / testRenderer.Height
					For Local y:Int = 0 Until GraphicsHeight() / scanStep
						SetBlend(LIGHTBLEND)
						SetAlpha(0.012)
						SetColor(255, 255, 255)
						DrawLine(0, y * scanStep + 1, GraphicsWidth(), y * scanStep + 1)
						
						SetBlend(ALPHABLEND)
						SetAlpha(0.02)
						SetColor(0, 0, 0)
						DrawLine(0, y * scanStep, GraphicsWidth(), y * scanStep)
					Next
					
					' Cell
					testRenderer.SetColor()
					SetAlpha(1)
					DrawImageRect(testRenderer.Image, 0, 0, GraphicsWidth(), GraphicsHeight())
					endrem
					Flip(1)
					
				Case EVENT_WINDOWCLOSE
					FreeGadget(Self.Canvas)
					End
					
				Case EVENT_APPTERMINATE
					End
			EndSelect
		Wend
		
		RedrawGadget(Self.Canvas )
	EndMethod
EndType