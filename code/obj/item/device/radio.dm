/obj/item/device/radio
	icon = 'icons/obj/radio.dmi'
	name = "station bounced radio"
	suffix = "\[3\]"
	icon_state = "walkietalkie"
	item_state = "walkietalkie"
	var
		on = 1 // 0 for off
		last_transmission
		frequency = 1459 //common chat
		traitor_frequency = 0 //tune to frequency to unlock traitor supplies
		canhear_range = 3 // the range which mobs can hear this radio from
		obj/item/device/radio/patch_link = null
		obj/item/device/uplink/radio/traitorradio = null
		wires = WIRE_SIGNAL | WIRE_RECEIVE | WIRE_TRANSMIT
		b_stat = 0
		broadcasting = 0
		listening = 1
		freerange = 0 // 0 - Sanitize frequencies, 1 - Full range
		list/channels = list() //see communications.dm for full list. First channes is a "default" for :h
		subspace_transmission = 0
//			"Example" = FREQ_LISTENING|FREQ_BROADCASTING
	flags = 450		// hello i'm a fucking idiot why is this 450?? CODE GODS PLEASE EXPLAIN~
	throw_speed = 2
	throw_range = 9
	w_class = 2
	g_amt = 25
	m_amt = 75
	var/const
		WIRE_SIGNAL = 1 //sends a signal, like to set off a bomb or electrocute someone
		WIRE_RECEIVE = 2
		WIRE_TRANSMIT = 4
		TRANSMISSION_DELAY = 5 // only 2/second/radio
		FREQ_LISTENING = 1
		//FREQ_BROADCASTING = 2


/obj/item/device/radio
	var
		datum/radio_frequency/radio_connection
		list/datum/radio_frequency/secure_radio_connections = new
	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)



/obj/item/device/radio/New()
	..()
	if(radio_controller)
		initialize()

	// If intercom: do a local power check loop
	if(istype(src, /obj/item/device/radio/intercom))
		spawn(5)
			checkpower()

/obj/item/device/radio/initialize()

	if(freerange)
		if(frequency < 1200 || frequency > 1600)
			frequency = sanitize_frequency(frequency)
	else if (frequency < 1441 || frequency > 1489)
		world.log << "[src] ([type]) has a frequency of [frequency], sanitizing."
		frequency = sanitize_frequency(frequency)

	set_frequency(frequency)

	for (var/ch_name in channels)
		secure_radio_connections[ch_name] = radio_controller.add_object(src, radiochannels[ch_name],  RADIO_CHAT)


/obj/item/device/radio/attack_self(mob/user as mob)
	user.machine = src
	interact(user)

/obj/item/device/radio/proc/interact(mob/user as mob)
	if(!on)
		return

	var/dat = {"
				<html><head><title>[src]</title></head><body><TT>
				Microphone: [broadcasting ? "<A href='byond://?src=\ref[src];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];talk=1'>Disengaged</A>"]<BR>
				Speaker: [listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
				Frequency:
				<A href='byond://?src=\ref[src];freq=-10'>-</A>
				<A href='byond://?src=\ref[src];freq=-2'>-</A>
				[format_frequency(frequency)]
				<A href='byond://?src=\ref[src];freq=2'>+</A>
				<A href='byond://?src=\ref[src];freq=10'>+</A><BR>
				"}

	for (var/ch_name in channels)
		dat+=text_sec_channel(ch_name, channels[ch_name])
	dat+={"[text_wires()]</TT></body></html>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/device/radio/proc/text_wires()
	if (!b_stat)
		return ""
	return {"
			<hr>
			Green Wire: <A href='byond://?src=\ref[src];wires=4'>[(wires & 4) ? "Cut" : "Mend"] Wire</A><BR>
			Red Wire:   <A href='byond://?src=\ref[src];wires=2'>[(wires & 2) ? "Cut" : "Mend"] Wire</A><BR>
			Blue Wire:  <A href='byond://?src=\ref[src];wires=1'>[(wires & 1) ? "Cut" : "Mend"] Wire</A><BR>
			"}


/obj/item/device/radio/proc/text_sec_channel(var/chan_name, var/chan_stat)
	var/list = !!(chan_stat&FREQ_LISTENING)!=0
	return {"
			<B>[chan_name]</B><br>
			Speaker: <A href='byond://?src=\ref[src];ch_name=[chan_name];listen=[!list]'>[list ? "Engaged" : "Disengaged"]</A><BR>
			"}

/obj/item/device/radio/proc/checkpower()

	// Simple loop, checks for power. Strictly for intercoms
	while(src)

		if(!src.loc)
			on = 0
		else
			var/area/A = src.loc.loc
			if(!A || !isarea(A) || !A.master)
				on = 0
			else
				on = A.master.powered(EQUIP) // set "on" to the power status

		if(!on)
			icon_state = "intercom-p"
		else
			icon_state = "intercom"

		sleep(30)

/obj/item/device/radio/Topic(href, href_list)
	//..()
	if (usr.stat || !on)
		return

	if (!(issilicon(usr) || (usr.contents.Find(src) || ( in_range(src, usr) && istype(loc, /turf) ))))
		usr << browse(null, "window=radio")
		return
	usr.machine = src
	if (href_list["track"])
		var/mob/target = locate(href_list["track"])
		var/mob/living/silicon/ai/A = locate(href_list["track2"])
		if(A && target)
			A.ai_actual_track(target)
		return

	else if (href_list["faketrack"])
		var/mob/target = locate(href_list["track"])
		var/mob/living/silicon/ai/A = locate(href_list["track2"])
		if(A && target)

			A:cameraFollow = target
			A << text("Now tracking [] on camera.", target.name)
			if (usr.machine == null)
				usr.machine = usr

			while (usr:cameraFollow == target)
				usr << "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb)."
				sleep(40)
				continue

		return

	else if (href_list["freq"])
		var/new_frequency = (frequency + text2num(href_list["freq"]))
		if (!freerange || (frequency < 1200 || frequency > 1600))
			new_frequency = sanitize_frequency(new_frequency)
		set_frequency(new_frequency)

		if (traitor_frequency && frequency == traitor_frequency)
			usr.machine = null
			usr << browse(null, "window=radio")
			// now transform the regular radio, into a (disguised)syndicate uplink!
			var/obj/item/device/uplink/radio/T = traitorradio
			var/obj/item/device/radio/R = src
			R.loc = T
			T.loc = usr
			T.layer = R.layer
			R.layer = 0
			if (usr.client)
				usr.client.screen -= R
			if (usr.r_hand == R)
				usr.u_equip(R)
				usr.r_hand = T
			else
				usr.u_equip(R)
				usr.l_hand = T
			R.loc = T
			T.attack_self(usr)
			return
	else if (href_list["talk"])
		broadcasting = text2num(href_list["talk"])
	else if (href_list["listen"])
		var/chan_name = href_list["ch_name"]
		if (!chan_name)
			listening = text2num(href_list["listen"])
		else
			if (channels[chan_name] & FREQ_LISTENING)
				channels[chan_name] &= ~FREQ_LISTENING
			else
				channels[chan_name] |= FREQ_LISTENING
	else if (href_list["wires"])
		var/t1 = text2num(href_list["wires"])
		if (!( istype(usr.equipped(), /obj/item/weapon/wire_cutters) ))
			return
		if (wires & t1)
			wires &= ~t1
		else
			wires |= t1
	if (!( master ))
		if (istype(loc, /mob))
			interact(loc)
		else
			updateDialog()
	else
		if (istype(master.loc, /mob))
			interact(master.loc)
		else
			updateDialog()
	add_fingerprint(usr)

/obj/item/device/radio/proc/autosay(var/message, var/from, var/channel)
	var/datum/radio_frequency/connection = null
	if(channel && channels && channels.len > 0)
		if (channel == "department")
			//world << "DEBUG: channel=\"[channel]\" switching to \"[channels[1]]\""
			channel = channels[1]
		connection = secure_radio_connections[channel]
	else
		connection = radio_connection
		channel = null
	if (!istype(connection))
		return
	if (!connection)
		return

	Broadcast_Message(connection, new /mob/living/silicon/ai(src), 0, "*garbled automated announcement*",
					  src, message, from, "Automated Announcement", from, "synthesized voice", 4, 0)
	return

/obj/item/device/radio/talk_into(mob/M as mob, message, channel)

	if(!on) return // the device has to be on
/*  Fix for permacell radios, but kinda eh about actually fixing them.
	if(!(src.wires & WIRE_TRANSMIT)) // The device has to have all its wires and shit intact
		return
*/


	/* Quick introduction:
		This new radio system uses a very robust FTL signaling technology unoriginally
		dubbed "subspace" which is somewhat similar to 'blue-space' but can't
		actually transmit large mass. Headsets are the only radio devices capable
		of sending subspace transmissions to the Communications Satellite.

		A headset sends a signal to a subspace listener/reciever elsewhere in space,
		the signal gets processed and logged, and an audible transmission gets sent
		to each individual headset.
	*/

	//#### Grab the connection datum ####//
	var/datum/radio_frequency/connection = null
	if(channel && channels && channels.len > 0)
		if (channel == "department")
			//world << "DEBUG: channel=\"[channel]\" switching to \"[channels[1]]\""
			channel = channels[1]
		connection = secure_radio_connections[channel]
	else
		connection = radio_connection
		channel = null
	if (!istype(connection))
		return
	if (!connection)
		return



	//#### Tagging the signal with all appropriate identity values ####//

	// ||-- The mob's name identity --||
	var/displayname = M.name	// grab the display name (name you get when you hover over someone's icon)
	var/real_name = M.real_name // mob's real name
	var/mobkey = "none" // player key associated with mob
	var/voicemask = 0 // the speaker is wearing a voice mask
	if(M.client)
		mobkey = M.key // assign the mob's key


	var/jobname // the mob's "job"

	// --- Human: use their actual job ---
	if (ishuman(M))
		jobname = M:get_assignment()

	// --- Carbon Nonhuman ---
	else if (iscarbon(M)) // Nonhuman carbon mob
		jobname = "No id"

	// --- AI ---
	else if (isAI(M))
		jobname = "AI"

	// --- Cyborg ---
	else if (isrobot(M))
		jobname = "Cyborg"

	// --- Personal AI (pAI) ---
	else if (istype(M, /mob/living/silicon/pai))
		jobname = "Personal AI"

	// --- Unidentifiable mob ---
	else
		jobname = "Unknown"


	// --- Modifications to the mob's identity ---

	// The mob is disguising their identity:
	if (istype(M.wear_mask, /obj/item/clothing/mask/gas/voice))
		if(M.wear_mask:vchange)
			displayname = M.wear_mask:voice
			jobname = "Unknown"
		voicemask = 1



  /* ###### Radio headsets can only broadcast through subspace ###### */

	if(subspace_transmission)
		// First, we want to generate a new radio signal
		var/datum/signal/signal = new
		signal.transmission_method = 2 // 2 would be a subspace transmission.
										// transmission_method could probably be enumerated through #define. Would be neater.

		// --- Finally, tag the actual signal with the appropriate values ---
		signal.data = list(
		  // Identity-associated tags:
			"mob" = M, // store a reference to the mob
			"mobtype" = M.type, 	// the mob's type
			"realname" = real_name, // the mob's real name
			"name" = displayname,	// the mob's display name
			"job" = jobname,		// the mob's job
			"key" = mobkey,			// the mob's key
			"vmessage" = M.voice_message, // the message to display if the voice wasn't understood
			"vname" = M.voice_name, // the name to display if the voice wasn't understood
			"vmask" = voicemask,	// 1 if the mob is using a voice gas mask

			// We store things that would otherwise be kept in the actual mob
			// so that they can be logged even AFTER the mob is deleted or something

		  // Other tags:
			"compression" = rand(45,50), // compressed radio signal
			"message" = message, // the actual sent message
			"connection" = connection, // the radio connection to use
			"radio" = src, // stores the radio used for transmission
			"slow" = 0, // how much to sleep() before broadcasting - simulates net lag
			"traffic" = 0, // dictates the total traffic sum that the signal went through
			"type" = 0, // determines what type of radio input it is: normal broadcast
			"server" = null, // the last server to log this signal
			"reject" = 0	// if nonzero, the signal will not be accepted by any broadcasting machinery
		)
		signal.frequency = connection.frequency // Quick frequency set

	  //#### Sending the signal to all subspace receivers ####//
		for(var/obj/machinery/telecomms/receiver/R in world)
			R.receive_signal(signal)

		// Allinone can act as receivers.
		for(var/obj/machinery/telecomms/allinone/R in world)
			R.receive_signal(signal)

		// Receiving code can be located in Telecommunications.dm
		return


  /* ###### Intercoms and station-bounced radios ###### */

	var/filter_type = 2

	/* --- Intercoms can only broadcast to other intercoms, but bounced radios can broadcast to bounced radios and intercoms --- */
	if(istype(src, /obj/item/device/radio/intercom))
		filter_type = 1


	var/datum/signal/signal = new
	signal.transmission_method = 2


	/* --- Try to send a normal subspace broadcast first */

	signal.data = list(

		"mob" = M, // store a reference to the mob
		"mobtype" = M.type, 	// the mob's type
		"realname" = real_name, // the mob's real name
		"name" = displayname,	// the mob's display name
		"job" = jobname,		// the mob's job
		"key" = mobkey,			// the mob's key
		"vmessage" = M.voice_message, // the message to display if the voice wasn't understood
		"vname" = M.voice_name, // the name to display if the voice wasn't understood
		"vmask" = voicemask,	// 1 if the mob is using a voice gas mas

		"compression" = 0, // uncompressed radio signal
		"message" = message, // the actual sent message
		"connection" = connection, // the radio connection to use
		"radio" = src, // stores the radio used for transmission
		"slow" = 0,
		"traffic" = 0,
		"type" = 0,
		"server" = null,
		"reject" = 0
	)
	signal.frequency = connection.frequency // Quick frequency set

	for(var/obj/machinery/telecomms/receiver/R in world)
		R.receive_signal(signal)


	sleep(rand(10,25)) // wait a little...

	if(signal.data["done"])
		// we're done here.
		return

	// Oh my god; the comms are down or something because the signal hasn't been broadcasted yet.
	// Send a mundane broadcast with limited targets:

	Broadcast_Message(connection, M, voicemask, M.voice_message,
					  src, message, displayname, jobname, real_name, M.voice_name,
							filter_type, signal.data["compression"])




/obj/item/device/radio/hear_talk(mob/M as mob, msg)

	if (broadcasting)
		talk_into(M, msg)
/*
/obj/item/device/radio/proc/accept_rad(obj/item/device/radio/R as obj, message)

	if ((R.frequency == frequency && message))
		return 1
	else if

	else
		return null
	return
*/
/obj/item/device/radio/proc/send_hear(freq)
	/*

		I'm removing this because this is apparently a REALLY REALLY bad thing and causes
		people's transmissions to get cut off. This also means radios have no delay. A
		fair price to pay for reliable radios. -- Doohl

	if(last_transmission && world.time < (last_transmission + TRANSMISSION_DELAY))
		return
	last_transmission = world.time
	*/
	if (!(wires & WIRE_RECEIVE))
		return
	if (!on)
		return
	if (!freq) //recieved on main frequency
		if (!listening)
			return
	else
		var/accept = (freq==frequency && listening)
		if (!accept)
			for (var/ch_name in channels)
				var/datum/radio_frequency/RF = secure_radio_connections[ch_name]
				if (RF.frequency==freq && (channels[ch_name]&FREQ_LISTENING))
					accept = 1
					break
		if (!accept)
			return

	/*		// UURAAAGH ALL THE CPUS, WASTED. ALL OF THEM. NO. -- Doohl
	var/turf/T = get_turf(src)
	var/list/hear = hearers(1, T)
	var/list/V
	//find mobs in lockers, cryo and intellicards, brains, MMIs, and so on.
	for (var/mob/M in world)
		if (isturf(M.loc))
			continue //if M can hear us it is already was found by hearers()
		if (!M.client)
			continue //skip monkeys and leavers
		if (!V) //lasy initialisation
			V = view(1, T)
		if (get_turf(M) in V) //this slow, but I don't think we'd have a lot of wardrobewhores every round --rastaf0
			hear+=M
	*/

	/* Instead, let's individually search potential containers for mobs! More verbose but a LOT more efficient and less laggy */
	// Check gamehelpers.dm for the proc definition:

	return get_mobs_in_view(canhear_range, src)

/obj/item/device/radio/examine()
	set src in view()

	..()
	if ((in_range(src, usr) || loc == usr))
		if (b_stat)
			usr.show_message("\blue \the [src] can be attached and modified!")
		else
			usr.show_message("\blue \the [src] can not be modified or attached!")
	return

/obj/item/device/radio/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	user.machine = src
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	b_stat = !( b_stat )
	if(!istype(src, /obj/item/device/radio/beacon))
		if (b_stat)
			user.show_message("\blue The radio can now be attached and modified!")
		else
			user.show_message("\blue The radio can no longer be modified or attached!")
		updateDialog()
			//Foreach goto(83)
		add_fingerprint(user)
		return
	else return

/obj/item/device/radio/emp_act(severity)
	broadcasting = 0
	listening = 0
	for (var/ch_name in channels)
		channels[ch_name] = 0
	..()

/obj/item/device/radio/proc/config(op)
	for (var/ch_name in channels)
		radio_controller.remove_object(src, radiochannels[ch_name])
	secure_radio_connections = new
	channels = op
	for (var/ch_name in op)
		secure_radio_connections[ch_name] = radio_controller.add_object(src, radiochannels[ch_name],  RADIO_CHAT)
	return
