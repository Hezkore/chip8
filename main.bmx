SuperStrict

Framework brl.glmax2d
Import brl.standardio
Import brl.retro

Import "renderer.bmx"
Import "input.bmx"
Import "cpu.bmx"
Import "audio.bmx"

Local testRenderer:TRenderer = New TRenderer

AppTitle = "BlitzMax CHIP-8 Emulator"
Graphics(testRenderer.WIDTH * 14, testRenderer.HEIGHT * 14, 0)

Local testInput:TInput = New TInput

Local testAudio:TAudio = New TAudio

Local testCPU:TCPU = New TCPU(testRenderer, testInput, testAudio)

testCPU.LoadROM("dev\RUSH_HOUR")

Local hertz:Int = 60
Local hertzInterval:Double = 1000.0 / hertz
Local hertzNow:Int = Millisecs()
Local hertzLast:Int = hertzNow
Local hertzElapsed:Int
Local hertzStep:Int

While Not AppTerminate() And Not KeyDown(KEY_ESCAPE)
	
	testInput.SetKeyStates()
	
	hertzNow = Millisecs()
	hertzElapsed:+hertzNow - hertzLast
	hertzLast = hertzNow
	While hertzElapsed >= hertzInterval
		hertzElapsed:-hertzInterval
		hertzStep:+1
		testCPU.Cycle()
	WEnd
	
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
	
	Flip(0)
WEnd
End