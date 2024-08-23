local DATA = {}
DATA.Name = "alaln_revolver_aim"
DATA.HoldType = "alaln_revolver_aim"
DATA.BaseHoldType = "revolver"
DATA.Translations = {}

DATA.Translations[ ACT_MP_SWIM ] = {
	{ Sequence = "sw_swimaim_bandages", Weight = 1 },
}

DATA.Translations[ ACT_MP_JUMP ] = {
	{ Sequence = "wos_aoc_jump_pistol", Weight = 1 },
}

DATA.Translations[ ACT_MP_STAND_IDLE ] = {
	{ Sequence = "standaim_revolver", Weight = 1 },
}

DATA.Translations[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = {
	{ Sequence = "attack_pistol", Weight = 1 },
}

DATA.Translations[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = {
	{ Sequence = "attack_pistol", Weight = 1 },
}

DATA.Translations[ ACT_MP_CROUCHWALK ] = {
	{ Sequence = "cwalk_pistol", Weight = 1 }, --c_crouchwalkaim_pistol
}

DATA.Translations[ ACT_MP_WALK ] = {
	{ Sequence = "w_walkaim_revolver", Weight = 1 },
}

DATA.Translations[ ACT_MP_RELOAD_STAND ] = {
	{ Sequence = "reload_revolver", Weight = 1 },
}

DATA.Translations[ ACT_MP_RELOAD_CROUCH ] = {
	{ Sequence = "reloadcrouch_pistol", Weight = 1 },
}

DATA.Translations[ ACT_MP_CROUCH_IDLE ] = {
	{ Sequence = "wos_aoc_cidle_pistol", Weight = 1 },
}

DATA.Translations[ ACT_MP_RUN ] = {
	{ Sequence = "r_runaim_revolver", Weight = 1 },
}

DATA.Translations[ ACT_MP_SPRINT ] = {
	{ Sequence = "s_sprintidle_pistol", Weight = 1 },
}

DATA.Translations[ ACT_LAND ] = {
	{ Sequence = "wos_bs_shared_jump_land", Weight = 1 },
	{ Sequence = "jump_land", Weight = 1 },
}

wOS.AnimExtension:RegisterHoldtype( DATA )