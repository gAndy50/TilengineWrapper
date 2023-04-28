without warning
without type_check

include std/ffi.e

include tilengine.e

TLN_Init(400,240,1,0,0)

object fg = TLN_LoadTilemap("sonic/Sonic_md_fg1.tmx",NULL)

if fg = -1 then
	puts(1,"Failed to load background!\n")
	abort(0)
end if

TLN_SetLayerTilemap(0,fg)

TLN_CreateWindow(NULL,0)

while TLN_ProcessWindow() do
	TLN_DrawFrame(0)
end while

TLN_DeleteTilemap(fg)
TLN_DeleteWindow()
TLN_Deinit()
­11.0