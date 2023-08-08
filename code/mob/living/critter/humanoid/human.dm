/**
 * A file for human mob critters
 *
 * It might seem odd, but when you just want a humanoid mob it makes sense to keep it simple
 * with normal humans you have more processing and more things to worry about like oxygen, disarms and inventory
 * and using real weapons you need to worry about ammo and such as well. The critter AI is also currently
 * better for the most part compared to human AI and only has full compatibility with mob critters.
 *
 * The idea is to use a temporary mob equip them and copy the appearance for the critter
 * while keeping inhands for their limbs where possible.
 *
 */
ABSTRACT_TYPE(/mob/living/critter/human)
/mob/living/critter/human
	name = "Human critter parent"
	desc = "You shouldn't see me!"
	icon = 'icons/mob/mob.dmi'
	icon_state = "m-none"
	health_brute = 50
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 1
	is_npc = TRUE
	ai_retaliates = TRUE
	ai_retaliate_patience = 3
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP
	ai_type = /datum/aiHolder/wanderer
	/// What do we spawn when we die should be a human corpse spawner leave null for gibs
	var/corpse_spawner = null
	/// Path of a human to copy appearance from
	var/human_to_copy = null

	New()
		..()
		src.steal_appearance(src.human_to_copy)
		src.update_inhands()
		src.post_setup()

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_brute_vuln)

	death(var/gibbed)
		if (gibbed)
			return ..()
		..()
		if (src.corpse_spawner)
			var/obj/mapping_helper/mob_spawn/corpse/human/body = new src.corpse_spawner(get_turf(src))
			body.decomp_stage = DECOMP_STAGE_NO_ROT
			body.max_organs_removed = 0
			src.ghostize()
			qdel(src)
		else
			src.gib()

	proc/steal_appearance(var/mob/living/carbon/human/H)
		if (isnull(H))
			return
		var/mob/living/carbon/human/target = new H
		if (target.l_hand) // don't want artifacts of papers / etc.
			qdel(target.l_hand)
		if (target.r_hand)
			qdel(target.r_hand)
		src.appearance = target
		src.overlay_refs = target.overlay_refs?.Copy()
		qdel(target)

	proc/post_setup()
		src.name = initial(src.name)
		src.real_name = initial(src.real_name)
		src.desc = initial(src.desc)

ABSTRACT_TYPE(/mob/living/critter/human/syndicate)
/mob/living/critter/human/syndicate
	name = "Syndicate Operative"
	real_name = "Syndicate Operative"
	desc = "A Syndicate Operative, oh dear."
	health_brute = 25
	health_burn = 25
	corpse_spawner = /obj/mapping_helper/mob_spawn/corpse/human/syndicate/old
	human_to_copy = /mob/living/carbon/human/normal/syndicate_old

	faction = FACTION_SYNDICATE

	post_setup()
		src.name = "[syndicate_name()] Operative"
		src.real_name = src.name
		src.desc = initial(src.desc)

/mob/living/critter/human/syndicate/knife
	ai_type = /datum/aiHolder/aggressive
	hand_count = 2

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb/sword
		HH.name = "left hand"
		HH.suffix = "-L"
		HH.icon_state = "blade"
		HH.limb_name = "combat knife"
		HH.can_hold_items = FALSE
		HH.object_for_inhand = /obj/item/dagger

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right arm"

/mob/living/critter/human/syndicate/rifle
	ai_type = /datum/aiHolder/ranged
	hand_count = 1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb/gun/kinetic/rifle
		HH.name = "rifle"
		HH.suffix = "-LR"
		HH.icon_state = "handrifle"
		HH.limb_name = "\improper Sirius assault rifle"
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE
		HH.object_for_inhand = /obj/item/gun/kinetic/assault_rifle
