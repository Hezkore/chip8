SuperStrict

Import "audio.bmx"
Import "cpu.bmx"
Import "input.bmx"
Import "memory.bmx"
Import "renderer.bmx"

Type TCHIP8Machine
	
	Field CPU:TBaseCPU
	Field Audio:TAudio = New TAudio
	Field Input:TInput = New TInput
	Field Memory:TMemory = New TMemory
	Field Renderer:TRenderer = New TRenderer
	
	Private
		Field HertzInterval:Double
		Field HertzNow:Int = Millisecs()
		Field HertzLast:Int = hertzNow
		Field HertzElapsed:Int
		
		Field IsRunning:Int
	Public
	
	Method Reset()
		' Reset devices
		Self.CPU.Reset()
		Self.Audio.Reset()
		Self.Input.Reset()
		Self.Memory.Reset()
		Self.Renderer.Reset()
		
		' Reset self
		Self.IsRunning = False
		Self.ResetTiming()
	EndMethod
	
	Method ResetTiming()
		Self.HertzNow = Millisecs()
		Self.HertzLast = HertzNow
	EndMethod
	
	Method Running:Int()
		Return Self.IsRunning
	EndMethod
	
	Method LoadROM:Int(path:String)
		Self.Reset()
		Self.IsRunning = Self.Memory.LoadROM(path)
		Self.ResetTiming()
		Return Self.IsRunning
	EndMethod
	
	Method Update()
		Self.HertzInterval:Double = 1000.0 / Self.CPU.hertz
		Self.HertzNow = Millisecs()
		Self.HertzElapsed:+HertzNow - HertzLast
		Self.HertzLast = HertzNow
		While Self.HertzElapsed >= Self.HertzInterval
			Self.HertzElapsed:-Self.HertzInterval
			Self.CPU.Cycle()
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
		Self.Reset()
		Return Self.CPU
	EndMethod
	
	Method SetKeyState(key:Int, state:Int)
		Self.Input.SetKeyState(key, state)
	EndMethod
	
	Method Render(width:Int = -1, height:Int = -1)
		Self.Renderer.Render(width, height)
	EndMethod
EndType