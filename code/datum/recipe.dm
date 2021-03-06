/* * * * * * * * * * * * * * * * * * * * * * * * * *
 * /datum/recipe by rastaf0            13 apr 2011 *
 * * * * * * * * * * * * * * * * * * * * * * * * * *
 * This is powerful and flexible recipe system.
 * It exists not only for food.
 * supports both reagents and objects as prerequisites.
 * In order to use this system you have to define a deriative from /datum/recipe
 * * reagents are reagents. Acid, milc, booze, etc.
 * * items are objects. Fruits, tools, circuit boards.
 * * result is type to create as new object
 * * time is optional parameter, you shall use in in your machine, 
     default /datum/recipe/ procs does not rely on this parameter.
 *
 *  Functions you need:
 *  /datum/recipe/proc/make(var/obj/container as obj)
 *    Creates result inside container,
 *    deletes prerequisite reagents, 
 *    transfers reagents from prerequisite objects,
 *    deletes all prerequisite objects (even not needed for recipe at the moment).
 * 
 *  Functions you do not need to call directly but could:
 *  /datum/recipe/proc/check_reagents(var/datum/reagents/avail_reagents)
 *    //1=precisely,  0=insufficiently, -1=superfluous
 * 
 *  /datum/recipe/proc/check_items(var/obj/container as obj)
 *    //1=precisely, 0=insufficiently, -1=superfluous
 * 
 * */

/datum/recipe
	var/list/reagents // example:  = list("berryjuice" = 5) // do not list same reagent twice
	var/list/items // example: =list(/obj/item/weapon/crowbar, /obj/item/weapon/welder) // place /foo/bar before /foo
	var/result //example: = /obj/item/weapon/reagent_containers/food/snacks/donut
	var/time = 100 // 1/10 part of second


/datum/recipe/proc/check_reagents(var/datum/reagents/avail_reagents) //1=precisely, 0=insufficiently, -1=superfluous
	. = 1
	for (var/r_r in reagents)
		var/aval_r_amnt = avail_reagents.get_reagent_amount(r_r)
		if (!(abs(aval_r_amnt - reagents[r_r])<0.5)) //if NOT equals
			if (aval_r_amnt>reagents[r_r])
				. = -1
			else
				return 0
	if ((reagents?(reagents.len):(0)) < avail_reagents.reagent_list.len)
		return -1
	return .
	
/datum/recipe/proc/check_items(var/obj/container as obj) //1=precisely, 0=insufficiently, -1=superfluous
	if (!items)
		if (locate(/obj/) in container)
			return -1
		else
			return 1
	. = 1
	var/list/checklist = items.Copy()
	for (var/obj/O in container)
		var/found = 0
		for (var/type in checklist)
			if (istype(O,type))
				checklist-=type
				found = 1
				break
		if (!found)
			. = -1
	if (checklist.len)
		return 0
	return .

//general version
/datum/recipe/proc/make(var/obj/container as obj)
	var/obj/result_obj = new result(container)
	for (var/obj/O in (container.contents-result_obj))
		O.reagents.trans_to(result_obj, O.reagents.total_volume)
		del(O)
	container.reagents.clear_reagents()
	return result_obj

// food-related
/datum/recipe/proc/make_food(var/obj/container as obj)
	var/obj/result_obj = new result(container)
	for (var/obj/O in (container.contents-result_obj))
		if (O.reagents)
			O.reagents.del_reagent("nutriment")
			O.reagents.update_total()
			O.reagents.trans_to(result_obj, O.reagents.total_volume)
		del(O)
	container.reagents.clear_reagents()
	return result_obj
