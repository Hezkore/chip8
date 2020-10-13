SuperStrict

Import brl.glmax2D

Type TRenderer
	
	Field Width:Byte
	Field Height:Byte
	Field Pixels:Byte[,]
	Field Pixmap:TPixmap
	Field Image:TImage
	Field ImageBlur:TImage
	Field Dirty:Int = True
	Field Foreground:Int[3]
	Field Background:Int[3]
	
	Method New()
		
		' Blue
		Self.Foreground = [36, 109, 145]
		Self.Background = [129, 165, 162]
		
		' Green
		'Self.Foreground = [174, 204, 159]
		'Self.Background = [120, 124, 116]
		
		Self.ChangeResolution(64, 32)
	EndMethod
	
	Method SetColor()
		SetColor(Self.Foreground[0], Self.Foreground[1], Self.Foreground[2])
		SetClsColor(Self.Background[0], Self.Background[1], Self.Background[2])
	EndMethod
	
	Method ChangeResolution(width:Int, height:Int)
		Self.Dirty = True
		Self.Width = width
		Self.Height = height
		Self.Pixels = New Byte[Self.Width, Self.Height]
		Self.Pixmap = CreatePixmap(Self.Width, Self.Height, PF_A8)
	EndMethod
	
	Method TogglePixel:Byte(x:Int, y:Int)
		' So every emulator seems to handle this differently
		
		' This seems to behave pretty well..
		If x >= Self.Width Then
			y:+x / Self.Width
			x:-Self.Width * (x / Self.Width)
		EndIf
		
		' Abort!
		If x < 0 Return 0
		If y < 0 Return 0
		If x >= Self.Width Return 0
		If y >= Self.Height Return 0
		
		
		Self.Pixels[x, y] = Not Self.Pixels[x, y]
		Self.Dirty = True
		Return Not Self.Pixels[x, y]
	EndMethod
	
	Method Clear()
		' Would it be faster to just re-create the array?
		For Local x:Int = 0 Until Self.Width
		For Local y:Int = 0 Until Self.Height
			If Self.Pixels[x, y] <> 0 Then
				Self.Dirty = True
				Self.Pixels[x, y] = 0
			EndIf
		Next
		Next
	EndMethod
	
	Method RenderFromPixmap()
		If Not Self.Dirty Return
		Self.Dirty = False
		
		' Render pixels to pixmap
		For Local x:Int = 0 Until Self.Width
		For Local y:Int = 0 Until Self.Height
			Self.Pixmap.WritePixel(x, y, Self.Pixels[x, y] * - 1)
		Next
		Next
		
		' Create a blurry and sharp image from pixmap
		Self.ImageBlur = LoadImage(Self.Pixmap, FILTEREDIMAGE)
		Self.Image = LoadImage(Self.Pixmap, MASKEDIMAGE)
	EndMethod
	
	Method Render(drawWidth:Int = -1, drawHeight:Int = -1)
		If drawWidth = -1 And drawHeight = -1 Then
			drawWidth = GraphicsWidth()
			drawHeight = GraphicsHeight()
		EndIf
		Self.RenderFromPixmap()
		Self.SetColor()
		
		' Cell shadow
		SetAlpha(0.5)
		DrawImageRect(Self.ImageBlur, drawWidth *.005, drawHeight *.0075, drawWidth, drawHeight)
		
		' Cell spread
		SetAlpha(0.5)
		DrawImageRect(Self.ImageBlur, 0, 0, drawWidth, drawHeight)
		
		' Scanlines
		Local scanStep:Float = drawHeight / Self.Height
		For Local y:Int = 0 Until drawHeight / scanStep
			SetBlend(LIGHTBLEND)
			SetAlpha(0.012)
			SetColor(255, 255, 255)
			DrawLine(0, y * scanStep + 1, drawWidth, y * scanStep + 1)
			
			SetBlend(ALPHABLEND)
			SetAlpha(0.02)
			SetColor(0, 0, 0)
			DrawLine(0, y * scanStep, drawWidth, y * scanStep)
		Next
		
		' Cell
		Self.SetColor()
		SetAlpha(1)
		DrawImageRect(Self.Image, 0, 0, drawWidth, drawHeight)
	EndMethod
	
	Method Reset()
		Self.Clear()
	EndMethod
EndType