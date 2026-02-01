--Eu Tile Engine
--Written by Andy P.
--Icy Viking Games
--Copyright (c) 2026

without warning

include std/ffi.e
include std/machine.e
include std/os.e
include std/math.e

public atom tile = 0

ifdef WINDOWS then
	tile = open_dll("Tilengine.dll")
	elsifdef LINUX or FREEBSD then
	tile = open_dll("libTilengine.so")
	elsifdef OSX then
	tile = open_dll("Tilengine.dylib")
end ifdef

--Flags
public constant TILENGINE_VER_MAJ = 2,
				TILENGINE_VER_MIN = 14,
				TILENGINE_VER_REV = 0
				
public constant TILENGINE_HEADER_VERSION = or_all({shift_bits(TILENGINE_VER_MAJ,-16),shift_bits(TILENGINE_VER_MIN,-8), TILENGINE_VER_REV})

public constant FLAG_NONE = 0,
				FLAG_FLIPX = shift_bits(1,-15),
				FLAG_FLIPY = shift_bits(1,-14),
				FLAG_ROTATE = shift_bits(1,-13),
				FLAG_PRIORITY = shift_bits(1,-12),
				FLAG_MASKED = shift_bits(1,-11),
				FLAG_TILESET = shift_bits(7,-8),
				FLAG_PALETTE = shift_bits(7,-5)
				
public enum type TLN_Blend
	BLEND_NONE = 0,
	BLEND_MIX25,
	BLEND_MIX50,
	BLEND_MIX75,
	BLEND_ADD,
	BLEND_SUB,
	BLEND_MOD,
	BLEND_CUSTOM,
	MAX_BLEND,
	BLEND_MIX = BLEND_MIX50
end type

public enum type TLN_LayerType
	LAYER_NONE = 0,
	LAYER_TILE,
	LAYER_OBJECT,
	LAYER_BITMAP
end type

--Structs
public constant TLN_Affine = define_c_struct({
	C_FLOAT, --angle
	C_FLOAT, --dx
	C_FLOAT, --dy
	C_FLOAT, --sx
	C_FLOAT --sy
})

public constant Tile = define_c_union({
	C_UINT32, --value
	C_UINT16, --index
	C_UINT16, --flags
	C_UINT8, --unused,
	C_UINT8, --palette
	C_UINT8, --tileset
	C_BOOL, --masked
	C_BOOL, --priority,
	C_BOOL, --rotated
	C_BOOL, --flipy
	C_BOOL --flipx
})

public constant TLN_SequenceFrame = define_c_struct({
	C_INT, --index
	C_INT --delay
})

public constant TLN_ColorStrip = define_c_struct({
	C_INT, --delay
	C_UINT8, --first
	C_UINT8, --count
	C_UINT8 --dir
})

public constant TLN_SequenceInfo = define_c_struct({
	{C_CHAR,32}, --name
	C_INT --num_frames
})

public constant TLN_SpriteData = define_c_struct({
	{C_CHAR,64}, --name
	C_INT, --x
	C_INT, --y
	C_INT, --w
	C_INT --h
})

public constant TLN_SpriteInfo = define_c_struct({
	C_INT, --w
	C_INT --h
})

public constant TLN_TileInfo = define_c_struct({
	C_UINT16, --index
	C_UINT16, --flags
	C_INT, --row
	C_INT, --col
	C_INT, --xoffset
	C_INT, --yoffset
	C_UINT8, --color
	C_UINT8, --type
	C_BOOL --empty
})

public constant TLN_ObjectInfo = define_c_struct({
	C_UINT16, --id
	C_UINT16, --gid
	C_UINT16, --flags
	C_INT, --x
	C_INT, --y
	C_INT, --width
	C_INT, --height
	C_UINT8, --type
	C_BOOL, --visible
	{C_CHAR,64} --name
})

public constant TLN_TileAttributes = define_c_struct({
	C_UINT8, --type
	C_BOOL --priority
})

public enum type TLN_CRT
	TLN_CRT_SLOT = 0,
	TLN_CRT_APERTURE,
	TLN_CRT_SHADOW
end type

public constant TLN_PixelMap = define_c_struct({
	C_INT16, --dx
	C_INT16 --dy
})

public constant TLN_TileImage = define_c_struct({
	C_POINTER, --bitmap
	C_UINT16, --id
	C_UINT16 --type
})

public constant TLN_SpriteState = define_c_struct({
	C_INT, --x
	C_INT, --y
	C_INT, --w
	C_INT, --h
	C_UINT32, --flags
	C_POINTER, --palette
	C_POINTER, --spriteset
	C_INT, --index
	C_BOOL, --enabled
	C_BOOL --collision
})

--Flags Cont
public enum type TLN_Player
	PLAYER1 = 0,
	PLAYER2,
	PLAYER3,
	PLAYER4
end type

public constant INPUT_NONE = 0,
				INPUT_UP = 1,
				INPUT_DOWN = 2,
				INPUT_LEFT = 3,
				INPUT_RIGHT = 4,
				INPUT_BUTTON1 = 5,
				INPUT_BUTTON2 = 6,
				INPUT_BUTTON3 = 7,
				INPUT_BUTTON4 = 8,
				INPUT_BUTTON5 = 9,
				INPUT_BUTTON6 = 10,
				INPUT_START = 11,
				INPUT_QUIT = 12,
				INPUT_CRT = 13,
				INPUT_P1 = shift_bits(PLAYER1,-5),
				INPUT_P2 = shift_bits(PLAYER2,-5),
				INPUT_P3 = shift_bits(PLAYER3,-5),
				INPUT_P4 = shift_bits(PLAYER4,-5)
				
public constant CWF_FULLSCREEN = shift_bits(1,0),
				CWF_VSYNC = shift_bits(1,-1),
				CWF_S1 = shift_bits(1,-2),
				CWF_S2 = shift_bits(2,-2),
				CWF_S3 = shift_bits(3,-2),
				CWF_S4 = shift_bits(4,-2),
				CWF_S5 = shift_bits(5,-2),
				CWF_NEAREST = shift_bits(1,-6)
				
public enum type TLN_Error
	TLN_ERR_OK = 0,
	TLN_ERR_OUT_OF_MEMORY,
	TLN_ERR_IDX_LAYER,
	TLN_ERR_IDX_SPRITE,
	TLN_ERR_IDX_ANIMATION,
	TLN_ERR_IDX_PICTURE,
	TLN_ERR_REF_TILESET,
	TLN_ERR_REF_TILEMAP,
	TLN_ERR_REF_SPRITESET,
	TLN_ERR_REF_PALETTE,
	TLN_ERR_REF_SEQUENCE,
	TLN_ERR_REF_SEQPACK,
	TLN_ERR_REF_BITMAP,
	TLN_ERR_NULL_POINTER,
	TLN_ERR_FILE_NOT_FOUND,
	TLN_ERR_WRONG_FORMAT,
	TLN_ERR_UNSUPPORTED,
	TLN_ERR_REF_LIST,
	TLN_ERR_IDX_PALETTE,
	TLN_MAX_ERR
end type

public enum type TLN_LogLevel
	TLN_LOG_NONE = 0,
	TLN_LOG_ERRORS,
	TLN_LOG_VERBOSE
end type

--Functions
		
--defgroup setup		
export constant xTLN_Init = define_c_func(tile,"+TLN_Init",{C_INT,C_INT,C_INT,C_INT,C_INT},C_POINTER)

public function TLN_Init(atom hres,atom vres,atom numlayers,atom numsprites,atom numani)
	return c_func(xTLN_Init,{hres,vres,numlayers,numsprites,numani})
end function

export constant xTLN_Deinit = define_c_proc(tile,"+TLN_Deinit",{})

public procedure TLN_Deinit()
	c_proc(xTLN_Deinit,{})
end procedure

export constant xTLN_DeleteContext = define_c_func(tile,"+TLN_DeleteContext",{C_POINTER},C_BOOL)

public function TLN_DeleteContext(atom ctx)
	return c_func(xTLN_DeleteContext,{ctx})
end function

export constant xTLN_SetContext = define_c_func(tile,"+TLN_SetContext",{C_POINTER},C_BOOL)

public function TLN_SetContext(atom ctx)
	return c_func(xTLN_SetContext,{ctx})
end function

export constant xTLN_GetContext = define_c_func(tile,"+TLN_GetContext",{},C_POINTER)

public function TLN_GetContext()
	return c_func(xTLN_GetContext,{})
end function

export constant xTLN_GetWidth = define_c_func(tile,"+TLN_GetWidth",{},C_INT)

public function TLN_GetWidth()
	return c_func(xTLN_GetWidth,{})
end function

export constant xTLN_GetHeight = define_c_func(tile,"+TLN_GetHeight",{},C_INT)

public function TLN_GetHeight()
	return c_func(xTLN_GetHeight,{})
end function

export constant xTLN_GetNumObjects = define_c_func(tile,"+TLN_GetNumObjects",{},C_UINT32)

public function TLN_GetNumObjects()
	return c_func(xTLN_GetNumObjects,{})
end function

export constant xTLN_GetUsedMemory = define_c_func(tile,"+TLN_GetUsedMemory",{},C_UINT32)

public function TLN_GetUsedMemory()
	return c_func(xTLN_GetUsedMemory,{})
end function

export constant xTLN_GetVersion = define_c_func(tile,"+TLN_GetVersion",{},C_UINT32)

public function TLN_GetVersion()
	return c_func(xTLN_GetVersion,{})
end function

export constant xTLN_GetNumLayers = define_c_func(tile,"+TLN_GetNumLayers",{},C_INT)

public function TLN_GetNumLayers()
	return c_func(xTLN_GetNumLayers,{})
end function

export constant xTLN_GetNumSprites = define_c_func(tile,"+TLN_GetNumSprites",{},C_INT)

public function TLN_GetNumSprites()
	return c_func(xTLN_GetNumSprites,{})
end function

export constant xTLN_SetBGColor = define_c_proc(tile,"+TLN_SetBGColor",{C_UINT8,C_UINT8,C_UINT8})

public procedure TLN_SetBGColor(atom r,atom g,atom b)
	c_proc(xTLN_SetBGColor,{r,g,b})
end procedure

export constant xTLN_SetBGColorFromTilemap = define_c_proc(tile,"+TLN_SetBGColorFromTilemap",{C_POINTER})

public procedure TLN_SetBGColorFromTilemap(atom tm)
	c_proc(xTLN_SetBGColorFromTilemap,{tm})
end procedure

export constant xTLN_DisableBGColor = define_c_proc(tile,"+TLN_DisableBGColor",{})

public procedure TLN_DisableBGColor()
	c_proc(xTLN_DisableBGColor,{})
end procedure

export constant xTLN_SetBGBitmap = define_c_func(tile,"+TLN_SetBGBitmap",{C_POINTER},C_BOOL)

public function TLN_SetBGBitmap(atom bit)
	return c_func(xTLN_SetBGBitmap,{bit})
end function

export constant xTLN_SetBGPalette = define_c_func(tile,"+TLN_SetBGPalette",{C_POINTER},C_BOOL)

public function TLN_SetBGPalette(atom pal)
	return c_func(xTLN_SetBGPalette,{pal})
end function

export constant xTLN_SetGlobalPalette = define_c_func(tile,"+TLN_SetGlobalPalette",{C_INT,C_POINTER},C_BOOL)

public function TLN_SetGlobalPalette(atom idx,atom pal)
	return c_func(xTLN_SetGlobalPalette,{idx,pal})
end function

export constant xTLN_SetRasterCallback = define_c_proc(tile,"+TLN_SetRasterCallback",{C_POINTER})

public procedure TLN_SetRasterCallback(atom cb)
	c_proc(xTLN_SetRasterCallback,{cb})
end procedure

export constant xTLN_SetFrameCallback = define_c_proc(tile,"+TLN_SetFrameCallback",{C_POINTER})

public procedure TLN_SetFrameCallback(atom cb)
	c_proc(xTLN_SetFrameCallback,{cb})
end procedure

export constant xTLN_SetRenderTarget = define_c_proc(tile,"+TLN_SetRenderTarget",{C_POINTER,C_INT})

public procedure TLN_SetRenderTarget(atom dat,atom pit)
	c_proc(xTLN_SetRenderTarget,{dat,pit})
end procedure

export constant xTLN_UpdateFrame = define_c_proc(tile,"+TLN_UpdateFrame",{C_INT})

public procedure TLN_UpdateFrame(atom f)
	c_proc(xTLN_UpdateFrame,{f})
end procedure

export constant xTLN_SetLoadPath = define_c_proc(tile,"+TLN_SetLoadPath",{C_STRING})

public procedure TLN_SetLoadPath(sequence p)
	c_proc(xTLN_SetLoadPath,{p})
end procedure

export constant xTLN_SetCustomBlendFunction = define_c_proc(tile,"+TLN_SetCustomBlendFunction",{C_POINTER})

public procedure TLN_SetCustomBlendFunction(atom bf)
	c_proc(xTLN_SetCustomBlendFunction,{bf})
end procedure

export constant xTLN_SetLogLevel = define_c_proc(tile,"+TLN_SetLogLevel",{C_INT})

public procedure TLN_SetLogLevel(atom l)
	c_proc(xTLN_SetLogLevel,{l})
end procedure

export constant xTLN_OpenResourcePack = define_c_func(tile,"+TLN_OpenResourcePack",{C_STRING,C_STRING},C_BOOL)

public function TLN_OpenResourcePack(sequence f,sequence k)
	return c_func(xTLN_OpenResourcePack,{f,k})
end function

export constant xTLN_CloseResourcePack = define_c_proc(tile,"+TLN_CloseResourcePack",{})

public procedure TLN_CloseResourcePack()
	c_proc(xTLN_CloseResourcePack,{})
end procedure

export constant xTLN_GetGlobalPalette = define_c_func(tile,"+TLN_GetGlobalPalette",{C_INT},C_POINTER)

public function TLN_GetGlobalPalette(atom idx)
	return c_func(xTLN_GetGlobalPalette,{idx})
end function

--defgroup errors
export constant xTLN_SetLastError = define_c_proc(tile,"+TLN_SetLastError",{C_INT})

public procedure TLN_SetLastError(atom err)
	c_proc(xTLN_SetLastError,{err})
end procedure

export constant xTLN_GetLastError = define_c_func(tile,"+TLN_GetLastError",{},C_INT)

public function TLN_GetLastError()
	return c_func(xTLN_GetLastError,{})
end function

export constant xTLN_GetErrorString = define_c_func(tile,"+TLN_GetErrorString",{C_INT},C_STRING)

public function TLN_GetErrorString(atom err)
	return c_func(xTLN_GetErrorString,{err})
end function

--defgroup window
export constant xTLN_CreateWindow = define_c_func(tile,"+TLN_CreateWindow",{C_STRING,C_INT},C_BOOL)

public function TLN_CreateWindow(object overlay,atom flags)
	return c_func(xTLN_CreateWindow,{overlay,flags})
end function

export constant xTLN_CreateWindowThread = define_c_func(tile,"+TLN_CreateWindowThread",{C_STRING,C_INT},C_BOOL)

public function TLN_CreateWindowThread(sequence overlay,atom flags)
	return c_func(xTLN_CreateWindowThread,{overlay,flags})
end function

export constant xTLN_ProcessWindow = define_c_func(tile,"+TLN_ProcessWindow",{},C_BOOL)

public function TLN_ProcessWindow()
	return c_func(xTLN_ProcessWindow,{})
end function

export constant xTLN_IsWindowActive = define_c_func(tile,"+TLN_IsWindowActive",{},C_BOOL)

public function TLN_IsWindowActive()
	return c_func(xTLN_IsWindowActive,{})
end function

export constant xTLN_GetInput = define_c_func(tile,"+TLN_GetInput",{C_INT},C_BOOL)

public function TLN_GetInput(atom id)
	return c_func(xTLN_GetInput,{id})
end function

export constant xTLN_EnableInput = define_c_proc(tile,"+TLN_EnableInput",{C_INT,C_BOOL})

public procedure TLN_EnableInput(atom player,atom en)
	c_proc(xTLN_EnableInput,{player,en})
end procedure

export constant xTLN_AssignInputJoystick = define_c_proc(tile,"+TLN_AssignInputJoystick",{C_INT,C_INT})

public procedure TLN_AssignInputJoystick(atom player,atom idx)
	c_proc(xTLN_AssignInputJoystick,{player,idx})
end procedure

export constant xTLN_DefineInputKey = define_c_proc(tile,"+TLN_DefineInputKey",{C_INT,C_INT,C_UINT32})

public procedure TLN_DefineInputKey(atom player,atom input,atom kc)
	c_proc(xTLN_DefineInputKey,{player,input,kc})
end procedure

export constant xTLN_DefineInputButton = define_c_proc(tile,"+TLN_DefineInputButton",{C_INT,C_INT,C_UINT8})

public procedure TLN_DefineInputButton(atom player,atom input,atom jb)
	c_proc(xTLN_DefineInputButton,{player,input,jb})
end procedure

export constant xTLN_DrawFrame = define_c_proc(tile,"+TLN_DrawFrame",{C_INT})

public procedure TLN_DrawFrame(atom f)
	c_proc(xTLN_DrawFrame,{f})
end procedure

export constant xTLN_WaitRedraw = define_c_proc(tile,"+TLN_WaitRedraw",{})

public procedure TLN_WaitRedraw()
	c_proc(xTLN_WaitRedraw,{})
end procedure

export constant xTLN_DeleteWindow = define_c_proc(tile,"+TLN_DeleteWindow",{})

public procedure TLN_DeleteWindow()
	c_proc(xTLN_DeleteWindow,{})
end procedure

export constant xTLN_EnableBlur = define_c_proc(tile,"+TLN_EnableBlur",{C_BOOL})

public procedure TLN_EnableBlur(atom mode)
	c_proc(xTLN_EnableBlur,{mode})
end procedure

export constant xTLN_ConfigCRTEffect = define_c_proc(tile,"+TLN_ConfigCRTEffect",{C_INT,C_BOOL})

public procedure TLN_ConfigCRTEffect(atom t,atom b)
	c_proc(xTLN_ConfigCRTEffect,{t,b})
end procedure

export constant xTLN_EnableCRTEffect = define_c_proc(tile,"+TLN_EnableCRTEffect",{C_INT,C_UINT8,C_UINT8,C_UINT8,C_UINT8,C_UINT8,C_UINT8,C_BOOL,C_UINT8})

public procedure TLN_EnableCRTEffect(atom overlay,atom of,atom hold,atom v0,atom v1,atom v2,atom v3,atom b,atom gf)
	c_proc(xTLN_EnableCRTEffect,{overlay,of,hold,v0,v1,v2,v3,b,gf})
end procedure

export constant xTLN_DisableCRTEffect = define_c_proc(tile,"+TLN_DisableCRTEffect",{})

public procedure TLN_DisableCRTEffect()
	c_proc(xTLN_DisableCRTEffect,{})
end procedure

export constant xTLN_SetSDLCallback = define_c_proc(tile,"+TLN_SetSDLCallback",{C_POINTER})

public procedure TLN_SetSDLCallback(atom cb)
	c_proc(xTLN_SetSDLCallback,{cb})
end procedure

export constant xTLN_Delay = define_c_proc(tile,"+TLN_Delay",{C_UINT32})

public procedure TLN_Delay(atom s)
	c_proc(xTLN_Delay,{s})
end procedure

export constant xTLN_GetTicks = define_c_func(tile,"+TLN_GetTicks",{},C_UINT32)

public function TLN_GetTicks()
	return c_func(xTLN_GetTicks,{})
end function

export constant xTLN_GetWindowWidth = define_c_func(tile,"+TLN_GetWindowWidth",{},C_INT)

public function TLN_GetWindowWidth()
	return c_func(xTLN_GetWindowWidth,{})
end function

export constant xTLN_GetWindowHeight = define_c_func(tile,"+TLN_GetWindowHeight",{},C_INT)

public function TLN_GetWindowHeight()
	return c_func(xTLN_GetWindowHeight,{})
end function

--defgroup spriteset
export constant xTLN_CreateSpriteset = define_c_func(tile,"+TLN_CreateSpriteset",{C_POINTER,C_POINTER,C_INT},C_POINTER)

public function TLN_CreateSpriteset(atom bit,atom dat,atom num)
	return c_func(xTLN_CreateSpriteset,{bit,dat,num})
end function

export constant xTLN_LoadSpriteset = define_c_func(tile,"+TLN_LoadSpriteset",{C_STRING},C_POINTER)

public function TLN_LoadSpriteset(sequence name)
	return c_func(xTLN_LoadSpriteset,{name})
end function

export constant xTLN_CloneSpriteset = define_c_func(tile,"+TLN_CloneSpriteset",{C_POINTER},C_POINTER)

public function TLN_CloneSpriteset(atom src)
	return c_func(xTLN_CloneSpriteset,{src})
end function

export constant xTLN_GetSpriteInfo = define_c_func(tile,"+TLN_GetSpriteInfo",{C_POINTER,C_INT,C_POINTER},C_BOOL)

public function TLN_GetSpriteInfo(atom set,atom ent,atom info)
	return c_func(xTLN_GetSpriteInfo,{set,ent,info})
end function

export constant xTLN_GetSpritesetPalette = define_c_func(tile,"+TLN_GetSpritesetPalette",{C_POINTER},C_POINTER)

public function TLN_GetSpritesetPalette(atom set)
	return c_func(xTLN_GetSpritesetPalette,{set})
end function

export constant xTLN_FindSpritesetSprite = define_c_func(tile,"+TLN_FindSpritesetSprite",{C_POINTER,C_STRING},C_INT)

public function TLN_FindSpritesetSprite(atom set,sequence name)
	return c_func(xTLN_FindSpritesetSprite,{set,name})
end function

export constant xTLN_SetSpritesetData = define_c_func(tile,"+TLN_SetSpritesetData",{C_POINTER,C_INT,C_POINTER,C_POINTER,C_INT},C_BOOL)

public function TLN_SetSpritesetData(atom set,atom ent,atom data,atom pix,atom pit)
	return c_func(xTLN_SetSpritesetData,{set,ent,data,pix,pit})
end function

export constant xTLN_DeleteSpriteset = define_c_func(tile,"+TLN_DeleteSpriteset",{C_POINTER},C_BOOL)

public function TLN_DeleteSpriteset(atom set)
	return c_func(xTLN_DeleteSpriteset,{set})
end function

--defgroup tileset
export constant xTLN_CreateTileset = define_c_func(tile,"+TLN_CreateTileset",{C_INT,C_INT,C_INT,C_POINTER,C_POINTER,C_POINTER},C_POINTER)

public function TLN_CreateTileset(atom num,atom w,atom h,atom pal,atom sp,atom att)
	return c_func(xTLN_CreateTileset,{num,w,h,pal,sp,att})
end function

export constant xTLN_CreateImageTileset = define_c_func(tile,"+TLN_CreateImageTileset",{C_INT,C_POINTER},C_POINTER)

public function TLN_CreateImageTileset(atom num,atom img)
	return c_func(xTLN_CreateImageTileset,{num,img})
end function

export constant xTLN_LoadTileset = define_c_func(tile,"+TLN_LoadTileset",{C_STRING},C_POINTER)

public function TLN_LoadTileset(sequence name)
	return c_func(xTLN_LoadTileset,{name})
end function

export constant xTLN_CloneTileset = define_c_func(tile,"+TLN_CloneTileset",{C_POINTER},C_POINTER)

public function TLN_CloneTileset(atom src)
	return c_func(xTLN_CloneTileset,{src})
end function

export constant xTLN_SetTilesetPixels = define_c_func(tile,"+TLN_SetTilesetPixels",{C_POINTER,C_INT,C_POINTER,C_INT},C_BOOL)

public function TLN_SetTilesetPixels(atom set,atom ent,atom src,atom pit)
	return c_func(xTLN_SetTilesetPixels,{set,ent,src,pit})
end function

export constant xTLN_GetTileWidth = define_c_func(tile,"+TLN_GetTileWidth",{C_POINTER},C_INT)

public function TLN_GetTileWidth(atom ts)
	return c_func(xTLN_GetTileWidth,{ts})
end function

export constant xTLN_GetTileHeight = define_c_func(tile,"+TLN_GetTileHeight",{C_POINTER},C_INT)

public function TLN_GetTileHeight(atom ts)
	return c_func(xTLN_GetTileHeight,{ts})
end function

export constant xTLN_GetTilesetNumTiles = define_c_func(tile,"+TLN_GetTilesetNumTiles",{C_POINTER},C_INT)

public function TLN_GetTilesetNumTiles(atom ts)
	return c_func(xTLN_GetTilesetNumTiles,{ts})
end function

export constant xTLN_GetTilesetPalette = define_c_func(tile,"+TLN_GetTilesetPalette",{C_POINTER},C_POINTER)

public function TLN_GetTilesetPalette(atom ts)
	return c_func(xTLN_GetTilesetPalette,{ts})
end function

export constant xTLN_GetTilesetSequencePack = define_c_func(tile,"+TLN_GetTilesetSequencePack",{C_POINTER},C_POINTER)

public function TLN_GetTilesetSequencePack(atom ts)
	return c_func(xTLN_GetTilesetSequencePack,{ts})
end function

export constant xTLN_DeleteTileset = define_c_func(tile,"+TLN_DeleteTileset",{C_POINTER},C_BOOL)

public function TLN_DeleteTileset(atom ts)
	return c_func(xTLN_DeleteTileset,{ts})
end function

--defgroup tilemap
export constant xTLN_CreateTilemap = define_c_func(tile,"+TLN_CreateTilemap",{C_INT,C_INT,C_POINTER,C_UINT32,C_POINTER},C_POINTER)

public function TLN_CreateTilemap(atom rows,atom cols,atom tiles,atom bgcol,atom ts)
	return c_func(xTLN_CreateTilemap,{rows,cols,tiles,bgcol,ts})
end function

export constant xTLN_LoadTilemap = define_c_func(tile,"+TLN_LoadTilemap",{C_STRING,C_STRING},C_POINTER)

public function TLN_LoadTilemap(object fname,object lname)
	return c_func(xTLN_LoadTilemap,{fname,lname})
end function

export constant xTLN_CloneTilemap = define_c_func(tile,"+TLN_CloneTilemap",{C_POINTER},C_POINTER)

public function TLN_CloneTilemap(atom src)
	return c_func(xTLN_CloneTilemap,{src})
end function

export constant xTLN_GetTilemapRows = define_c_func(tile,"+TLN_GetTilemapRows",{C_POINTER},C_INT)

public function TLN_GetTilemapRows(atom tm)
	return c_func(xTLN_GetTilemapRows,{tm})
end function

export constant xTLN_GetTilemapCols = define_c_func(tile,"+TLN_GetTilemapCols",{C_POINTER},C_INT)

public function TLN_GetTilemapCols(atom tm)
	return c_func(xTLN_GetTilemapCols,{tm})
end function

export constant xTLN_SetTilemapTileset = define_c_func(tile,"+TLN_SetTilemapTileset",{C_POINTER,C_POINTER},C_BOOL)

public function TLN_SetTilemapTileset(atom tm,atom ts)
	return c_func(xTLN_SetTilemapTileset,{tm,ts})
end function

export constant xTLN_GetTilemapTileset = define_c_func(tile,"+TLN_GetTilemapTileset",{C_POINTER},C_POINTER)

public function TLN_GetTilemapTileset(atom tm)
	return c_func(xTLN_GetTilemapTileset,{tm})
end function

export constant xTLN_SetTilemapTileset2 = define_c_func(tile,"+TLN_SetTilemapTileset2",{C_POINTER,C_POINTER},C_BOOL)

public function TLN_SetTilemapTileset2(atom tm,atom ts)
	return c_func(xTLN_SetTilemapTileset2,{tm,ts})
end function

export constant xTLN_GetTilemapTileset2 = define_c_func(tile,"+TLN_GetTilemapTileset2",{C_POINTER},C_POINTER)

public function TLN_GetTilemapTileset2(atom tm)
	return c_func(xTLN_GetTilemapTileset2,{tm})
end function

export constant xTLN_GetTilemapTile = define_c_func(tile,"+TLN_GetTilemapTile",{C_POINTER,C_INT,C_INT,C_POINTER},C_BOOL)

public function TLN_GetTilemapTile(atom tm,atom row,atom col,atom t)
	return c_func(xTLN_GetTilemapTile,{tm,row,col,t})
end function

export constant xTLN_SetTilemapTile = define_c_func(tile,"+TLN_SetTilemapTile",{C_POINTER,C_INT,C_INT,C_POINTER},C_BOOL)

public function TLN_SetTilemapTile(atom tm,atom row,atom col,atom t)
	return c_func(xTLN_SetTilemapTile,{tm,row,col,t})
end function

export constant xTLN_CopyTiles = define_c_func(tile,"+TLN_CopyTiles",{C_POINTER,C_INT,C_INT,C_INT,C_INT,C_POINTER,C_INT,C_INT},C_BOOL)

public function TLN_CopyTiles(atom src,atom srcrow,atom srccol,atom rows,atom cols,atom dst,atom dstrow,atom dstcol)
	return c_func(xTLN_CopyTiles,{src,srcrow,srccol,rows,cols,dst,dstrow,dstcol})
end function

export constant xTLN_GetTilemapTiles = define_c_func(tile,"+TLN_GetTilemapTiles",{C_POINTER,C_INT,C_INT},C_POINTER)

public function TLN_GetTilemapTiles(atom tm,atom row,atom col)
	return c_func(xTLN_GetTilemapTiles,{tm,row,col})
end function

export constant xTLN_DeleteTilemap = define_c_func(tile,"+TLN_DeleteTilemap",{C_POINTER},C_BOOL)

public function TLN_DeleteTilemap(atom tm)
	return c_func(xTLN_DeleteTilemap,{tm})
end function

--defgroup palette
export constant xTLN_CreatePalette = define_c_func(tile,"+TLN_CreatePalette",{C_INT},C_POINTER)

public function TLN_CreatePalette(atom entries)
	return c_func(xTLN_CreatePalette,{entries})
end function

export constant xTLN_LoadPalette = define_c_func(tile,"+TLN_LoadPalette",{C_STRING},C_POINTER)

public function TLN_LoadPalette(sequence fname)
	return c_func(xTLN_LoadPalette,{fname})
end function

export constant xTLN_ClonePalette = define_c_func(tile,"+TLN_ClonePalette",{C_POINTER},C_POINTER)

public function TLN_ClonePalette(atom src)
	return c_func(xTLN_ClonePalette,{src})
end function

export constant xTLN_SetPaletteColor = define_c_func(tile,"+TLN_SetPaletteColor",{C_POINTER,C_INT,C_UINT8,C_UINT8,C_UINT8},C_BOOL)

public function TLN_SetPaletteColor(atom pal,atom col,atom r,atom g,atom b)
	return c_func(xTLN_SetPaletteColor,{pal,col,r,g,b})
end function

export constant xTLN_MixPalettes = define_c_func(tile,"+TLN_MixPalettes",{C_POINTER,C_POINTER,C_POINTER,C_UINT8},C_BOOL)

public function TLN_MixPalettes(atom src,atom src2,atom dst,atom fac)
	return c_func(xTLN_MixPalettes,{src,src2,dst,fac})
end function

export constant xTLN_AddPaletteColor = define_c_func(tile,"+TLN_AddPaletteColor",{C_POINTER,C_UINT8,C_UINT8,C_UINT8,C_UINT8,C_UINT8},C_BOOL)

public function TLN_AddPaletteColor(atom pal,atom r,atom g,atom b,atom st,atom num)
	return c_func(xTLN_AddPaletteColor,{pal,r,g,b,st,num})
end function

export constant xTLN_SubPaletteColor = define_c_func(tile,"+TLN_SubPaletteColor",{C_POINTER,C_UINT8,C_UINT8,C_UINT8,C_UINT8,C_UINT8},C_BOOL)

public function TLN_SubPaletteColor(atom pal,atom r,atom g,atom b,atom st,atom num)
	return c_func(xTLN_SubPaletteColor,{pal,r,g,b,st,num})
end function

export constant xTLN_ModPaletteColor = define_c_func(tile,"+TLN_ModPaletteColor",{C_POINTER,C_UINT8,C_UINT8,C_UINT8,C_UINT8,C_UINT8},C_BOOL)

public function TLN_ModPaletteColor(atom pal,atom r,atom g,atom b,atom st,atom num)
	return c_func(xTLN_ModPaletteColor,{pal,r,g,b,st,num})
end function

export constant xTLN_GetPaletteData = define_c_func(tile,"+TLN_GetPaletteData",{C_POINTER,C_INT},C_POINTER)

public function TLN_GetPaletteData(atom pal,atom idx)
	return c_func(xTLN_GetPaletteData,{pal,idx})
end function

export constant xTLN_DeletePalette = define_c_func(tile,"+TLN_DeletePalette",{C_POINTER},C_BOOL)

public function TLN_DeletePalette(atom pal)
	return c_func(xTLN_DeletePalette,{pal})
end function

--defgroup bitmap
export constant xTLN_CreateBitmap = define_c_func(tile,"+TLN_CreateBitmap",{C_INT,C_INT,C_INT},C_POINTER)

public function TLN_CreateBitmap(atom w,atom h,atom b)
	return c_func(xTLN_CreateBitmap,{w,h,b})
end function
				
export constant xTLN_LoadBitmap = define_c_func(tile,"+TLN_LoadBitmap",{C_STRING},C_POINTER)

public function TLN_LoadBitmap(sequence f)
	return c_func(xTLN_LoadBitmap,{f})
end function

export constant xTLN_CloneBitmap = define_c_func(tile,"+TLN_CloneBitmap",{C_POINTER},C_POINTER)

public function TLN_CloneBitmap(atom src)
	return c_func(xTLN_CloneBitmap,{src})
end function

export constant xTLN_GetBitmapPtr = define_c_func(tile,"+TLN_GetBitmapPtr",{C_POINTER,C_INT,C_INT},C_POINTER)

public function TLN_GetBitmapPtr(atom bit,atom x,atom y)
	return c_func(xTLN_GetBitmapPtr,{bit,x,y})
end function

export constant xTLN_GetBitmapWidth = define_c_func(tile,"+TLN_GetBitmapWidth",{C_POINTER},C_INT)

public function TLN_GetBitmapWidth(atom bit)
	return c_func(xTLN_GetBitmapWidth,{bit})
end function

export constant xTLN_GetBitmapHeight = define_c_func(tile,"+TLN_GetBitmapHeight",{C_POINTER},C_INT)

public function TLN_GetBitmapHeight(atom bit)
	return c_func(xTLN_GetBitmapHeight,{bit})
end function

export constant xTLN_GetBitmapDepth = define_c_func(tile,"+TLN_GetBitmapDepth",{C_POINTER},C_INT)

public function TLN_GetBitmapDepth(atom bit)
	return c_func(xTLN_GetBitmapDepth,{bit})
end function

export constant xTLN_GetBitmapPitch = define_c_func(tile,"+TLN_GetBitmapPitch",{C_POINTER},C_INT)

public function TLN_GetBitmapPitch(atom bit)
	return c_func(xTLN_GetBitmapPitch,{bit})
end function

export constant xTLN_GetBitmapPalette = define_c_func(tile,"+TLN_GetBitmapPalette",{C_POINTER},C_POINTER)

public function TLN_GetBitmapPalette(atom bit)
	return c_func(xTLN_GetBitmapPalette,{bit})
end function

export constant xTLN_SetBitmapPalette = define_c_func(tile,"+TLN_SetBitmapPalette",{C_POINTER,C_POINTER},C_BOOL)

public function TLN_SetBitmapPalette(atom bit,atom pal)
	return c_func(xTLN_SetBitmapPalette,{bit,pal})
end function

export constant xTLN_DeleteBitmap = define_c_func(tile,"+TLN_DeleteBitmap",{C_POINTER},C_BOOL)

public function TLN_DeleteBitmap(atom bit)
	return c_func(xTLN_DeleteBitmap,{bit})
end function

--defgroup objects
export constant xTLN_CreateObjectList = define_c_func(tile,"+TLN_CreateObjectList",{},C_POINTER)

public function TLN_CreateObjectList()
	return c_func(xTLN_CreateObjectList,{})
end function

export constant xTLN_AddTileObjectToList = define_c_func(tile,"+TLN_AddTileObjectToList",{C_POINTER,C_UINT16,C_UINT16,C_UINT16,C_INT,C_INT},C_BOOL)

public function TLN_AddTileObjectToList(atom list,atom id,atom gid,atom flags,atom x,atom y)
	return c_func(xTLN_AddTileObjectToList,{list,id,gid,flags,x,y})
end function

export constant xTLN_LoadObjectList = define_c_func(tile,"+TLN_LoadObjectList",{C_STRING,C_STRING},C_POINTER)

public function TLN_LoadObjectList(sequence fname,sequence lname)
	return c_func(xTLN_LoadObjectList,{fname,lname})
end function

export constant xTLN_CloneObjectList = define_c_func(tile,"+TLN_CloneObjectList",{C_POINTER},C_POINTER)

public function TLN_CloneObjectList(atom src)
	return c_func(xTLN_CloneObjectList,{src})
end function

export constant xTLN_GetListNumObjects = define_c_func(tile,"+TLN_GetListNumObjects",{C_POINTER},C_INT)

public function TLN_GetListNumObjects(atom l)
	return c_func(xTLN_GetListNumObjects,{l})
end function

export constant xTLN_GetListObject = define_c_func(tile,"+TLN_GetListObject",{C_POINTER,C_POINTER},C_BOOL)

public function TLN_GetListObject(atom list,atom info)
	return c_func(xTLN_GetListObject,{list,info})
end function

export constant xTLN_DeleteObjectList = define_c_func(tile,"+TLN_DeleteObjectList",{C_POINTER},C_BOOL)

public function TLN_DeleteObjectList(atom list)
	return c_func(xTLN_DeleteObjectList,{list})
end function

--defgroup Layer
export constant xTLN_SetLayer = define_c_func(tile,"+TLN_SetLayer",{C_INT,C_POINTER,C_POINTER},C_BOOL)

public function TLN_SetLayer(atom l,atom ts,atom tm)
	return c_func(xTLN_SetLayer,{l,ts,tm})
end function

export constant xTLN_SetLayerTilemap = define_c_func(tile,"+TLN_SetLayerTilemap",{C_INT,C_POINTER},C_BOOL)

public function TLN_SetLayerTilemap(atom l,object tm)
	return c_func(xTLN_SetLayerTilemap,{l,tm})
end function

export constant xTLN_SetLayerBitmap = define_c_func(tile,"+TLN_SetLayerBitmap",{C_INT,C_POINTER},C_BOOL)

public function TLN_SetLayerBitmap(atom l,atom bit)
	return c_func(xTLN_SetLayerBitmap,{l,bit})
end function

export constant xTLN_SetLayerPalette = define_c_func(tile,"+TLN_SetLayerPalette",{C_INT,C_POINTER},C_BOOL)

public function TLN_SetLayerPalette(atom l,atom pal)
	return c_func(xTLN_SetLayerPalette,{l,pal})
end function

export constant xTLN_SetLayerPosition = define_c_func(tile,"+TLN_SetLayerPosition",{C_INT,C_INT,C_INT},C_BOOL)

public function TLN_SetLayerPosition(atom l,atom h,atom v)
	return c_func(xTLN_SetLayerPosition,{l,h,v})
end function

export constant xTLN_SetLayerScaling = define_c_func(tile,"+TLN_SetLayerScaling",{C_INT,C_FLOAT,C_FLOAT},C_BOOL)

public function TLN_SetLayerScaling(atom l,atom x,atom y)
	return c_func(xTLN_SetLayerScaling,{l,x,y})
end function

export constant xTLN_SetLayerAffineTransform = define_c_func(tile,"+TLN_SetLayerAffineTransform",{C_INT,C_POINTER},C_BOOL)

public function TLN_SetLayerAffineTransform(atom l,atom aff)
	return c_func(xTLN_SetLayerAffineTransform,{l,aff})
end function

export constant xTLN_SetLayerTransform = define_c_func(tile,"+TLN_SetLayerTransform",{C_INT,C_FLOAT,C_FLOAT,C_FLOAT,C_FLOAT,C_FLOAT},C_BOOL)

public function TLN_SetLayerTransform(atom l,atom ang,atom dx,atom dy,atom sx,atom sy)
	return c_func(xTLN_SetLayerTransform,{l,ang,dx,dy,sx,sy})
end function

export constant xTLN_SetLayerPixelMapping = define_c_func(tile,"+TLN_SetLayerPixelMapping",{C_INT,C_POINTER},C_BOOL)

public function TLN_SetLayerPixelMapping(atom l,atom tab)
	return c_func(xTLN_SetLayerPixelMapping,{l,tab})
end function

export constant xTLN_SetLayerBlendMode = define_c_func(tile,"+TLN_SetLayerBlendMode",{C_INT,C_INT,C_UINT8},C_BOOL)

public function TLN_SetLayerBlendMode(atom l,atom mode,atom fac)
	return c_func(xTLN_SetLayerBlendMode,{l,mode,fac})
end function

export constant xTLN_SetLayerColumnOffset = define_c_func(tile,"+TLN_SetLayerColumnOffset",{C_INT,C_POINTER},C_BOOL)

public function TLN_SetLayerColumnOffset(atom l,atom off)
	return c_func(xTLN_SetLayerColumnOffset,{l,off})
end function

export constant xTLN_SetLayerClip = define_c_func(tile,"+TLN_SetLayerClip",{C_INT,C_INT,C_INT,C_INT,C_INT},C_BOOL)

public function TLN_SetLayerClip(atom l,atom x,atom y,atom x2,atom y2)
	return c_func(xTLN_SetLayerClip,{l,x,y,x2,y2})
end function

export constant xTLN_DisableLayerClip = define_c_func(tile,"+TLN_DisableLayerClip",{C_INT},C_BOOL)

public function TLN_DisableLayerClip(atom l)
	return c_func(xTLN_DisableLayerClip,{l})
end function

export constant xTLN_SetLayerWindow = define_c_func(tile,"+TLN_SetLayerWindow",{C_INT,C_INT,C_INT,C_INT,C_INT,C_BOOL},C_BOOL)

public function TLN_SetLayerWindow(atom l,atom x,atom y,atom x2,atom y2,atom invert)
	return c_func(xTLN_SetLayerWindow,{l,x,y,x2,y2,invert})
end function

export constant xTLN_SetLayerWindowColor = define_c_func(tile,"+TLN_SetLayerWindowColor",{C_INT,C_UINT8,C_UINT8,C_UINT8,C_INT},C_BOOL)

public function TLN_SetLayerWindowColor(atom l,atom r,atom g,atom b,atom blend)
	return c_func(xTLN_SetLayerWindowColor,{l,r,g,b,blend})
end function

export constant xTLN_DisableLayerWindow = define_c_func(tile,"+TLN_DisableLayerWindow",{C_INT},C_BOOL)

public function TLN_DisableLayerWindow(atom l)
	return c_func(xTLN_DisableLayerWindow,{l})
end function

export constant xTLN_DisableLayerWindowColor = define_c_func(tile,"+TLN_DisableLayerWindowColor",{C_INT},C_BOOL)

public function TLN_DisableLayerWindowColor(atom l)
	return c_func(xTLN_DisableLayerWindowColor,{l})
end function

export constant xTLN_SetLayerMosaic = define_c_func(tile,"+TLN_SetLayerMosaic",{C_INT,C_INT,C_INT},C_BOOL)

public function TLN_SetLayerMosaic(atom l,atom w,atom h)
	return c_func(xTLN_SetLayerMosaic,{l,w,h})
end function

export constant xTLN_DisableLayerMosaic = define_c_func(tile,"+TLN_DisableLayerMosaic",{C_INT},C_BOOL)

public function TLN_DisableLayerMosaic(atom l)
	return c_func(xTLN_DisableLayerMosaic,{l})
end function

export constant xTLN_ResetLayerMode = define_c_func(tile,"+TLN_ResetLayerMode",{C_INT},C_BOOL)

public function TLN_ResetLayerMode(atom l)
	return c_func(xTLN_ResetLayerMode,{l})
end function

export constant xTLN_SetLayerObjects = define_c_func(tile,"+TLN_SetLayerObjects",{C_INT,C_POINTER,C_POINTER},C_BOOL)

public function TLN_SetLayerObjects(atom l,atom obj,atom ts)
	return c_func(xTLN_SetLayerObjects,{l,obj,ts})
end function

export constant xTLN_SetLayerPriority = define_c_func(tile,"+TLN_SetLayerPriority",{C_INT,C_BOOL},C_BOOL)

public function TLN_SetLayerPriority(atom l,atom en)
	return c_func(xTLN_SetLayerPriority,{l,en})
end function

export constant xTLN_SetLayerParent = define_c_func(tile,"+TLN_SetLayerParent",{C_INT,C_INT},C_BOOL)

public function TLN_SetLayerParent(atom l,atom par)
	return c_func(xTLN_SetLayerParent,{l,par})
end function

export constant xTLN_DisableLayerParent = define_c_func(tile,"+TLN_DisableLayerParent",{C_INT},C_BOOL)

public function TLN_DisableLayerParent(atom l)
	return c_func(xTLN_DisableLayerParent,{l})
end function

export constant xTLN_EnableLayer = define_c_func(tile,"+TLN_EnableLayer",{C_INT},C_BOOL)

public function TLN_EnableLayer(atom l)
	return c_func(xTLN_EnableLayer,{l})
end function

export constant xTLN_GetLayerType = define_c_func(tile,"+TLN_GetLayerType",{C_INT},C_POINTER)

public function TLN_GetLayerType(atom l)
	return c_func(xTLN_GetLayerType,{l})
end function

export constant xTLN_GetLayerPalette = define_c_func(tile,"+TLN_GetLayerPalette",{C_INT},C_POINTER)

public function TLN_GetLayerPalette(atom l)
	return c_func(xTLN_GetLayerPalette,{l})
end function

export constant xTLN_GetLayerTileset = define_c_func(tile,"+TLN_GetLayerTileset",{C_INT},C_POINTER)

public function TLN_GetLayerTileset(atom l)
	return c_func(xTLN_GetLayerTileset,{l})
end function

export constant xTLN_GetLayerTilemap = define_c_func(tile,"+TLN_GetLayerTilemap",{C_INT},C_POINTER)

public function TLN_GetLayerTilemap(atom l)
	return c_func(xTLN_GetLayerTilemap,{l})
end function

export constant xTLN_GetLayerBitmap = define_c_func(tile,"+TLN_GetLayerBitmap",{C_INT},C_POINTER)

public function TLN_GetLayerBitmap(atom l)
	return c_func(xTLN_GetLayerBitmap,{l})
end function

export constant xTLN_GetLayerObjects = define_c_func(tile,"+TLN_GetLayerObjects",{C_INT},C_POINTER)

public function TLN_GetLayerObjects(atom l)
	return c_func(xTLN_GetLayerObjects,{l})
end function

export constant xTLN_GetLayerTile = define_c_func(tile,"+TLN_GetLayerTile",{C_INT,C_INT,C_INT,C_POINTER},C_BOOL)

public function TLN_GetLayerTile(atom l,atom x,atom y,atom info)
	return c_func(xTLN_GetLayerTile,{l,x,y,info})
end function

export constant xTLN_GetLayerWidth = define_c_func(tile,"+TLN_GetLayerWidth",{C_INT},C_INT)

public function TLN_GetLayerWidth(atom l)
	return c_func(xTLN_GetLayerWidth,{l})
end function

export constant xTLN_GetLayerHeight = define_c_func(tile,"+TLN_GetLayerHeight",{C_INT},C_INT)

public function TLN_GetLayerHeight(atom l)
	return c_func(xTLN_GetLayerHeight,{l})
end function

export constant xTLN_GetLayerX = define_c_func(tile,"+TLN_GetLayerX",{C_INT},C_INT)

public function TLN_GetLayerX(atom l)
	return c_func(xTLN_GetLayerX,{l})
end function

export constant xTLN_GetLayerY = define_c_func(tile,"+TLN_GetLayerY",{C_INT},C_INT)

public function TLN_GetLayerY(atom l)
	return c_func(xTLN_GetLayerY,{l})
end function

--defgroup sprite
export constant xTLN_ConfigSprite = define_c_func(tile,"+TLN_ConfigSprite",{C_INT,C_POINTER,C_UINT32},C_BOOL)

public function TLN_ConfigSprite(atom s,atom ss,atom flags)
	return c_func(xTLN_ConfigSprite,{s,ss,flags})
end function

export constant xTLN_SetSpriteSet = define_c_func(tile,"+TLN_SetSpriteSet",{C_INT,C_POINTER},C_BOOL)

public function TLN_SetSpriteSet(atom s,atom ss)
	return c_func(xTLN_SetSpriteSet,{s,ss})
end function

export constant xTLN_SetSpriteFlags = define_c_func(tile,"+TLN_SetSpriteFlags",{C_INT,C_UINT32},C_BOOL)

public function TLN_SetSpriteFlags(atom s,atom flags)
	return c_func(xTLN_SetSpriteFlags,{s,flags})
end function

export constant xTLN_EnableSpriteFlag = define_c_func(tile,"+TLN_EnableSpriteFlag",{C_INT,C_UINT32,C_BOOL},C_BOOL)

public function TLN_EnableSpriteFlag(atom s,atom flag,atom en)
	return c_func(xTLN_EnableSpriteFlag,{s,flag,en})
end function

export constant xTLN_SetSpritePivot = define_c_func(tile,"+TLN_SetSpritePivot",{C_INT,C_FLOAT,C_FLOAT},C_BOOL)

public function TLN_SetSpritePivot(atom s,atom x,atom y)
	return c_func(xTLN_SetSpritePivot,{s,x,y})
end function

export constant xTLN_SetSpritePosition = define_c_func(tile,"+TLN_SetSpritePosition",{C_INT,C_INT,C_INT},C_BOOL)

public function TLN_SetSpritePosition(atom s,atom x,atom y)
	return c_func(xTLN_SetSpritePosition,{s,x,y})
end function

export constant xTLN_SetSpritePicture = define_c_func(tile,"+TLN_SetSpritePicture",{C_INT,C_INT},C_BOOL)

public function TLN_SetSpritePicture(atom s,atom en)
	return c_func(xTLN_SetSpritePicture,{s,en})
end function

export constant xTLN_SetSpritePalette = define_c_func(tile,"+TLN_SetSpritePalette",{C_INT,C_POINTER},C_BOOL)

public function TLN_SetSpritePalette(atom s,atom pal)
	return c_func(xTLN_SetSpritePalette,{s,pal})
end function

export constant xTLN_SetSpriteBlendMode = define_c_func(tile,"+TLN_SetSpriteBlendMode",{C_INT,C_INT,C_UINT8},C_BOOL)

public function TLN_SetSpriteBlendMode(atom s,atom m,atom fac)
	return c_func(xTLN_SetSpriteBlendMode,{s,m,fac})
end function

export constant xTLN_SetSpriteScaling = define_c_func(tile,"+TLN_SetSpriteScaling",{C_INT,C_FLOAT,C_FLOAT},C_BOOL)

public function TLN_SetSpriteScaling(atom s,atom x,atom y)
	return c_func(xTLN_SetSpriteScaling,{s,x,y})
end function

export constant xTLN_ResetSpriteScaling = define_c_func(tile,"+TLN_ResetSpriteScaling",{C_INT},C_BOOL)

public function TLN_ResetSpriteScaling(atom s)
	return c_func(xTLN_ResetSpriteScaling,{s})
end function

export constant xTLN_GetSpritePicture = define_c_func(tile,"+TLN_GetSpritePicture",{C_INT},C_INT)

public function TLN_GetSpritePicture(atom s)
	return c_func(xTLN_GetSpritePicture,{s})
end function

export constant xTLN_GetSpriteX = define_c_func(tile,"+TLN_GetSpriteX",{C_INT},C_INT)

public function TLN_GetSpriteX(atom s)
	return c_func(xTLN_GetSpriteX,{s})
end function

export constant xTLN_GetSpriteY = define_c_func(tile,"+TLN_GetSpriteY",{C_INT},C_INT)

public function TLN_GetSpriteY(atom s)
	return c_func(xTLN_GetSpriteY,{s})
end function

export constant xTLN_GetAvailableSprite = define_c_func(tile,"+TLN_GetAvailableSprite",{},C_INT)

public function TLN_GetAvailableSprite()
	return c_func(xTLN_GetAvailableSprite,{})
end function

export constant xTLN_EnableSpriteCollision = define_c_func(tile,"+TLN_EnableSpriteCollision",{C_INT,C_BOOL},C_BOOL)

public function TLN_EnableSpriteCollision(atom s,atom en)
	return c_func(xTLN_EnableSpriteCollision,{s,en})
end function

export constant xTLN_GetSpriteCollision = define_c_func(tile,"+TLN_GetSpriteCollision",{C_INT},C_BOOL)

public function TLN_GetSpriteCollision(atom s)
	return c_func(xTLN_GetSpriteCollision,{s})
end function

export constant xTLN_GetSpriteState = define_c_func(tile,"+TLN_GetSpriteState",{C_INT,C_POINTER},C_BOOL)

public function TLN_GetSpriteState(atom s,atom st)
	return c_func(xTLN_GetSpriteState,{s,st})
end function

export constant xTLN_SetFirstSprite = define_c_func(tile,"+TLN_SetFirstSprite",{C_INT},C_BOOL)

public function TLN_SetFirstSprite(atom s)
	return c_func(xTLN_SetFirstSprite,{s})
end function

export constant xTLN_SetNextSprite = define_c_func(tile,"+TLN_SetNextSprite",{C_INT,C_INT},C_BOOL)

public function TLN_SetNextSprite(atom s,atom n)
	return c_func(xTLN_SetNextSprite,{s,n})
end function

export constant xTLN_EnableSpriteMasking = define_c_func(tile,"+TLN_EnableSpriteMasking",{C_INT,C_BOOL},C_BOOL)

public function TLN_EnableSpriteMasking(atom s,atom en)
	return c_func(xTLN_EnableSpriteMasking,{s,en})
end function

export constant xTLN_SetSpriteMaskRegion = define_c_proc(tile,"+TLN_SetSpriteMaskREgion",{C_INT,C_INT})

public procedure TLN_SetSpriteMaskRegion(atom top,atom bot)
	c_proc(xTLN_SetSpriteMaskRegion,{top,bot})
end procedure

export constant xTLN_SetSpriteAnimation = define_c_func(tile,"+TLN_SetSpriteAnimation",{C_INT,C_POINTER,C_INT},C_BOOL)

public function TLN_SetSpriteAnimation(atom s,atom seq,atom l)
	return c_func(xTLN_SetSpriteAnimation,{s,seq,l})
end function

export constant xTLN_DisableSpriteAnimation = define_c_func(tile,"+TLN_DisableSpriteAnimation",{C_INT},C_BOOL)

public function TLN_DisableSpriteAnimation(atom s)
	return c_func(xTLN_DisableSpriteAnimation,{s})
end function

export constant xTLN_PauseSpriteAnimation = define_c_func(tile,"+TLN_PauseSpriteAnimation",{C_INT},C_BOOL)

public function TLN_PauseSpriteAnimation(atom i)
	return c_func(xTLN_PauseSpriteAnimation,{i})
end function

export constant xTLN_ResumeSpriteAnimation = define_c_func(tile,"+TLN_ResumeSpriteAnimation",{C_INT},C_BOOL)

public function TLN_ResumeSpriteAnimation(atom i)
	return c_func(xTLN_ResumeSpriteAnimation,{i})
end function

export constant xTLN_DisableAnimation = define_c_func(tile,"+TLN_DisableAnimation",{C_INT},C_BOOL)

public function TLN_DisableAnimation(atom i)
	return c_func(xTLN_DisableAnimation,{i})
end function

export constant xTLN_DisableSprite = define_c_func(tile,"+TLN_DisableSprite",{C_INT},C_BOOL)

public function TLN_DisableSprite(atom i)
	return c_func(xTLN_DisableSprite,{i})
end function

export constant xTLN_GetSpritePalette = define_c_func(tile,"+TLN_GetSpritePalette",{C_INT},C_POINTER)

public function TLN_GetSpritePalette(atom s)
	return c_func(xTLN_GetSpritePalette,{s})
end function

--defgroup sequence
export constant xTLN_CreateSequence = define_c_func(tile,"+TLN_CreateSequence",{C_STRING,C_INT,C_INT,C_POINTER},C_POINTER)

public function TLN_CreateSequence(sequence name,atom target,atom num,atom frames)
	return c_func(xTLN_CreateSequence,{name,target,num,frames})
end function

export constant xTLN_CreateCycle = define_c_func(tile,"+TLN_CreateCycle",{C_STRING,C_INT,C_POINTER},C_POINTER)

public function TLN_CreateCycle(sequence name,atom num,atom strips)
	return c_func(xTLN_CreateCycle,{name,num,strips})
end function

export constant xTLN_CreateSpriteSequence = define_c_func(tile,"+TLN_CreateSpriteSequence",{C_STRING,C_POINTER,C_STRING,C_INT},C_POINTER)

public function TLN_CreateSpriteSequence(sequence name,atom ss,sequence base,atom de)
	return c_func(xTLN_CreateSpriteSequence,{name,ss,base,de})
end function

export constant xTLN_CloneSequence = define_c_func(tile,"+TLN_CloneSequence",{C_POINTER},C_POINTER)

public function TLN_CloneSequence(atom src)
	return c_func(xTLN_CloneSequence,{src})
end function

export constant xTLN_GetSequenceInfo = define_c_func(tile,"+TLN_GetSequenceInfo",{C_POINTER,C_POINTER},C_BOOL)

public function TLN_GetSequenceInfo(atom seq,atom info)
	return c_func(xTLN_GetSequenceInfo,{seq,info})
end function

export constant xTLN_DeleteSequence = define_c_func(tile,"+TLN_DeleteSequence",{C_POINTER},C_BOOL)

public function TLN_DeleteSequence(atom seq)
	return c_func(xTLN_DeleteSequence,{seq})
end function

--defgroup sequencepack
export constant xTLN_CreateSequencePack = define_c_func(tile,"+TLN_CreateSequencePack",{},C_POINTER)

public function TLN_CreateSequencePack()
	return c_func(xTLN_CreateSequencePack,{})
end function

export constant xTLN_LoadSequencePack = define_c_func(tile,"+TLN_LoadSequencePack",{C_STRING},C_POINTER)

public function TLN_LoadSequencePack(sequence fname)
	return c_func(xTLN_LoadSequencePack,{fname})
end function

export constant xTLN_GetSequence = define_c_func(tile,"+TLN_GetSequence",{C_POINTER,C_INT},C_POINTER)

public function TLN_GetSequence(atom sp,atom idx)
	return c_func(xTLN_GetSequence,{sp,idx})
end function

export constant xTLN_FindSequence = define_c_func(tile,"+TLN_FindSequence",{C_POINTER,C_STRING},C_POINTER)

public function TLN_FindSequence(atom sp,sequence name)
	return c_func(xTLN_FindSequence,{sp,name})
end function

export constant xTLN_GetSequencePackCount = define_c_func(tile,"+TLN_GetSequencePackCount",{C_POINTER},C_INT)

public function TLN_GetSequencePackCount(atom sp)
	return c_func(xTLN_GetSequencePackCount,{sp})
end function

export constant xTLN_AddSequenceToPack = define_c_func(tile,"+TLN_AddSequenceToPack",{C_POINTER,C_POINTER},C_BOOL)

public function TLN_AddSequenceToPack(atom sp,atom seq)
	return c_func(xTLN_AddSequenceToPack,{sp,seq})
end function

export constant xTLN_DeleteSequencePack = define_c_func(tile,"+TLN_DeleteSequencePack",{C_POINTER},C_BOOL)

public function TLN_DeleteSequencePack(atom sp)
	return c_func(xTLN_DeleteSequencePack,{sp})
end function

--defgroup animation
export constant xTLN_SetPaletteAnimation = define_c_func(tile,"+TLN_SetPaletteAnimation",{C_INT,C_POINTER,C_POINTER,C_BOOL},C_BOOL)

public function TLN_SetPaletteAnimation(atom idx,atom pal,atom seq,atom ble)
	return c_func(xTLN_SetPaletteAnimation,{idx,pal,seq,ble})
end function

export constant xTLN_SetPaletteAnimationSource = define_c_func(tile,"+TLN_SetPaletteAnimationSource",{C_INT,C_POINTER},C_BOOL)

public function TLN_SetPaletteAnimationSource(atom idx,atom pal)
	return c_func(xTLN_SetPaletteAnimationSource,{idx,pal})
end function

export constant xTLN_GetAnimationState = define_c_func(tile,"+TLN_GetAnimationState",{C_INT},C_BOOL)

public function TLN_GetAnimationState(atom idx)
	return c_func(xTLN_GetAnimationState,{idx})
end function

export constant xTLN_SetAnimationDelay = define_c_func(tile,"+TLN_SetAnimationDelay",{C_INT,C_INT,C_INT},C_BOOL)

public function TLN_SetAnimationDelay(atom idx,atom frame,atom de)
	return c_func(xTLN_SetAnimationDelay,{idx,frame,de})
end function

export constant xTLN_GetAvailableAnimation = define_c_func(tile,"+TLN_GetAvailableAnimation",{},C_INT)

public function TLN_GetAvailableAnimation()
	return c_func(xTLN_GetAvailableAnimation,{})
end function

export constant xTLN_DisablePaletteAnimation = define_c_func(tile,"+TLN_DisablePaletteAnimation",{C_INT},C_BOOL)

public function TLN_DisablePaletteAnimation(atom idx)
	return c_func(xTLN_DisablePaletteAnimation,{idx})
end function

--defgroup world
export constant xTLN_LoadWorld = define_c_func(tile,"+TLN_LoadWorld",{C_STRING,C_INT},C_BOOL)

public function TLN_LoadWorld(sequence tmx,atom first)
	return c_func(xTLN_LoadWorld,{tmx,first})
end function

export constant xTLN_SetWorldPosition = define_c_proc(tile,"+TLN_SetWorldPosition",{C_INT,C_INT})

public procedure TLN_SetWorldPosition(atom x,atom y)
	c_proc(xTLN_SetWorldPosition,{x,y})
end procedure

export constant xTLN_SetLayerParallaxFactor = define_c_func(tile,"+TLN_SetLayerParallaxFactor",{C_INT,C_FLOAT,C_FLOAT},C_BOOL)

public function TLN_SetLayerParallaxFactor(atom l,atom x,atom y)
	return c_func(xTLN_SetLayerParallaxFactor,{l,x,y})
end function

export constant xTLN_SetSpriteWorldPosition = define_c_func(tile,"+TLN_SetSpriteWorldPosition",{C_INT,C_INT,C_INT},C_BOOL)

public function TLN_SetSpriteWorldPosition(atom s,atom x,atom y)
	return c_func(xTLN_SetSpriteWorldPosition,{s,x,y})
end function

export constant xTLN_ReleaseWorld = define_c_proc(tile,"+TLN_ReleaseWorld",{})

public procedure TLN_ReleaseWorld()
	c_proc(xTLN_ReleaseWorld,{})
end procedure
­674.0

