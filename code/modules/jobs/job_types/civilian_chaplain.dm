//Due to how large this one is it gets its own file
/*
Chaplain
*/
/datum/job/chaplain
	title = "Kaplan"
	flag = CHAPLAIN
	department_head = list("Szef Personelu")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "szef personelu"
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/chaplain

	access = list(access_morgue, access_chapel_office, access_crematorium, access_theatre)
	minimal_access = list(access_morgue, access_chapel_office, access_crematorium, access_theatre)

/datum/outfit/job/chaplain
	name = "Chaplain"

	belt = /obj/item/device/pda/chaplain
	uniform = /obj/item/clothing/under/rank/chaplain
	backpack_contents = list(/obj/item/device/camera/spooky = 1)
	backpack = /obj/item/weapon/storage/backpack/cultpack
	satchel = /obj/item/weapon/storage/backpack/cultpack


/datum/outfit/job/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/weapon/storage/book/bible/B = new /obj/item/weapon/storage/book/bible/booze(H)
	var/new_religion = "Chrzescijanstwo"
	if(H.client && H.client.prefs.custom_names["religion"])
		new_religion = H.client.prefs.custom_names["religion"]

	switch(lowertext(new_religion))
		if("chrzescijanstwo", "katolicyzm", "protestantyzm", "luteranizm")
			B.name = pick("Biblia")
		if("szatanizm", "satanizm", "satanism")
			B.name = "Czarna Ksiega"
		if("cthulu")
			B.name = "Necronomicon"
		if("islam", "sunnizm", "muzulmanstwo", "szyizm")
			B.name = "Koran"
		if("scientology")
			B.name = pick("The Biography of L. Ron Hubbard","Dianetics")
		if("chaos")
			B.name = "The Book of Lorgar"
		if("imperium")
			B.name = "Uplifting Primer"
		if("toolboxia")
			B.name = "Toolbox Manifesto"
		if("homosexuality")
			B.name = "Guys Gone Wild"
		if("lol", "wtf", "gay", "penis", "ass", "poo", "badmin", "shitmin", "deadmin", "cock", "cocks", "meme", "memes")
			B.name = pick("Woodys Got Wood: The Aftermath", "War of the Cocks", "Sweet Bro and Hella Jef: Expanded Edition")
			H.setBrainLoss(100) // starts off retarded as fuck
		if("science")
			B.name = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
		else
			B.name = "Swieta Ksiega religii [new_religion]"
	feedback_set_details("religion_name","[new_religion]")
	ticker.Bible_name = B.name

	var/new_deity = "Jezus Chrustus"
	if(H.client && H.client.prefs.custom_names["deity"])
		new_deity = H.client.prefs.custom_names["deity"]
	B.deity_name = new_deity

	if(ticker)
		ticker.Bible_deity_name = B.deity_name
	feedback_set_details("religion_deity","[new_deity]")
	H.equip_to_slot_or_del(B, slot_in_backpack)