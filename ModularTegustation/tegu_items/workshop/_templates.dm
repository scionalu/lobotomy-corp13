/obj/item/ego_weapon/template
	name = "blank template"
	desc = "A blank template. You should never see this!"
	icon = 'ModularTegustation/Teguicons/workshop.dmi'
	force = 0
	attack_speed = 1
	damtype = RED_DAMAGE

	attack_verb_continuous = list("pokes", "jabs", "tears", "lacerates", "gores")
	attack_verb_simple = list("poke", "jab", "tear", "lacerate", "gore")
	hitsound = 'sound/weapons/ego/spear1.ogg'
	var/active
	var/finisheddesc = "A finished weapon."
	var/aoe_range = 0
	var/type_overriden = FALSE
	var/forceholder	//holds the force for later
	var/special_count //Various vars use this for various things
	var/obj/item/workshop_mod/specialmod
	var/list/finishedname = list()
	var/list/finishedicon = list()

	var/weapon_xp = 0
	var/level_xp = 100

/obj/item/ego_weapon/template/attack(mob/living/target, mob/living/carbon/human/user)
	if(target.stat != DEAD)
		weapon_xp ++
	forceholder = force
	if(!active)
		to_chat(user, span_notice("This weapon is unfinished!"))
		return
	if(specialmod)
		specialmod.ActivateEffect(src, special_count, target, user)
	..()
	if(forceholder != force)
		force = forceholder

/obj/item/ego_weapon/template/attackby(obj/item/I, mob/living/user, params)
	..()
	if(istype(I, /obj/item/workshop_mod) && !active)
		InstallMod(I)
		return

//Mod Installation Proc: Seperated from attackby so its easier to read and override.
/obj/item/ego_weapon/template/proc/InstallMod(obj/item/workshop_mod/mod)
	active = TRUE

	//Modify these
	force *= mod.forcemod
	attack_speed *= mod.attackspeedmod

	if(!type_overriden)
		damtype = mod.damagetype
	if(!color)
		// Material color overwrites
		color = mod.weaponcolor
	//throwforce is special
	if(throwforce>10)
		throwforce *= mod.throwforcemod
	else if(mod.throwforcemod > 1)
		throwforce = 30

	/* Calls unique installation proc that the mod has.
		Unsure if i should put all of the above in this proc.*/
	mod.InstallationEffect(src)

	//naming and icon stuff.
	var/newname = pick(finishedname)
	name = "[mod.modname] [newname]"
	if(finishedicon)
		icon_state = pick(finishedicon)
	desc = finisheddesc
	add_overlay("[mod.overlay]")
	specialmod = mod
	//May have to change this later if the contents of the weapon can be accessed.
	mod.forceMove(src)
	return

/obj/item/ego_weapon/template/proc/AlterSpecial(subject, add_to = FALSE)
	if(add_to)
		special_count += subject
	else
		special_count = subject

/obj/item/ego_weapon/template/examine(mob/user)
	. = ..()

	if(level_xp == 600)
		. += "This weapon is fully upgraded!"
		return


	if(weapon_xp < level_xp)
		. += "Weapon XP : [weapon_xp]/[level_xp]."
	else
		. += "Weapon XP : FULL! Bring to a workshop to reforge!"

//Upgrade shit
/obj/item/ego_weapon/template/attackby(obj/item/I, mob/living/user, params)
	..()
	if(istype(I, /obj/item/forginghammer))
		if(!(locate(/obj/structure/table/anvil) in loc))
			to_chat(user, span_warning("You need this to be on an anvil to work it."))
			return

		if(level_xp == 600)
			to_chat(user, span_warning("This weapon cannot be upgraded."))
			return

		if(weapon_xp < level_xp)
			to_chat(user, span_warning("This weapon does not have enough XP to level up yet."))
			return

		if(!do_after(user, 10 SECONDS))
			return

		weapon_xp = 0
		level_xp += 100
		force *= 1.1

