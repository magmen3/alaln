function ScrWidth(w)
	return (w / 1920) * ScrW()
end

function ScrHeight(h)
	return (h / 1080) * ScrH()
end

local function CreateFonts()
	surface.CreateFont("alaln-hudfontvbig", {
		font = "SMODGUI",
		extended = true,
		size = ScrHeight(84),
		weight = 500,
		blursize = 0,
		scanlines = 4,
		antialias = false,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false,
	})

	surface.CreateFont("alaln-hudfontbig", {
		font = "SMODGUI",
		extended = true,
		size = ScrHeight(64),
		weight = 500,
		blursize = 0,
		scanlines = 3,
		antialias = false,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false,
	})

	surface.CreateFont("alaln-hudfontsmall", {
		font = "SMODGUI",
		extended = true,
		size = ScrHeight(32),
		weight = 500,
		blursize = 0,
		scanlines = 2,
		antialias = false,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false,
	})

	surface.CreateFont("alaln-hudfontvsmall", {
		font = "SMODGUI",
		extended = true,
		size = ScrHeight(18),
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})
end

CreateFonts()