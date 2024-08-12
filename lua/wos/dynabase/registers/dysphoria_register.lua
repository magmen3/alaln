wOS.DynaBase:RegisterSource({
	Name = "Dysphoria bs_zombie Extension",
	Type =  WOS_DYNABASE.EXTENSION,
	Shared = "models/dysphoria/anims/bs_zombie.mdl",
})

wOS.DynaBase:RegisterSource({
	Name = "Dysphoria l4d2 Extension",
	Type =  WOS_DYNABASE.EXTENSION,
	Shared = "models/dysphoria/anims/l4d2.mdl",
})

wOS.DynaBase:RegisterSource({
	Name = "Dysphoria zps_surv Extension",
	Type =  WOS_DYNABASE.EXTENSION,
	Shared = "models/dysphoria/anims/zps_surv.mdl",
})

hook.Add( "PreLoadAnimations", "wOS.DynaBase.MountDysphoria", function( gender )
	if gender != WOS_DYNABASE.SHARED then return end
	IncludeModel( "models/dysphoria/anims/bs_zombie.mdl" )
	IncludeModel( "models/dysphoria/anims/l4d2.mdl" )
	IncludeModel( "models/dysphoria/anims/zps_surv.mdl" )
end )