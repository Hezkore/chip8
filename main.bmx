SuperStrict

Framework brl.glmax2d
Import maxgui.drivers
Import brl.eventqueue

Import "cpu/cpu.bmx"

Import "renderer.bmx"
Import "input.bmx"
Import "cpu.bmx"
Import "audio.bmx"

Local window:TGadget=CreateWindow("BlitzMax CHIP-8 Emulator",0,0,64*14,32*14,Null,WINDOW_RESIZABLE|WINDOW_CENTER|WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS)
Local canvas:TGadget=CreateCanvas(0,0,ClientWidth(window),ClientHeight(window),window)
SetGadgetLayout( canvas, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
ActivateGadget( canvas )

Local testRenderer:TRenderer = New TRenderer

Local testInput:TInput = New TInput

Local testAudio:TAudio = New TAudio

Local testCPU:TCPU = New TCPU(testRenderer, testInput, testAudio)

CurrentCPU = TBaseCPU.GetCPU("CHIP-8")
'Print "Current CPU is " + CurrentCPU.Name
'CurrentCPU.Execute("00E0")
'End

testCPU.LoadROM("dev\RUSH_HOUR")

Local hertz:Int = 60
Local hertzInterval:Double = 1000.0 / hertz
Local hertzNow:Int = Millisecs()
Local hertzLast:Int = hertzNow
Local hertzElapsed:Int
Local hertzStep:Int

While True
	
	hertzNow = Millisecs()
	hertzElapsed:+hertzNow - hertzLast
	hertzLast = hertzNow
	While hertzElapsed >= hertzInterval
		hertzElapsed:-hertzInterval
		hertzStep:+1
		'testCPU.Cycle()
		CurrentCPU.Cycle()
	WEnd
	
	While PollEvent()
		Select EventID()
			Case EVENT_KEYDOWN
				testInput.SetKeyState(EventData(), True)
				
			Case EVENT_KEYUP
				testInput.SetKeyState(EventData(), False)
				
			Case EVENT_GADGETPAINT
				SetGraphics(CanvasGraphics(canvas))
				SetViewport( 0,0, ClientWidth(canvas), ClientHeight(canvas) )
				
				SetBlend(ALPHABLEND)
				testRenderer.SetColor()
				Cls()
				
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
				
				Flip(1)
				
			Case EVENT_WINDOWCLOSE
				FreeGadget(canvas)
				End

			Case EVENT_APPTERMINATE
				End
		EndSelect
	Wend
	RedrawGadget( canvas )
Wend