/datum/targetable/wraithAbility/possessObject
	name = "Possess Object"
	icon_state = "possessobject"
	desc = "Possess and control an everyday object. Freakout level: high."
	targeted = 1
	target_anything = 1
	pointCost = 300
	cooldown = 150 SECONDS //Tweaked this down from 3 minutes to 2 1/2, let's see if that ruins anything

	cast(var/atom/target)
		if (..())
			return 1

		if (src.holder.owner.density)
			boutput(usr, SPAN_ALERT("You cannot force your consciousness into a body while corporeal."))
			return 1

		if (istype(target, /obj/item/bible))
			boutput(holder.owner, SPAN_ALERT("<b>You feel rebuffed by a holy force!<b>"))

		if (!isitem(target))
			boutput(holder.owner, SPAN_ALERT("You cannot possess this!"))
			return 1

		boutput(holder.owner, SPAN_ALERT("<strong>[pick("You extend your will into [target].", "You force [target] to do your bidding.")]</strong>"))
		usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithpossesobject.ogg', 50, 0)
		var/mob/living/object/O = new/mob/living/object(get_turf(target), target, holder.owner)
		SPAWN(45 SECONDS)
			if (O)
				boutput(O, SPAN_ALERT("You feel your control of this vessel slipping away!"))
		SPAWN(60 SECONDS) //time limit on possession: 1 minute
			if (O)
				boutput(O, SPAN_ALERT("<strong>Your control is wrested away! The item is no longer yours.</strong>"))
				usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithleaveobject.ogg', 50, 0)
				O.death(FALSE)
		return 0
