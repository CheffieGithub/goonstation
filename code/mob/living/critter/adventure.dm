/* -For adventure zoneish mobs-
whats here
	- Transposed scientist
	- Ancient robot
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
	can_help = TRUE
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	health_brute = 25
	health_brute_vuln = 1
	health_burn = 25
	health_burn_vuln = 1
	speech_void = 1
	ai_retaliates = TRUE
	ai_retaliate_patience = 3
	ai_retaliate_persistence = RETALIATE_ONCE // They don't really want to hurt you
	ai_type = /datum/aiHolder/wanderer_agressive
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

	critter_attack(var/mob/target)
		if (target.lying || is_incapacitated(target))
			src.set_a_intent(INTENT_HELP)
		else
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

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 5, 15, 0, can_punch = FALSE, can_kick = FALSE)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = "grab"
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with [src.holder]!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/burn_sizzle.ogg'
		msgs.damage_type = DAMAGE_BURN
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target
		ON_COOLDOWN(src, "limb_cooldown", 2 SECONDS)

////////////// Ancient robot ////////////////
/mob/living/critter/robotic/ancient_robot
	name = "???"
	real_name = "ancient robot"
	desc = "What the hell is that?"
	icon_state = "ancientrobot"
	icon_state_dead = "ancientrobot" // fades away
	invisibility = INVIS_GHOST
	hand_count = 2
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	health_brute = 30
	health_brute_vuln = 0.8
	health_burn = 30
	health_burn_vuln = 0.8
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/wanderer_agressive
	is_npc = TRUE
	var/poke_count = 0
	var/ready_to_gib = FALSE
	var/activating = FALSE // Are we preparing to gib?

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/ancient_tendril
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left strange tendril"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/ancient_tendril
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right strange tendril"

	setup_healths()
		add_hh_robot(src.health_brute, src.health_brute_vuln)
		add_hh_robot_burn(src.health_burn, src.health_burn_vuln)

	seek_target(var/range = 5)
		. = list()
		for (var/mob/living/C in hearers(range, src))
			if (isintangible(C)) continue
			if (isdead(C)) continue
			if (istype(C, src.type)) continue
			. += C

		if (length(.))
			if(invisibility != INVIS_NONE)
				src.appear()
			if(src.ready_to_gib && prob(15) )
				playsound(src.loc, 'sound/misc/automaton_ratchet.ogg', 60, 1)

	critter_attack(var/mob/target)
		if(src.activating)
			return
		if(src.poke_count < 5)
			if (prob(50))
				boutput(target, "<span class='alert'>You feel [pick("very", null ,"rather","fairly","remarkably")] uncomfortable.</span>")
			..()
			src.poke_count++
		else if (src.ready_to_gib)
			src.gib_patient(target)
		else
			playsound(src.loc, 'sound/misc/automaton_tickhum.ogg', 40, 1)
			src.visible_message("<span class='alert'><b> the [src] begins to unveil an array of tendrils! oh shit! RUN!</b></span>")
			src.activating = TRUE
			SPAWN(3 SECONDS)
				playsound(src.loc, 'sound/misc/automaton_ratchet.ogg', 60, 1)
				src.ready_to_gib = TRUE
				src.activating = FALSE

	death()
		..()
		flick("ancientrobot-disappear",src)
		SPAWN(16) //maybe let the animation actually play
			qdel(src)

	proc/appear()
		if (!invisibility || (src.icon_state != "ancientrobot"))
			return
		src.name = pick("something","weird thing","odd thing","whatchamacallit","thing","something weird","old thing")
		flick("ancientrobot-appear",src)
		src.invisibility = INVIS_NONE
		return

	proc/gib_patient(var/mob/target)
		src.visible_message("<span class='alert'><b>In a whirling flurry of tendrils, [src] rends down [target]! Holy shit!</b></span>")
		logTheThing(LOG_COMBAT, target, "was gibbed by [src] at [log_loc(src)].") // Some logging for instakill critters would be nice (Convair880).
		playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
		if(ishuman(target)) new /obj/decal/fakeobjects/skeleton(target.loc)
		target.ghostize()
		target.gib()
		src.ready_to_gib = FALSE
		src.poke_count = 0

/datum/limb/ancient_tendril
	harm(mob/target, var/mob/living/user)
		if(check_target_immunity( target ))
			return FALSE

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 3, 5, 0, can_punch = FALSE, can_kick = FALSE)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("poke", "prod", "feel", "jab")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with [src.holder]!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/burn_sizzle.ogg'
		msgs.damage_type = DAMAGE_STAB
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target
		ON_COOLDOWN(src, "limb_cooldown", 2 SECONDS)

/mob/living/critter/robotic/repairbot
	name = "strange robot"
	real_name = "strange robot"
	desc = "It looks like some sort of floating repair bot or something?"
	icon_state = "ancient_repairbot"
	hand_count = 1
	can_throw = FALSE
	can_grab = FALSE
	can_disarm = FALSE
	health_brute = 15
	health_brute_vuln = 0.7
	health_burn = 15
	health_burn_vuln = 0.3
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/wanderer_agressive
	is_npc = TRUE
	death_text = "%src% blows apart!"
	custom_gib_handler = /proc/robogibs
	say_language = "binary"
	voice_name = "synthesized voice"
	blood_id = "oil"
	speechverb_say = "beeps"
	speechverb_gasp = "chirps"
	speechverb_stammer = "beeps"
	speechverb_exclaim = "beeps"
	speechverb_ask = "beeps"
	metabolizes = FALSE

	understands_language(var/langname)
		if (langname == say_language || langname == "silicon" || langname == "binary" || langname == "english")
			return TRUE
		return FALSE

	New()
		..()
		src.name = "[pick("strange","weird","odd","bizarre","quirky","antique")] [pick("robot","automaton","machine","gizmo","thingmabob","doodad","widget")]"
		src.real_name = src.name

	process_language(var/message)
		var/datum/language/L = languages.language_cache[say_language]
		if (!L)
			L = languages.language_cache["english"]
		return L.get_messages(message, (1 - health / max_health) * 16)

	death(var/gibbed)
		elecflash(src,power = 3)
		..()
		ghostize()
		qdel(src)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/screams/robot_scream.ogg' , 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> screams!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears/intercom(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/arcflash
		HH.name = "Electric Intruder Countermeasure"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handzap"
		HH.limb_name = "Electric Intruder Countermeasure"
		HH.can_hold_items = FALSE
		HH.can_attack = FALSE
		HH.can_range_attack = TRUE

	setup_healths()
		add_hh_robot(src.health_brute, src.health_brute_vuln)
		add_hh_robot_burn(src.health_burn, src.health_burn_vuln)

	seek_target(var/range = 5)
		. = list()
		for (var/mob/living/C in hearers(range, src))
			if (isintangible(C)) continue
			if (isdead(C)) continue
			if (istype(C, /mob/living/critter/robotic/repairbot)) continue
			if (isrobot(C)) continue // Arcflash doesn't hurt borgs
			. += C

		if (length(.) && prob(15))
			playsound(src.loc,pick('sound/misc/ancientbot_beep1.ogg','sound/misc/ancientbot_beep2.ogg','sound/misc/ancientbot_beep3.ogg'), 50, 1)

	critter_attack(var/mob/target)
		var/list/params = list()
		params["left"] = TRUE
		params["ai"] = TRUE
		src.hand_range_attack(target, params)

/mob/living/critter/robotic/repairbot/security
	name = "stranger robot"
	real_name = "repair bot"
	desc = "A Security Robot, something seems a bit off."
	icon_state = "ancient_guardbot"
	health_brute = 20
	health_brute_vuln = 0.7
	health_burn = 20
	health_burn_vuln = 0.2





