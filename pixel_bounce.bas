' ----------------------------------------------------------------------
' A generic type that can drive the bouncing movement of any entity
' ----------------------------------------------------------------------
TYPE bouncer
	w  AS INT	'boundary width
	h  AS INT	'boundary height
	x  AS INT	'current horizontal position (1 < x < w)
	y  AS INT 'current vertical position (1 < y <h)
	dx AS INT 'current horizontal direction (1 or -1)
	dy AS INT 'current vertical direction (1 or -1)
	
	' Constructor (must be manually invoked)
	SUB init(w AS INT, h AS INT, x AS INT, y AS INT) STATIC
		THIS.w = w
		THIS.h = h
		THIS.x = x
		THIS.y = y
		THIS.dx = 1
		THIS.dy = 1
	END SUB
	
	' Moves the entity one pixel to the current direction
	' and reverses direction if the boundaries are hit
	SUB move() STATIC
		THIS.x = THIS.x + THIS.dx
		THIS.y = THIS.y + THIS.dy
		IF THIS.x = THIS.w OR THIS.x = 1 THEN THIS.dx = THIS.dx * -1
		IF THIS.y = THIS.h OR THIS.y = 1 THEN THIS.dy = THIS.dy * -1
	END SUB
END TYPE

' ----------------------------------------------------------------------
' A helper that's responsibility is to update the sprite's shape
' ----------------------------------------------------------------------
TYPE box_shape
	' Helper variables to calculate where the pixel is in memory
	offset  AS BYTE 'Offset within the 63-byte sprite data
	abs_ptr AS WORD	'the absolute pointer to the byte to update
	bit_pos AS BYTE 'the pixel's position within the byte
	
	' Calculation function shared by set_pixel() and unset_pixel()
	SUB calc(x AS BYTE, y AS BYTE) STATIC
		THIS.offset = 3 * y + x / 8
		THIS.bit_pos = 7 - (x - (x / 8) * 8)
		THIS.abs_ptr = $3f80 + THIS.offset
	END SUB
	
	' Unsets the pixel. This should be called prior to updating
	' the pixel's position
	SUB unset_pixel(x AS BYTE, y AS BYTE) STATIC
		CALL THIS.calc(x, y)
		POKE THIS.abs_ptr, PEEK(THIS.abs_ptr) AND NOT SHL(1, THIS.bit_pos)
	END SUB
	
	' Sets the pixel. This should be called after updating
	' the pixel's position
	SUB set_pixel(x AS BYTE, y AS BYTE) STATIC
		CALL THIS.calc(x, y)
		POKE THIS.abs_ptr, PEEK(THIS.abs_ptr) OR SHL(1, THIS.bit_pos)
	END SUB
END TYPE

' ----------------------------------------------------------------------
' Box is a wrapper around the sprite. It adds the moving and updating
' behavior to it. The box consists of the frame and the pixel
' ----------------------------------------------------------------------
TYPE box
	' The pixel and the frame both share functionality of the bouncer type
	pixel AS bouncer
	frame AS bouncer
	' The shape helper is injected here
	shape AS box_shape
	
	' Constructor (must be manually invoked)
	SUB init() STATIC
		' Initialize the frame. Its container is the screen
		CALL THIS.frame.init(272, 158, 2, 2)
		' Initialize the pixel. Its container is the frame
		CALL THIS.pixel.init(22, 19, 1, 2)
		' Initialize the sprite
		MEMCPY @sprite_shape, $3f80, 63
		SPRITE 1 COLOR 1 SHAPE 254 HIRES XYSIZE 1, 1 ON
	END SUB
	
	' Moves and animates the box
	SUB move() STATIC
		CALL THIS.shape.unset_pixel(THIS.pixel.x, THIS.pixel.y)
		CALL THIS.pixel.move()
		CALL THIS.shape.set_pixel(THIS.pixel.x, THIS.pixel.y)
		CALL THIS.frame.move()
		' Update sprite position
		SPRITE 1 AT THIS.frame.x + 23, THIS.frame.y + 49
	END SUB
END TYPE

' ----------------------------------------------------------------------
' Start of the main program
' ----------------------------------------------------------------------

' Create the bouncing box and initialize it
DIM bouncing_box AS box
CALL bouncing_box.init()

' Clear screen
PRINT "{CLR}";

' Start endless loop
DO
	' Wait until raster position goes below visible area
	DO : LOOP WHILE SCAN() < 250
	' Move and animate box
	CALL bouncing_box.move()
LOOP WHILE 1

' ----------------------------------------------------------------------
' Data area
' The shape of the empty box, 21 rows of 3 bytes
' ----------------------------------------------------------------------
sprite_shape:
DATA AS BYTE 255, 255, 255
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 128, 0, 1
DATA AS BYTE 255, 255, 255
