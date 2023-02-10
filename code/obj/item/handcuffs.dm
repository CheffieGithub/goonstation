/obj/item/handcuffs
	name = "handcuffs"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "handcuff"
	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	throwforce = 5
	w_class = W_CLASS_SMALL
	throw_speed = 2
	throw_range = 5
	m_amt = 500
	var/strength = 2
	var/delete_on_last_use = 0 // Delete src when it's used up (e.g. tape roll)?
	var/apply_multiplier = 1
	var/remove_self_multiplier = 1
	var/remove_other_multiplier = 1
	desc = "Adjustable metal rings joined by cable, made to be applied to a person in such a way that they are unable to use their hands. Difficult to remove from oneself."
	custom_suicide = 1

/obj/item/handcuffs/setMaterial(var/datum/material/mat1, var/appearance = 1, var/setname = 1, var/copy = 1, var/use_descriptors = 0)
	..()
	if (mat1.mat_id == "silver")
		name = "silver handcuffs"
		icon_state = "handcuff-silver"
		desc = "These handcuffs are perfect for containing evil creatures, but they're fragile otherwise as a result."
		strength = 1

/obj/item/handcuffs/examine()
	. = ..()
	if (src.delete_on_last_use)
		. += "There are [src.amount] lengths of [istype(src, /obj/item/handcuffs/tape_roll) ? "tape" : "ziptie"] left!"

/obj/item/handcuffs/suicide(var/mob/living/carbon/human/user as mob) //brutal
	if (!istype(user) || !user.organHolder || !src.user_can_suicide(user))
		return 0
	if (istype(src,/obj/item/handcuffs/tape_roll) || istype(src,/obj/item/handcuffs/tape)) // shout out once again to the hasvar bullshit that was here
		return 0
	user.canmove = 0
	user.visible_message("<span class='alert'><b>[user] jams one end of [src] into one of [his_or_her(user)] eye sockets, closing the loop through the other!")
	playsound(user, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
	user.emote("scream")
	SPAWN(1 SECOND)
		user.visible_message("<span class='alert'><b>[user] yanks the other end of [src] as hard as [he_or_she(user)] can, ripping [his_or_her(user)] skull clean out of [his_or_her(user)] head! [pick("Jesus christ!","Holy shit!","What the fuck!?","Oh my god!")]</b></span>")
		var/obj/skull = user.organHolder.drop_organ("skull")
		if (skull)
			skull.set_loc(user.loc)
		make_cleanable( /obj/decal/cleanable/blood,user.loc)
		playsound(user, 'sound/impact_sounds/Flesh_Break_2.ogg', 50, 1)
		health_update_queue |= user

/* do not do this thing here:
		for (var/mob/O in AIviewers(user, null)) // loop through all mobs that can see user kill themself
			if (O != user && ishuman(O) && prob(33)) // make sure O isn't user, then make sure they're human?
				//why didn't we just loop through /mob/living/carbon/human in the first place instead of all mobs?
				O.show_message("<span class='alert'>You feel ill from watching that.</span>") // O is grossed out
				for (var/mob/V in viewers(O, null)) // loop through all the mobs that can see O locally
					V.show_message("<span class='alert'>[O.name] pukes all over \himself. Thanks, [user.name].</span>", 1) // tell them that O puked
					playsound(O.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1) // play a sound where O is
					make_cleanable( /obj/decal/cleanable/vomit,O.loc) // make a vomit decal where O
					// these last two parts are within the for loop so that means that for EVERY MOB THAT SEES THIS, A SOUND AND DECAL ARE MADE
*/
		for (var/mob/living/carbon/human/O in AIviewers(user, null))
			if (O != user && prob(33))
				O.visible_message("<span class='alert'>[O] pukes all over [himself_or_herself(O)]. Thanks, [user].</span>",\
				"<span class='alert'>You feel ill from watching that. Thanks, [user].</span>")
				O.vomit()

		SPAWN(0.5 SECONDS)
			if (user && skull)
				var/obj/brain = user.organHolder.drop_organ("brain")
				if (brain)
					brain.set_loc(skull.loc)
					brain.visible_message("<span class='alert'><b>[brain] falls out of the bottom of [skull].</b></span>")

		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
				user.canmove = 1
	return 1

/obj/item/handcuffs/attack(mob/M, mob/user)
	src.try_cuff(M, user)

/obj/item/handcuffs/proc/try_cuff(mob/M, mob/user, instant = FALSE)
	if (user?.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50))
		boutput(user, "<span class='alert'>Uh ... how do those things work?!</span>")
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (!H.limbs || !H.limbs.l_arm || !H.limbs.r_arm)
				return
			M = user
			JOB_XP(user, "Clown", 1)
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (isabomination(H))
			boutput(user, "<span class='alert'>You can't! There's nowhere to put them!</span>")
			return

		var/handslost = !istype(H.limbs.l_arm,/obj) + !istype(H.limbs.r_arm,/obj)
		switch(handslost)
			if (1)
				boutput(user, "<span class='alert'>[H.name] only has one arm, you still try to handcuff [his_or_her(H)]!</span>")
			if (2)
				boutput(user, "<span class='alert'>[H.name] has no arms, you can't handcuff them!</span>")
				return

		if (H.hasStatus("handcuffed"))
			boutput(user, "<span class='alert'>[H] is already handcuffed</span>")
			return

		playsound(src.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
		if (instant)
			src.cuff(M)
		else
			actions.start(new/datum/action/bar/icon/handcuffSet(H, src), user)

/obj/item/handcuffs/proc/cuff(mob/living/carbon/human/target)
	src.set_loc(target)
	target.handcuffs = src
	target.drop_from_slot(target.r_hand)
	target.drop_from_slot(target.l_hand)
	target.drop_juggle()
	target.setStatus("handcuffed", duration = INFINITE_STATUS)
	target.update_clothing()

/obj/item/handcuffs/New()
	..()
	BLOCK_SETUP(BLOCK_ROPE)

/obj/item/handcuffs/disposing()
	if (ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		H.set_clothing_icon_dirty()
	..()

/obj/item/handcuffs/proc/werewolf_cant_rip()
	.= src.material && src.material.mat_id == "silver"

/obj/item/handcuffs/proc/drop_handcuffs(mob/user)
	user.handcuffs = null
	user.delStatus("handcuffed")
	user.drop_item(src)
	user.update_clothing()
	if (src.strength == 1) // weak cuffs break
		if (src.material && src.material.mat_id == "silver")
			src.visible_message("<span class='alert'>[src] disintegrate.</span>")
		else if ((istype(src, /obj/item/handcuffs/guardbot)))
			src.visible_message("<span class='alert'>[src] biodegrade instantly. [prob (10) ? "DO NOT QUESTION THIS" : null]</span>")
		else
			src.visible_message("<span class='alert'>[src] break apart.</span>")
		qdel(src)

/obj/item/handcuffs/proc/destroy_handcuffs(mob/user)
	user.handcuffs = null
	user.delStatus("handcuffed")
	user.update_clothing()
	qdel(src)

/obj/item/handcuffs/tape_roll
	name = "ducktape"
	desc = "A convenient and illegal source of makeshift handcuffs."
	icon_state = "ducktape"
	flags = FPRINT | TABLEPASS
	c_flags = ONBELT
	m_amt = 200
	amount = 10
	delete_on_last_use = TRUE

/obj/item/handcuffs/tape_roll/crappy
	name = "masking tape"
	delete_on_last_use = FALSE
	apply_multiplier = 2
	remove_self_multiplier = 0.125

/obj/item/handcuffs/tape
	desc = "These seem to be made of tape"
	strength = 1

/obj/item/handcuffs/guardbot
	name = "ziptie cuffs"
	desc = "A wrist-binding tie made from a durable synthetic material.  Weaker than traditional handcuffs, but much more comfortable."
	icon_state = "buddycuff"
	m_amt = 0
	strength = 1
	apply_multiplier = 0.5
