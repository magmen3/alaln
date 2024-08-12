local DATA = {}
DATA.Name = "alaln_smg_idle"
DATA.HoldType = "alaln_smg_idle"
DATA.BaseHoldType = "smg"
DATA.Translations = {} 

DATA.Translations[ ACT_MP_STAND_IDLE ] = {
	{ Sequence = "standidle_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = {
	{ Sequence = "attack_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = {
	{ Sequence = "attack_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_ATTACK_STAND_SECONDARYFIRE ] = {
	{ Sequence = "secondaryattack_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_ATTACK_CROUCH_SECONDARYFIRE ] = {
	{ Sequence = "secondaryattackcrouch_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_CROUCHWALK ] = {
	{ Sequence = "c_crouchwalkidle_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_WALK ] = {
	{ Sequence = "r_runidle_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_RELOAD_STAND ] = {
	{ Sequence = "reload_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_RELOAD_CROUCH ] = {
	{ Sequence = "reloadcrouch_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_CROUCH_IDLE ] = {
	{ Sequence = "crouchidle_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_RUN ] = {
	{ Sequence = "r_runidle_rifle", Weight = 1 },
}

DATA.Translations[ ACT_MP_SPRINT ] = {
	{ Sequence = "r_runidle_rifle", Weight = 1 },
}

DATA.Translations[ ACT_MP_JUMP ] = nil

wOS.AnimExtension:RegisterHoldtype( DATA )