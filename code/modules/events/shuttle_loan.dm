#define HIJACK_SYNDIE 1
#define RUSKY_PARTY 2
#define SPIDER_GIFT 3
#define DEPARTMENT_RESUPPLY 4
#define ANTIDOTE_NEEDED 5


/datum/round_event_control/shuttle_loan
	name = "Shuttle loan"
	typepath = /datum/round_event/shuttle_loan
	max_occurrences = 1
	earliest_start = 4000

/datum/round_event/shuttle_loan
	announceWhen = 1
	endWhen = 500
	var/dispatched = 0
	var/dispatch_type = 0
	var/bonus_points = 10000
	var/thanks_msg = "Statek cargo powinien przyleciec za 5 minut. Macie troche punktow za fatyge."

/datum/round_event/shuttle_loan/start()
	dispatch_type = pick(HIJACK_SYNDIE, RUSKY_PARTY, SPIDER_GIFT, DEPARTMENT_RESUPPLY, ANTIDOTE_NEEDED)

/datum/round_event/shuttle_loan/announce()
	SSshuttle.shuttle_loan = src
	switch(dispatch_type)
		if(HIJACK_SYNDIE)
			priority_announce("Cargo: Syndykat proboje zinfiltrowac wasza stacje. Jesli pozwolicie im porwac wasz statek cargo to zaoszczedzicie nam klopotow.","Wydzial Kontrwywiadu")
		if(RUSKY_PARTY)
			priority_announce("Cargo: Grupa wkurwionych Rosjan chce sie pobawic, mozecie im wyslac swoj statek cargo a potem sie nimi zajac?","Wydzial Przyjazni z Rosjanami")
		if(SPIDER_GIFT)
			priority_announce("Cargo: Klan pajakow wyslal nam tajemniczy prezent. Mozemy go wam wyslac byscie mogli sprawdzic co jest w srodku?","Wydzial Dyplomacji")
		if(DEPARTMENT_RESUPPLY)
			priority_announce("Cargo: Wyglada na to ze zamowilismy w tym miesiacu za duzo paczek uzupelniajacych. Mozemy wam wyslac nadwyzke?","Wydzial Dostaw")
			thanks_msg = "The cargo shuttle should return in 5 minutes."
			bonus_points = 0
		if(ANTIDOTE_NEEDED)
			priority_announce("Cargo: Wasza stacja zostala wybrana do udzialu w programie badan epidemiologicznych. Wyslijcie nam swoj statek cargo, a wyslemy wam pierwsze probki.", "Wydzial Badan")

/datum/round_event/shuttle_loan/proc/loan_shuttle()
	priority_announce(thanks_msg, "Cargo shuttle commandeered by Centcom.")

	dispatched = 1
	SSshuttle.points += bonus_points
	endWhen = activeFor + 1

	SSshuttle.supply.sell()
	SSshuttle.supply.enterTransit()
	if(SSshuttle.supply.z != ZLEVEL_STATION)
		SSshuttle.supply.mode = SHUTTLE_CALL
		SSshuttle.supply.destination = SSshuttle.getDock("supply_home")
	else
		SSshuttle.supply.mode = SHUTTLE_RECALL
	SSshuttle.supply.setTimer(3000)

	switch(dispatch_type)
		if(HIJACK_SYNDIE)
			SSshuttle.centcom_message += "Statek porwany przez Syndykat nadlatuje."
		if(RUSKY_PARTY)
			SSshuttle.centcom_message += "Wkurwieni Rosjanie nadlatuja."
		if(SPIDER_GIFT)
			SSshuttle.centcom_message += "Prezent od klanu pajakow nadlatuje."
		if(DEPARTMENT_RESUPPLY)
			SSshuttle.centcom_message += "Nadwyzka paczek uzupelniajacych nadlatuje."
		if(ANTIDOTE_NEEDED)
			SSshuttle.centcom_message += "Probki wirusow nadlatuja."

/datum/round_event/shuttle_loan/tick()
	if(dispatched)
		if(SSshuttle.supply.mode != SHUTTLE_IDLE)
			endWhen = activeFor
		else
			endWhen = activeFor + 1

/datum/round_event/shuttle_loan/end()
	if(SSshuttle.shuttle_loan && SSshuttle.shuttle_loan.dispatched)
		//make sure the shuttle was dispatched in time
		SSshuttle.shuttle_loan = null

		var/list/empty_shuttle_turfs = list()
		for(var/turf/open/floor/T in SSshuttle.supply.areaInstance)
			if(T.density || T.contents.len)
				continue
			empty_shuttle_turfs += T
		if(!empty_shuttle_turfs.len)
			return

		var/list/shuttle_spawns = list()
		switch(dispatch_type)
			if(HIJACK_SYNDIE)
				var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/emergency/specialops]
				pack.generate(pick_n_take(empty_shuttle_turfs))

				shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate)
				if(prob(75))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate)

			if(RUSKY_PARTY)
				var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/organic/party]
				pack.generate(pick_n_take(empty_shuttle_turfs))

				shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian/ranged)	//drops a mateba
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/bear)
				if(prob(75))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/bear)

			if(SPIDER_GIFT)
				var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/emergency/specialops]
				pack.generate(pick_n_take(empty_shuttle_turfs))

				shuttle_spawns.Add(/mob/living/simple_animal/hostile/poison/giant_spider)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/poison/giant_spider)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/poison/giant_spider/nurse)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/poison/giant_spider/hunter)

				var/turf/T = pick(empty_shuttle_turfs)
				empty_shuttle_turfs.Remove(T)

				new /obj/effect/decal/remains/human(T)
				new /obj/item/clothing/shoes/space_ninja(T)
				new /obj/item/clothing/mask/balaclava(T)

				T = pick(empty_shuttle_turfs)
				new /obj/effect/spider/stickyweb(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/spider/stickyweb(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/spider/stickyweb(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/spider/stickyweb(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/spider/stickyweb(T)

			if(ANTIDOTE_NEEDED)
				var/virus_type = pick(/datum/disease/beesease, /datum/disease/brainrot, /datum/disease/fluspanish)
				var/turf/T
				for(var/i=0, i<10, i++)
					if(prob(15))
						shuttle_spawns.Add(/obj/item/weapon/reagent_containers/glass/bottle)
					else if(prob(15))
						shuttle_spawns.Add(/obj/item/weapon/reagent_containers/syringe)
					else if(prob(25))
						shuttle_spawns.Add(/obj/item/weapon/shard)
					T = pick_n_take(empty_shuttle_turfs)
					var/obj/effect/decal/cleanable/blood/b = new(T)
					var/datum/disease/D = new virus_type()
					D.longevity = 1000
					b.viruses += D
					D.holder = b
				shuttle_spawns.Add(/obj/structure/closet/crate)
				shuttle_spawns.Add(/obj/item/weapon/reagent_containers/glass/bottle/pierrot_throat)
				shuttle_spawns.Add(/obj/item/weapon/reagent_containers/glass/bottle/magnitis)

			if(DEPARTMENT_RESUPPLY)
				var/list/crate_types = list(
					/datum/supply_pack/emergency/equipment,
					/datum/supply_pack/security/supplies,
					/datum/supply_pack/organic/food,
					/datum/supply_pack/emergency/weedcontrol,
					/datum/supply_pack/engineering/tools,
					/datum/supply_pack/engineering/engiequipment,
					/datum/supply_pack/science/robotics,
					/datum/supply_pack/science/plasma,
					/datum/supply_pack/medical/supplies
					)
				for(var/crate in crate_types)
					var/datum/supply_pack/pack = SSshuttle.supply_packs[crate]
					pack.generate(pick_n_take(empty_shuttle_turfs))

				for(var/i in 1 to 5)
					var/decal = pick(/obj/effect/decal/cleanable/flour, /obj/effect/decal/cleanable/robot_debris, /obj/effect/decal/cleanable/oil)
					new decal(pick_n_take(empty_shuttle_turfs))

		var/false_positive = 0
		while(shuttle_spawns.len && empty_shuttle_turfs.len)
			var/turf/T = pick_n_take(empty_shuttle_turfs)
			if(T.contents.len && false_positive < 5)
				false_positive++
				continue

			var/spawn_type = pick_n_take(shuttle_spawns)
			new spawn_type(T)

#undef HIJACK_SYNDIE
#undef RUSKY_PARTY
#undef SPIDER_GIFT
#undef DEPARTMENT_RESUPPLY
#undef ANTIDOTE_NEEDED