SuperStrict

Import brl.freeaudioaudio
'Import brl.standardio

Type TAudio
	
	Field Volume:Int = 100 ' 0 to 255
	
	Field SoundTimer:Int
	
	' Since audio is slow, we need to pad the timing a little
	' Otherwise we won't hear anything
	Field PadLongTime:Int = 2
	
	Field LongChannel:TChannel
	Field LongSound:TSound
	
	Field ShortSound:TSound
	Field ShortChannel:TChannel
	
	Method New()
		'For Local a:String = EachIn AudioDrivers()
		'	Print("Audio device found: " + a)
		'Next
		SetAudioDriver(AudioDrivers()[0])
		Self.GenerateSamples()
	EndMethod
	
	Method GenerateSamples()
		' Short
		Local length:Int = 32
		Local sample:TAudioSample = CreateAudioSample(length, 22050 / 10, SF_MONO8)
		
		For Local i:Int = 0 Until length
			sample.samples[i] = Tan(i * 360.0 / (length / 20.0)) * 127.5 + 127.5
		Next
		
		Self.ShortSound = LoadSound(sample, Null)
		Self.ShortChannel = AllocChannel()
		
		' Long
		length = 32
		sample = CreateAudioSample(length, 22050 / 10, SF_MONO8)
		
		For Local i:Int = 0 Until length
			sample.samples[i] = Tan(i * 360.0 / (length / 20.0)) * 127.5 + 127.5
		Next
		
		Self.LongSound = LoadSound(sample, SOUND_LOOP)
		Self.LongChannel = CueSound(Self.LongSound)
	EndMethod
	
	Method Play(time:Int)
		Self.SoundTimer = time
		If Self.SoundTimer <= 0 Return
		
		' Is this a short or long sound?
		If Self.SoundTimer <= 1 Then
			' Short
			Self.SoundTimer = 0
			SetChannelVolume(Self.ShortChannel, Self.Volume / 255.0)
			PlaySound(Self.ShortSound, Self.ShortChannel)
		Else
			' Long
			Self.SoundTimer:+Self.PadLongTime
			SetChannelVolume(Self.LongChannel, Self.Volume / 255.0)
			ResumeChannel(Self.LongChannel)
		EndIf
	EndMethod
	
	Method Update()
		If Self.SoundTimer > 1 Then
			Self.SoundTimer:-1
		Else
			PauseChannel(Self.LongChannel)
		EndIf
	EndMethod
EndType
