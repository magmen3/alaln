local DATA = {}
DATA.Name = "alaln_ar_aim"
DATA.HoldType = "alaln_ar_aim"
DATA.BaseHoldType = "ar2"
DATA.Translations = {} 

DATA.Translations[ ACT_MP_STAND_IDLE ] = {
	{ Sequence = "standaim_bar", Weight = 1 },
}

DATA.Translations[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = {
	{ Sequence = "attack_bar", Weight = 1 },
}

DATA.Translations[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = {
	{ Sequence = "attack_bar", Weight = 1 },
}

DATA.Translations[ ACT_MP_CROUCHWALK ] = {
	{ Sequence = "c_crouchwalkaim_bar", Weight = 1 },
}

DATA.Translations[ ACT_MP_WALK ] = {
	{ Sequence = "r_runaim_bar", Weight = 1 },
}

DATA.Translations[ ACT_MP_RELOAD_STAND ] = {
	{ Sequence = "reload_bar", Weight = 1 },
}

DATA.Translations[ ACT_MP_RELOAD_CROUCH ] = {
	{ Sequence = "reloadcrouch_bar", Weight = 1 },
}

DATA.Translations[ ACT_MP_CROUCH_IDLE ] = {
	{ Sequence = "crouchaim_bar", Weight = 1 },
}

DATA.Translations[ ACT_MP_RUN ] = {
	{ Sequence = "r_runidle_mg", Weight = 1 }, -- r_runaim_bar
}

DATA.Translations[ ACT_MP_SPRINT ] = {
	{ Sequence = "r_runidle_mg", Weight = 1 }, -- r_runaim_bar
}

DATA.Translations[ ACT_MP_JUMP ] = {
	{ Sequence = "jump_ar", Weight = 1 },
} --nil

DATA.Translations[ ACT_LAND ] = {
	{ Sequence = "wos_bs_shared_jump_land", Weight = 1 },
	{ Sequence = "jump_land", Weight = 1 },
}

wOS.AnimExtension:RegisterHoldtype( DATA )