/* -For adventure zoneish mobs-
whats here
	- Transposed Scientist
	- Ancient Thing
	- Repair bots
	- Shade

*/
////////////// Transposed Scientist ////////////////
/mob/living/critter/crunched
	name = "transposed scientist"
	real_name = "transposed scientist"
	desc = "A fellow who seems to have been shunted between dimensions. Not a good state to be in."
	icon_state = "crunched"
	icon_state_dead = "crunched"
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	health_brute = 25
	health_brute_vuln = 1
	health_burn = 25
	health_burn_vuln = 1
	speech_void = 1
	ai_retaliates = TRUE
	ai_retaliate_patience = 3
	ai_retaliate_persistence = RETALIATE_ONCE
	ai_type = /datum/aiHolder/brullbar
	is_npc = TRUE

	New()
		..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/transposed
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left transposed arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/transposed
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right transposed arm"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	critter_attack(var/mob/target)
		if (target.lying || is_incapacitated(target))
			src.visible_message("<span class='notice'>[src] shakes [target] trying to wake them up!</span>")
			src.set_a_intent(INTENT_HELP)
		else
			src.visible_message("<span class='combat'><B>[src]</B> grabs at [target]'s arm!</span>")
			src.set_a_intent(INTENT_HARM)
		src.chase_lines(target)
		src.hand_attack(target)

	proc/chase_lines(var/mob/target)
		if(!ON_COOLDOWN(src, "crunched_chase_talk", 5 SECONDS))
			if (target.lying || is_incapacitated(target))
				src.say( pick("No! Get up! Please, get up!", "Not again! Not again! I need you!", "Please! Please get up! Please!", "I don't want to be alone again!") )
			else
				src.say( pick("Please! Help! I need help!", "Please...help me!", "Are you real? You're real! YOU'RE REAL", "Everything hurts! Everything hurts!", "Please, make the pain stop! MAKE IT STOP!") )


	seek_target(var/range = 5)
		. = list()
		for (var/mob/living/C in hearers(range, src))
			if (isintangible(C)) continue
			if (isdead(C)) continue
			if (istype(C, src.type)) continue
			. += C

		if (length(.) && prob(10))
			src.say(pick("Please...help...it hurts...please", "I'm...sick...help","It went wrong.  It all went wrong.","I didn't mean for this to happen!", "I see everything twice!") )

	death()
		src.say( pick("There...is...nothing...","It's dark.  Oh god, oh god, it's dark.","Thank you.","Oh wow. Oh wow. Oh wow.") )
		..()
		SPAWN(1.5 SECONDS)
			qdel(src)

////////// Transposed limb ///////////
/datum/limb/transposed
	help(mob/target, var/mob/living/user)
		..()
		harm(target, user, 0)

	harm(mob/target, var/mob/living/user)
		if(check_target_immunity( target ))
			return FALSE
		logTheThing(LOG_COMBAT, user, "harms [constructTarget(target,"combat")] with [src] at [log_loc(user)].")

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 5, 15, 0, can_punch = FALSE, can_kick = FALSE)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = "grab"
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with [src.holder]!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/burn_sizzle.ogg'
		msgs.damage_type = DAMAGE_BURN
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target
		ON_COOLDOWN(src, "limb_cooldown", 20)

////////////// Ancient thing ////////////////
/mob/living/critter/robotic/ancient_thing
	name = "???"
	real_name = "ancient thing"
	desc = "What the hell is that?"
	icon_state = "ancientrobot"
	dead_state = "ancientrobot" // fades away
	invisibility = INVIS_GHOST
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	health_brute = 30
	health_brute_vuln = 0.8
	health_burn = 30
	health_burn_vuln = 0.9
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/brullbar
	is_npc = TRUE

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/transposed
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left transposed arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/transposed
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right transposed arm"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)


	death()
		..()
		flick("ancientrobot-disappear",src)
		SPAWN(16) //maybe let the animation actually play
			qdel(src)

	proc/appear()
		if (!invisibility || (src.icon_state != "ancientrobot"))
			return
		src.name = pick("something","weird thing","odd thing","whatchamacallit","thing","something weird","old thing")
		src.icon_state = "ancientrobot-appear"
		src.invisibility = INVIS_NONE
		SPAWN(1.2 SECONDS)
			src.icon_state = "ancientrobot"
		return




