/turf
	var/list/affecting_lights
	#if LIGHTING_RESOLUTION == 1
	var/atom/movable/lighting_overlay/lighting_overlay
	#else
	var/list/lighting_overlays[0]
	#endif

/turf/proc/reconsider_lights()
	for(var/datum/light_source/L in affecting_lights)
		L.force_update()

/turf/proc/lighting_clear_overlays()
//	testing("Clearing lighting overlays on \the [src]")
	#if LIGHTING_RESOLUTION == 1
	if(lighting_overlay)
		returnToPool(lighting_overlay)
	#else
	for(var/atom/movable/lighting_overlay/L in lighting_overlays)
		returnToPool(L)
	#endif

/turf/proc/lighting_build_overlays()
	#if LIGHTING_RESOLUTION == 1
	if(lighting_overlay)
	#else
	if(lighting_overlays.len)
	#endif
		return

	var/state = "light[LIGHTING_RESOLUTION]"
	var/area/A = loc
	if(A.lighting_use_dynamic)
		#if LIGHTING_RESOLUTION == 1
		var/atom/movable/lighting_overlay/O = new(src)
		O.icon_state = state
		lighting_overlay = O
		all_lighting_overlays |= O
		#else
		for(var/i = 0; i < LIGHTING_RESOLUTION; i++)
			for(var/j = 0; j < LIGHTING_RESOLUTION; j++)
				var/atom/movable/lighting_overlay/O = new(src)
				O.pixel_x = i * (32 / LIGHTING_RESOLUTION)
				O.pixel_y = j * (32 / LIGHTING_RESOLUTION)
				O.xoffset = (((2*i + 1) / (LIGHTING_RESOLUTION * 2)) - 0.5)
				O.yoffset = (((2*j + 1) / (LIGHTING_RESOLUTION * 2)) - 0.5)
				O.icon_state = state
				lighting_overlays |= O
				all_lighting_overlays |= O
		#endif

/turf/proc/get_lumcount(var/minlum = 0, var/maxlum = 1)
	#if LIGHTING_RESOLUTION == 1
	if(!lighting_overlay) //We're not dynamic, whatever, return 50% lighting.
	#else
	if(!lighting_overlays.len)
	#endif
		return 0.5

	var/totallums = 0
	#if LIGHTING_RESOLUTION == 1

	totallums = (lighting_overlay.lum_r + lighting_overlay.lum_b + lighting_overlay.lum_g) / 3

	#else

	if(!lighting_overlays.len) //Ya wot.
		return

	for(var/atom/movable/lighting_overlay/L in lighting_overlays)
		totallums += (L.lum_r + L.lum_g + L.lum_b) / 3

	totallums /= lighting_overlays.len //Get the average, used for higher resolutions of lighting.

	#endif

	totallums = (totallums - minlum) / (maxlum - minlum)

	return Clamp(totallums, 0, 1)

//Proc I made to dick around with update lumcount.
/turf/proc/update_lumcount(delta_r, delta_g, delta_b)
	#if LIGHTING_RESOLUTION == 1
	if(lighting_overlay)
		lighting_overlay.update_lumcount(delta_r, delta_g, delta_b)
	#else
	for(var/atom/movable/lighting_overlay/L in lighting_overlays)
		L.update_lumcount(delta_r, delta_g, delta_b)
	#endif

/turf/Entered(atom/movable/Obj, atom/OldLoc)
	. = ..()

	if(Obj && Obj.opacity)
		reconsider_lights()

/turf/Exited(atom/movable/Obj, atom/newloc)
	. = ..()

	if(Obj && Obj.opacity)
		reconsider_lights()

//Testing proc like update_lumcount.
/turf/proc/update_overlay()
	#if LIGHTING_RESOLUTION == 1
	lighting_overlay.update_overlay()
	#else
	for(var/atom/movable/lighting_overlay/L in lighting_overlays)
		L.update_overlay()
	#endif
