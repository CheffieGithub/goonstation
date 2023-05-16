// Rockworm vomit

/datum/targetable/critter/vomit_ore
	name = "Vomit ore"
	desc = "Throw out a piece of raw ore"
	icon_state = "puke"
	cooldown = 30 SECONDS
	targeted = TRUE
	target_anything = TRUE

	cast(atom/T)
		var/mob/living/critter/C = holder.owner
		if (istype(C, /mob/living/critter/rockworm))
			var/mob/living/critter/rockworm/worm = C
			if (worm.eaten >= worm.rocks_per_gem)
				boutput(C,"<span class='alert'> you don't feel full enough to vomit.</span>")
				return
			worm.eaten -= worm.rocks_per_gem
		var/obj/item/created
		var/pickgem = rand(1,3)
		switch(pickgem)
			if(1) created = new /obj/item/raw_material/gemstone
			if(2) created = new /obj/item/raw_material/uqill
			if(3) created = new /obj/item/raw_material/fibrilith
		var/obj/item/raw_material/ammo = new created(C.loc)
		C.visible_message("<b><span class='alert'>[C] vomits up a piece of [ammo]!</span></b>")
		ammo.throw_at(T, 32, 4)
		doCooldown()
