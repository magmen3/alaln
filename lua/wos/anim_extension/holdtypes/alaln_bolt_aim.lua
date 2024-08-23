local DATA = {}
DATA.Name = "alaln_bolt_aim"
DATA.HoldType = "alaln_bolt_aim"
DATA.BaseHoldType = "ar2"
DATA.Translations = {} 

DATA.Translations[ ACT_MP_STAND_IDLE ] = {
	{ Sequence = "standaim_bolt", Weight = 1 },
}

DATA.Translations[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = {
	{ Sequence = "attack_bolt", Weight = 1 },
}

DATA.Translations[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = {
	{ Sequence = "attack_bolt", Weight = 1 },
}

DATA.Translations[ ACT_MP_CROUCHWALK ] = {
	{ Sequence = "c_crouchwalkaim_bolt", Weight = 1 },
}

DATA.Translations[ ACT_MP_WALK ] = {
	{ Sequence = "r_runaim_bolt", Weight = 1 },
}

DATA.Translations[ ACT_MP_RELOAD_STAND ] = {
	{ Sequence = "reload_bolt", Weight = 1 },
}

DATA.Translations[ ACT_MP_RELOAD_CROUCH ] = {
	{ Sequence = "reloadcrouch_bolt", Weight = 1 },
}

DATA.Translations[ ACT_MP_CROUCH_IDLE ] = {
	{ Sequence = "crouchaim_bolt", Weight = 1 },
}

DATA.Translations[ ACT_MP_RUN ] = {
	{ Sequence = "r_runaim_bolt", Weight = 1 },
}

DATA.Translations[ ACT_MP_SPRINT ] = {
	{ Sequence = "s_sprintidle_bolt", Weight = 1 },
}

DATA.Translations[ ACT_MP_JUMP ] = {
	{ Sequence = "jump_ar", Weight = 1 },
} --nil

DATA.Translations[ ACT_LAND ] = {
	{ Sequence = "wos_bs_shared_jump_land", Weight = 1 },
	{ Sequence = "jump_land", Weight = 1 },
}

wOS.AnimExtension:RegisterHoldtype( DATA )