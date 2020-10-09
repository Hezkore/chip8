SuperStrict

Import "audio.bmx"
Import "cpu/cpu.bmx"
Import "input.bmx"
Import "memory.bmx"
Import "renderer.bmx"

Type TCHIP8Machine
	
	Field Audio:TAudio = New TAudio
	Field CPU:TBaseCPU
	Field Input:TInput = New TInput
	Field Memory:TMemory = New TMemory
	Field Renderer:TRenderer = New TRenderer
	
	Field hertz:Int = 60
	Field hertzInterval:Double = 1000.0 / hertz
	Field hertzNow:Int = Millisecs()
	Field hertzLast:Int = hertzNow
	Field hertzElapsed:Int
	Field hertzStep:Int
	
	Method Running:Int()
		Return True
	EndMethod
	
	Method LoadROM:Int(path:String)
		Return Self.Memory.LoadROM(path)
	EndMethod
	
	Method Update()
		hertzNow = Millisecs()
		hertzElapsed:+hertzNow - hertzLast
		hertzLast = hertzNow
		While hertzElapsed >= hertzInterval
			hertzElapsed:-hertzInterval
			hertzStep:+1
			CPU.Cycle()
		WEnd
	EndMethod
	
	Method ChangeCPU:TBaseCPU(name:String)
		Self.CPU = TBaseCPU.GetCPU(name)
		If Self.CPU Then
			Self.CPU.AudioPtr = Self.Audio
			Self.CPU.InputPtr = Self.Input
			Self.CPU.MemoryPtr = Self.Memory
			Self.CPU.RendererPtr = Self.Renderer
		EndIf
		Return Self.CPU
	EndMethod
	
	Method SetKeyState(key:Int, state:Int)
		Self.Input.SetKeyState(key,state)
	EndMethod
	
	Method Render()
		Self.Renderer.Render()
	EndMethod
EndType