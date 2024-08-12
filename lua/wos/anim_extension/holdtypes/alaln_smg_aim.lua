local DATA = {}
DATA.Name = "alaln_smg_aim"
DATA.HoldType = "alaln_smg_aim"
DATA.BaseHoldType = "smg"
DATA.Translations = {} 

DATA.Translations[ ACT_MP_STAND_IDLE ] = {
	{ Sequence = "standaim_mp40", Weight = 1 },
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
	{ Sequence = "c_crouchwalkaim_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_WALK ] = {
	{ Sequence = "r_runaim_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_RELOAD_STAND ] = {
	{ Sequence = "reload_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_RELOAD_CROUCH ] = {
	{ Sequence = "reloadcrouch_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_CROUCH_IDLE ] = {
	{ Sequence = "crouchaim_mp40", Weight = 1 },
}

DATA.Translations[ ACT_MP_RUN ] = {
	{ Sequence = "r_runidle_rifle", Weight = 1 },
}

DATA.Translations[ ACT_MP_SPRINT ] = {
	{ Sequence = "r_runidle_rifle", Weight = 1 },
}

DATA.Translations[ ACT_MP_JUMP ] = nil

wOS.AnimExtension:RegisterHoldtype( DATA )