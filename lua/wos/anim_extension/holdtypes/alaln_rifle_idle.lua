local DATA = {}
DATA.Name = "alaln_rifle_idle"
DATA.HoldType = "alaln_rifle_idle"
DATA.BaseHoldType = "ar2"
DATA.Translations = {} 

DATA.Translations[ ACT_MP_STAND_IDLE ] = {
	{ Sequence = "standidle_rifle", Weight = 1 },
}

DATA.Translations[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = {
	{ Sequence = "attack_rifle", Weight = 1 },
}

DATA.Translations[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = {
	{ Sequence = "attack_rifle", Weight = 1 },
}

DATA.Translations[ ACT_MP_CROUCHWALK ] = {
	{ Sequence = "c_crouchwalkidle_rifle", Weight = 1 },
}

DATA.Translations[ ACT_MP_WALK ] = {
	{ Sequence = "r_runidle_rifle", Weight = 1 },
}

DATA.Translations[ ACT_MP_RELOAD_STAND ] = {
	{ Sequence = "reload_rifle", Weight = 1 },
}

DATA.Translations[ ACT_MP_RELOAD_CROUCH ] = {
	{ Sequence = "reloadcrouch_rifle", Weight = 1 },
}

DATA.Translations[ ACT_MP_CROUCH_IDLE ] = {
	{ Sequence = "crouchidle_rifle", Weight = 1 },
}

DATA.Translations[ ACT_MP_RUN ] = {
	{ Sequence = "r_runidle_mg", Weight = 1 }, -- r_runidle_mg
}

DATA.Translations[ ACT_MP_SPRINT ] = {
	{ Sequence = "r_runidle_mg", Weight = 1 }, -- r_runidle_mg
}

DATA.Translations[ ACT_MP_JUMP ] = {
	{ Sequence = "jump_ar", Weight = 1 },
} --nil

DATA.Translations[ ACT_LAND ] = {
	{ Sequence = "wos_bs_shared_jump_land", Weight = 1 },
	{ Sequence = "jump_land", Weight = 1 },
}

wOS.AnimExtension:RegisterHoldtype( DATA )