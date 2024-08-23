local DATA = {}
DATA.Name = "alaln_knife"
DATA.HoldType = "alaln_knife"
DATA.BaseHoldType = "knife"
DATA.Translations = {} 

DATA.Translations[ ACT_MP_SWIM ] = {
	{ Sequence = "sw_swimaim_bandages", Weight = 1 },
}

DATA.Translations[ ACT_MP_JUMP ] = "deliver_1handed_grab_jump" --[[{ nil
	{ Sequence = "jump_gren_frag", Weight = 1 },
	{ Sequence = "jump_gren_frag1", Weight = 1 },
}]]

DATA.Translations[ ACT_MP_STAND_IDLE ] = {
	{ Sequence = "standidle_knife", Weight = 1 },
}

DATA.Translations[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = {
	{ Sequence = "attack_knife", Weight = 1 },
}

DATA.Translations[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = {
	{ Sequence = "attackcrouch_knife", Weight = 1 },
}

DATA.Translations[ ACT_MP_CROUCHWALK ] = {
	{ Sequence = "c_crouchwalkidle_knife", Weight = 1 },
}

DATA.Translations[ ACT_MP_WALK ] = {
	{ Sequence = "r_runidle_knife", Weight = 1 },
}

DATA.Translations[ ACT_MP_RELOAD_STAND ] = {
	{ Sequence = "reload_knife", Weight = 1 },
}

DATA.Translations[ ACT_MP_RELOAD_CROUCH ] = {
	{ Sequence = "reloadcrouch_knife", Weight = 1 },
}

DATA.Translations[ ACT_MP_CROUCH_IDLE ] = {
	{ Sequence = "crouchidle_knife", Weight = 1 },
}

DATA.Translations[ ACT_MP_RUN ] = {
	{ Sequence = "r_runidle_knife", Weight = 1 },
}

DATA.Translations[ ACT_MP_SPRINT ] = {
	{ Sequence = "s_sprintaim_knife", Weight = 1 },
}

DATA.Translations[ ACT_LAND ] = {
	{ Sequence = "wos_bs_shared_jump_land", Weight = 1 },
	{ Sequence = "jump_land", Weight = 1 },
}

wOS.AnimExtension:RegisterHoldtype( DATA )