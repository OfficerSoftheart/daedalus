/obj/structure/closet/secure_closet/medicine
	name = "Medicine Closet"
	desc = "Filled with medical junk."
	icon_state = "securemed1"
	icon_closed = "securemed"
	icon_locked = "securemed1"
	icon_opened = "securemedopen"
	icon_broken = "securemedbroken"
	icon_off = "securemed1"
	req_access = list(access_medical)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/syringes(src)
		new /obj/item/weapon/reagent_containers/dropper(src)
		new /obj/item/weapon/reagent_containers/dropper(src)
		new /obj/item/weapon/reagent_containers/glass/beaker(src)
		new /obj/item/weapon/reagent_containers/glass/beaker(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/antitoxin(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/antitoxin(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/inaprovaline(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/inaprovaline(src)
		return



/obj/structure/closet/secure_closet/anaesthetic
	name = "Anesthetic"
	desc = "Used to knock people out."
	icon_state = "securemed1"
	icon_closed = "securemed"
	icon_locked = "securemed1"
	icon_opened = "securemedopen"
	icon_broken = "securemedbroken"
	icon_off = "securemed1"
	req_access = list(access_medical)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/clothing/mask/breath/medical(src)
		new /obj/item/clothing/mask/breath/medical(src)
		new /obj/item/clothing/mask/breath/medical(src)
		return



/obj/structure/closet/secure_closet/doctor_personal
	name = "Doctor's Locker"
	req_access = list(access_medical)
	icon_state = "securemed1"
	icon_closed = "securemed"
	icon_locked = "securemed1"
	icon_opened = "securemedopen"
	icon_broken = "securemedbroken"
	icon_off = "securemed1"

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/doctor(src)
		//
		var/obj/item/weapon/storage/backpack/medic/BPK = new /obj/item/weapon/storage/backpack/medic(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/pda/medical(src)
		new /obj/item/weapon/storage/firstaid/regular(src)
		new /obj/item/device/flashlight/pen(src)
		new /obj/item/weapon/cartridge/medical(src)
		new /obj/item/device/radio/headset/headset_med(src)
		return

/obj/structure/closet/secure_closet/chemist_personal
	name = "Chemist's Locker"
	req_access = list(ACCESS_CHEMISTRY)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/chemist(src)
		//
		var/obj/item/weapon/storage/backpack/medic/BPK = new /obj/item/weapon/storage/backpack/medic(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/radio/headset/headset_medsci(src)
		new /obj/item/device/pda/toxins(src)
		return

/obj/structure/closet/secure_closet/genetics_personal
	name = "Geneticist's Locker"
	req_access = list(access_medlab)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/geneticist(src)
		//
		var/obj/item/weapon/storage/backpack/medic/BPK = new /obj/item/weapon/storage/backpack/medic(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/pda/medical(src)
		new /obj/item/device/flashlight/pen(src)
		new /obj/item/device/radio/headset/headset_medsci(src)

/obj/structure/closet/secure_closet/viro_personal
	name = "Virologist's Locker"
	req_access = list(ACCESS_VIROLOGY)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/virologist(src)
		//
		var/obj/item/weapon/storage/backpack/medic/BPK = new /obj/item/weapon/storage/backpack/medic(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/flashlight/pen(src)
		new /obj/item/device/pda/medical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/device/radio/headset/headset_med(src)

/obj/structure/closet/secure_closet/CMO
	name = "Chief Medical Officer's Locker"
	req_access = list(access_cmo)
	icon_state = "cmosecure1"
	icon_closed = "cmosecure"
	icon_locked = "cmosecure1"
	icon_opened = "cmosecureopen"
	icon_broken = "cmosecurebroken"
	icon_off = "cmosecure1"

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/cmo(src)
		//
		var/obj/item/weapon/storage/backpack/medic/BPK = new /obj/item/weapon/storage/backpack/medic(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/pda/heads/cmo(src)
		new /obj/item/weapon/storage/firstaid/regular(src)
		new /obj/item/device/flashlight/pen(src)
		new /obj/item/weapon/cartridge/cmo(src)
		new /obj/item/device/radio/headset/heads/cmo(src)
		return



/obj/structure/closet/secure_closet/animal
	name = "Animal Control"
	req_access = list(access_medical)


	New()
		..()
		sleep(2)
		new /obj/item/device/assembly/signaler(src)
		new /obj/item/device/radio/electropack(src)
		new /obj/item/device/radio/electropack(src)
		new /obj/item/device/radio/electropack(src)
		return



/obj/structure/closet/secure_closet/chemical
	name = "Chemical Closet"
	desc = "Store dangerous chemicals in here."
	icon_state = "securemed1"
	icon_closed = "securemed"
	icon_locked = "securemed1"
	icon_opened = "securemedopen"
	icon_broken = "securemedbroken"
	icon_off = "securemed1"
	req_access = list(access_medical)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/pillbottlebox(src)
		new /obj/item/weapon/storage/pillbottlebox(src)
		return