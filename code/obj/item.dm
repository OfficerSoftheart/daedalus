/obj/item/proc/transfer_soul(var/choice as text, var/target, var/mob/U as mob).
	switch(choice)
		if("VICTIM")
			var/mob/living/carbon/human/T = target
			var/obj/item/device/soulstone/C = src
			if(C.imprinted != "empty")
				U << "\red <b>Capture failed!</b>: \black The soul stone has already been imprinted with [C.imprinted]'s mind!"
			else
				if (T.stat == 0)
					U << "\red <b>Capture failed!</b>: \black Kill or maim the victim first!"
				else
					if(T.client == null)
						U << "\red <b>Capture failed!</b>: \black The soul has already fled it's mortal frame."
					else
						if(C.contents.len)
							U << "\red <b>Capture failed!</b>: \black The soul stone is full! Use or free an existing soul to make room."
						else
							for(var/obj/item/W in T)
								T.drop_from_slot(W)
							new /obj/effect/decal/remains/human(T.loc) //Spawns a skeleton
							T.invisibility = 101
							var/atom/movable/overlay/animation = new /atom/movable/overlay( T.loc )
							animation.icon_state = "blank"
							animation.icon = 'icons/mob/mob.dmi'
							animation.master = T
							flick("dust-h", animation)
							del(animation)
							var/mob/living/simple_animal/shade/S = new /mob/living/simple_animal/shade( T.loc )
							S.loc = C //put shade in stone
							S.nodamage = 1 //So they won't die inside the stone somehow
							S.canmove = 0//Can't move out of the soul stone
							S.name = "Shade of [T.name]"
							if (T.client)
								T.client.mob = S
							S.cancel_camera()
							C.icon_state = "soulstone2"
							C.name = "Soul Stone: [S.name]"
							S << "Your soul has been captured! You are now bound to [U.name]'s will, help them suceed in their goals at all costs."
							U << "\blue <b>Capture successful!</b>: \black [T.name]'s soul has been ripped from their body and stored within the soul stone."
							U << "The soulstone has been imprinted with [S.name]'s mind, it will no longer react to other souls."
							C.imprinted = "[S.name]"
							del T
		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			var/obj/item/device/soulstone/C = src
			if (T.alive == 0)
				U << "\red <b>Capture failed!</b>: \black The shade has already been banished!"
			else
				if(C.contents.len)
					U << "\red <b>Capture failed!</b>: \black The soul stone is full! Use or free an existing soul to make room."
				else
					if(T.name != C.imprinted)
						U << "\red <b>Capture failed!</b>: \black The soul stone has already been imprinted with [C.imprinted]'s mind!"
					else
						T.loc = C //put shade in stone
						T.nodamage = 1
						T.canmove = 0
						T.health = T.maxHealth
						C.icon_state = "soulstone2"
						T << "Your soul has been recaptured by the soul stone, its arcane energies are reknitting your ethereal form"
						U << "\blue <b>Capture successful!</b>: \black [T.name]'s has been recaptured and stored within the soul stone."
		if("CONSTRUCT")
			var/obj/structure/constructshell/T = target
			var/obj/item/device/soulstone/C = src
			var/mob/living/simple_animal/shade/A = locate() in C
			if(A)
				var/construct_class = alert(U, "Please choose which type of construct you wish to create.",,"Juggernaut","Wraith","Artificer")
				var/mob/living/simple_animal/Z
				switch(construct_class)
					if("Juggernaut")
						Z = new /mob/living/simple_animal/constructarmoured (get_turf(T.loc))
						if (A.client)
							A.client.mob = Z
						del(T)
						Z << "<B>You are playing a Juggernaut. Though slow, you can withstand extreme punishment, and rip apart enemies and walls alike.</B>"
						Z << "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>"
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall(Z)
						Z.cancel_camera()
						del(C)

					if("Wraith")
						Z = new /mob/living/simple_animal/constructwraith (get_turf(T.loc))
						if (A.client)
							A.client.mob = Z
						del(T)
						Z << "<B>You are playing a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</B>"
						Z << "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>"
						Z.spell_list += new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift(Z)
						Z.cancel_camera()
						del(C)

					if("Artificer")
						Z = new /mob/living/simple_animal/constructbuilder (get_turf(T.loc))
						if (A.client)
							A.client.mob = Z
						del(T)
						Z << "<B>You are playing an Artificer. You are incredibly weak and fragile, but you are able to construct fortifications, repair allied constructs (by clicking on them), and even create new constructs</B>"
						Z << "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>"
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser(Z)
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/wall(Z)
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/floor(Z)
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/wall/reinforced(Z)
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone(Z)
						Z.cancel_camera()
						del(C)
			else
				U << "\red <b>Creation failed!</b>: \black The soul stone is empty! Go kill someone!"
	return

/obj/item/proc/attack_self()
	return

/obj/item/proc/talk_into(mob/M as mob, text)
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return

/obj/item/proc/dropped(mob/user as mob)
	..()
	user.update_clothing()

	// So you can't drop the Offhand
	if(istype(src, /obj/item/weapon/offhand))
		user.drop_item(src)

		var/obj/item/O_r = user.r_hand
		var/obj/item/O_l = user.l_hand
		if(O_r.twohanded)
			if(O_r.wielded)
				user.drop_item(O_r)
		if(O_l.twohanded)
			if(O_l.wielded)
				user.drop_item(O_l)
		del(src)

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot is text of slot type e.g. "head"
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(var/mob/user, var/slot)
	return
//
// ***TODO: implement unequipped()
//

/obj/item/proc/afterattack()

	return

/obj/item/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(5))
				del(src)
				return
		else
	return

/obj/item/blob_act()
	return

/obj/item/verb/move_to_top()
	set name = "Move To Top"
	set category = "Object"
	set src in oview(1)

	if(!istype(src.loc, /turf) || usr.stat || usr.restrained() )
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T

obj/item/verb/pick_up()
	set name = "Pick Up"
	set category = "Object"
	set src in view(1)

	if(!(usr))
		return
	if((!istype(usr, /mob/living/carbon)) || (istype(usr, /mob/living/carbon/brain)))//Is humanoid, and is not a brain
		usr << "\red You can't pick things up!"
		return
	if( usr.stat || usr.restrained() )//Is not asleep/dead and is not restrained
		usr << "\red You can't pick things up!"
		return
	if(src.anchored) //Object isn't anchored
		usr << "\red You can't pick that up!"
		return
	if(!usr.hand && usr.r_hand) //Right hand is not full
		usr << "\red Your right hand is full."
		return
	if(usr.hand && usr.l_hand) //Left hand is not full
		usr << "\red Your left hand is full."
		return
	if(!istype(src.loc, /turf)) //Object is on a turf
		usr << "\red You can't pick that up!"
		return
	//All checks are done, time to pick it up!
	if(istype(usr, /mob/living/carbon/human))
		src.attack_hand(usr)
	if(istype(usr, /mob/living/carbon/alien))
		src.attack_alien(usr)
	if(istype(usr, /mob/living/carbon/monkey))
		src.attack_paw(usr)
	return

/obj/item/examine()
	set src in view()

	var/t
	switch(src.w_class)
		if(1.0)
			t = "tiny"
		if(2.0)
			t = "small"
		if(3.0)
			t = "normal-sized"
		if(4.0)
			t = "bulky"
		if(5.0)
			t = "huge"
		else
	if ((usr.mutations & CLUMSY) && prob(50)) t = "funny-looking"
	usr << text("This is a []\icon[][]. It is a [] item.", !src.blood_DNA ? "" : "bloody ",src, src.name, t)
	if(src.desc)
		usr << src.desc
	return

/obj/item/attack_hand(mob/user as mob)
	if (!user) return
	if (user.hand)
		if(ishuman(user))
			var/datum/organ/external/temp = user:organs["l_hand"]
			if(temp.destroyed)
				user << "\blue Yo- wait a minute."
				return
	else
		if(ishuman(user))
			var/datum/organ/external/temp = user:organs["r_hand"]
			if(temp.destroyed)
				user << "\blue Yo- wait a minute."
	if (istype(src.loc, /obj/item/weapon/storage))
		for(var/mob/M in range(1, src.loc))
			if (M.s_active == src.loc)
				if (M.client)
					M.client.screen -= src
		if(istype(src.loc, /obj/item/weapon/storage/backpack/santabag))
			if(src.loc.contents.len < 5)
				src.loc.icon_state = "giftbag0"
			else if(src.loc.contents.len >= 5 && src.loc.contents.len < 15)
				src.loc.icon_state = "giftbag1"
			else if(src.loc.contents.len >= 15)
				src.loc.icon_state = "giftbag2"

	src.throwing = 0
	if (src.loc == user)
		//canremove==0 means that object may not be removed. You can still wear it. This only applies to clothing. /N
		if(istype(src, /obj/item/clothing) && !src:canremove)
			return
		else
			user.u_equip(src)
	else
		if(istype(src.loc, /mob/living))
			return
		src.pickup(user)
		user.lastDblClick = world.time + 2
		user.next_move = world.time + 2

	if (user.hand)
		if(ishuman(user))
			var/datum/organ/external/temp = user:organs["l_hand"]
			if(!temp.destroyed)
				user.l_hand = src
			else
				user << "\blue You pick \the [src] up with your ha- wait a minute."
				if(loc == user)
					user.drop_from_slot(src)
				return
		else
			user.l_hand = src
	else
		if(ishuman(user))
			var/datum/organ/external/temp = user:organs["r_hand"]
			if(!temp.destroyed)
				user.r_hand = src
			else
				user << "\blue You pick \the [src] up with your ha- wait a minute."
				if(loc == user)
					user.drop_from_slot(src)
				return
		else
			user.r_hand = src
	src.loc = user
	src.layer = 20
	add_fingerprint(user)
	user.update_clothing()
	return

/obj/item/attack_paw(mob/user as mob)

	if(isalien(user)) // -- TLE
		var/mob/living/carbon/alien/A = user

		if(!A.has_fine_manipulation || w_class <= 4)
			user << "Your claws aren't capable of such fine manipulation."
			return

	if (user.hand)
		if(ismonkey(user))
			var/datum/organ/external/temp = user:organs["l_hand"]
			if(temp.destroyed)
				user << "\blue Yo- wait a minute."
				return
	else
		if(ismonkey(user))
			var/datum/organ/external/temp = user:organs["r_hand"]
			if(temp.destroyed)
				user << "\blue Yo- wait a minute."

	if (istype(src.loc, /obj/item/weapon/storage))
		for(var/mob/M in range(1, src.loc))
			if (M.s_active == src.loc)
				if (M.client)
					M.client.screen -= src
	src.throwing = 0
	if (src.loc == user)
		//canremove==0 means that object may not be removed. You can still wear it. This only applies to clothing. /N
		if(istype(src, /obj/item/clothing) && !src:canremove)
			return
		else
			user.u_equip(src)
	else
		if(istype(src.loc, /mob/living))
			return
		src.pickup(user)
		user.lastDblClick = world.time + 2
		user.next_move = world.time + 2

	if (user.hand)
		user.l_hand = src
	else
		user.r_hand = src
	src.loc = user
	src.layer = 20
	user.update_clothing()
	return


/obj/item/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return

/obj/item/attack_self(mob/user as mob)
	..()
	if(twohanded)
		if(wielded) //Trying to unwield it
			wielded = 0
			force = force_unwielded
			src.name = "[initial(name)] (Unwielded)"
			src.update_icon() //If needed by the particular item
			user << "\blue You are now carrying the [initial(name)] with one hand."

			if(istype(user.get_inactive_hand(),/obj/item/weapon/offhand))
				del user.get_inactive_hand()
			return
		else //Trying to wield it
			if(user.get_inactive_hand())
				user << "\red You need your other hand to be empty"
				return
			wielded = 1
			force = force_wielded
			src.name = "[initial(name)] (Wielded)"
			src.update_icon() //If needed by the particular item
			user << "\blue You grab the [initial(name)] with both hands."

			var/obj/item/weapon/offhand/O = new /obj/item/weapon/offhand(user) ////Let's reserve his other hand~
			O.name = text("[initial(src.name)] - Offhand")
			O.desc = "Your second grip on the [initial(src.name)]"
			if(user.hand)
				user.r_hand = O          ///Place dat offhand in the opposite hand
			else
				user.l_hand = O
			O.layer = 20
			return

/obj/item/proc/attack(mob/living/M as mob, mob/living/user as mob, def_zone)

	if (!istype(M)) // not sure if this is the right thing...
		return
	var/messagesource = M

	if (istype(M,/mob/living/carbon/brain))
		messagesource = M:container
	if (src.hitsound)
		playsound(src.loc, hitsound, 50, 1, -1)
	M.flash_weak_pain()
	/////////////////////////
	user.lastattacked = M
	M.lastattacker = user

	var/power = src.force

	// EXPERIMENTAL: scale power and time to the weight class
	if(w_class >= 4.0 && !istype(src,/obj/item/weapon/melee/energy/blade)) // eswords are an exception, they only have a w_class of 4 to not fit into pockets
		power = power * 2.5

		user.visible_message("\red [user.name] swings at [M.name] with \the [src]!")
		user.next_move = max(user.next_move, world.time + 30)

		// if the mob didn't move, he has a 100% chance to hit(given the enemy also didn't move)
		// otherwise, the chance to hit is lower
		var/unmoved = 0
		spawn
			unmoved = do_after(user, 4)
		sleep(4)
		if( (!unmoved && !prob(70)) || (get_dist(user, M) != 1 && user != M))
			user.visible_message("\red [user.name] misses with \the [src]!")
			return


	user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(src.damtype)])</font>"
	M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(src.damtype)])</font>"
	log_admin("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	message_admins("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(src.damtype)])</font>" )

	//spawn(1800)            // this wont work right
	//	M.lastattacker = null
	/////////////////////////

	if(!istype(M, /mob/living/carbon/human))
		if(istype(M, /mob/living/carbon/metroid))
			var/mob/living/carbon/metroid/Metroid = M
			if(prob(25))
				user << "\red [src] passes right through [M]!"
				return

			if(power > 0)
				Metroid.attacked += 10

			if(power >= 3)
				if(istype(Metroid, /mob/living/carbon/metroid/adult))
					if(prob(5 + round(power/2)))

						if(Metroid.Victim)
							if(prob(80) && !Metroid.client)
								Metroid.Discipline++
						Metroid.Victim = null
						Metroid.anchored = 0

						if(prob(80) && !Metroid.client)
							Metroid.Discipline++

						spawn()
							if(Metroid)
								Metroid.SStun = 1
								sleep(rand(5,20))
								if(Metroid)
									Metroid.SStun = 0

						spawn(0)
							Metroid.canmove = 0
							step_away(Metroid, user)
							if(prob(25 + power*2))
								sleep(2)
								step_away(Metroid, user)
							Metroid.canmove = 1

				else
					if(prob(10 + power*2))

						if(Metroid.Victim)
							if(prob(80) && !Metroid.client)
								Metroid.Discipline++

								if(Metroid.Discipline == 1)
									Metroid.attacked = 0

							spawn()
								Metroid.SStun = 1
								sleep(rand(5,20))
								Metroid.SStun = 0

						Metroid.Victim = null
						Metroid.anchored = 0


						spawn(0)
							step_away(Metroid, user)
							Metroid.canmove = 0
							if(prob(25 + power*4))
								sleep(2)
								step_away(Metroid, user)
							Metroid.canmove = 1

		var/showname = "."
		if(user)
			showname = " by [user]."
		if(!(user in viewers(M, null)))
			showname = "."

		for(var/mob/O in viewers(messagesource, null))
			O.show_message(text("\red <B>[] has been attacked with [][] </B>", M, src, showname), 1)

		if(!showname && user)
			if(user.client)
				user << "\red <B>You attack [M] with [src]. </B>"



	if(istype(M, /mob/living/carbon/human))
		M:attacked_by(src, user, def_zone)
		var/mob/living/carbon/human/H = M
		if(H)
			H.UpdateDamageIcon()
			H.update_clothing()
		user.update_clothing()
	else
		switch(src.damtype)
			if("brute")
				if(istype(src, /mob/living/carbon/metroid))
					M.adjustBrainLoss(power)

				else

					M.take_organ_damage(power)
					if (prob(33)) // Added blood for whacking non-humans too
						var/turf/location = M.loc
						if (istype(location, /turf/simulated))
							location.add_blood_floor(M)
			if("fire")
				if (!(M.mutations & COLD_RESISTANCE))
					M.take_organ_damage(0, power)
					M << "Aargh it burns!"
		M.updatehealth()
	src.add_fingerprint(user)
	M.react_to_attack(user)
	return 1


/obj/item/proc/IsShield()
	return 0

/obj/item/proc/eyestab(mob/living/carbon/M as mob, mob/living/carbon/user as mob)

	var/mob/living/carbon/human/H = M
	if(istype(H) && ( \
			(H.head && H.head.flags & HEADCOVERSEYES) || \
			(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
			(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
		))
		// you can't stab someone in the eyes wearing a mask!
		user << "\red You're going to need to remove that mask/helmet/glasses first."
		return

	var/mob/living/carbon/monkey/Mo = M
	if(istype(Mo) && ( \
			(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
		))
		// you can't stab someone in the eyes wearing a mask!
		user << "\red You're going to need to remove that mask/helmet/glasses first."
		return

	if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/carbon/metroid))//Aliens don't have eyes./N     Metroids also don't have eyes!
		user << "\red You cannot locate any eyes on this creature!"
		return

	user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
	M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"

	log_admin("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	message_admins("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	log_attack("<font color='red'> [user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

	src.add_fingerprint(user)
	//if((user.mutations & CLUMSY) && prob(50))
	//	M = user
		/*
		M << "\red You stab yourself in the eye."
		M.sdisabilities |= 1
		M.weakened += 4
		M.adjustBruteLoss(10)
		*/
	if(M != user)
		for(var/mob/O in (viewers(M) - user - M))
			O.show_message("\red [M] has been stabbed in the eye with [src] by [user].", 1)
		M << "\red [user] stabs you in the eye with [src]!"
		user << "\red You stab [M] in the eye with [src]!"
	else
		user.visible_message( \
			"\red [user] has stabbed themself with [src]!", \
			"\red You stab yourself in the eyes with [src]!" \
		)
	if(istype(M, /mob/living/carbon/human))
		var/datum/organ/external/affecting = M:get_organ("head")
		affecting.take_damage(7)
	else
		M.take_organ_damage(7)
	M.eye_blurry += rand(3,4)
	M.eye_stat += rand(5,9)
	if (M.eye_stat >= 10)
		M.eye_blurry += 15+(0.1*M.eye_blurry)
		M.disabilities |= 1
		if(M.stat != 2)
			M << "\red Your eyes start to bleed profusely!"
		if(prob(50))
			if(M.stat != 2)
				M << "\red You drop what you're holding and clutch at your eyes!"
				M.drop_item()
			M.eye_blurry += 10
			M.Paralyse(1)
			M.Weaken(4)
		if (prob(M.eye_stat - 10 + 1))
			if(M.stat != 2)
				M << "\red You go blind!"
			M.disabilities |= 128
	return



/obj/item/missile
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	var/primed = null
	throwforce = 15

	throw_impact(atom/hit_atom)
		if(primed)
			explosion(hit_atom, 0, 0, 2, 4)
			del(src)
		else
			..()
		return
