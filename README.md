# Fly

## Table of contents
- [Gamemode settings](#gamemode-settings)
- [Mapping guidelines](#mapping-guidelines)
- [Plugin guidelines](#plugin-guidelines)

## Gamemode settings
Tickrate: 100
```CPP
sv_accelerate 5
sv_airaccelerate 1000
sv_wateraccelerate 1000
sv_maxvelocity 3500
sv_jump_impulse 301.993377
sv_timebetweenducks 0

sv_staminamax 0
sv_staminajumpcost 0
sv_staminalandcost 0

sv_autobunnyhopping 1
sv_enablebunnyhopping 1
sv_clamp_unsafe_velocities 0

sv_minrate 786432
sv_mincmdrate 64
sv_minupdaterate 64

sv_friction 4
sv_backspeed 0.6
sv_stopspeed 75
sv_ladder_scale_speed 1
```

The values on `sv_friction, sv_backspeed, sv_accelerate & sv_stopspeed` are all taken from the default settings in Counter-Strike: Source.

## Mapping guidelines
- [General rules](#general-rules)
- [Map props](#map-props)
- [Basics of zoning](#basics-of-zoning)
- [Start zone](#start-zone)
- [End zone](#end-zone)
- [Checkpoints (optional)](#checkpoints-optional)
- [Bonus zones](#bonus-zones)
- [Map properties](#map-properties)
- [Naming convention](#naming-convention)
- [Zones TL;DR](#tldr)

#### General rules
- It is the mappers duty to reset any changed movement values on clients when they enter the start zone such as gravity or other speed modifiers.
- At least 1 CT & 1 T spawn placed inside the start zone preferably.
- Do not use func_door's to make blocks that teleport you back, this is an outdated technique.

#### Map props
- Refrain from using props that can be used to RNG player runs e.g. moving props (barrels, rotating things etc.) and opening doors.

#### Basics of zoning
- There can only be unique names in the property field `name`, having more than 1 entity with the same `name` will result in a  sanity check fail.
- It is the mappers job to mark/draw zones if they wish to do so!
- Do not place a booster inside your start zone, they need to be at least 72 units apart from each other!

#### Start zone
The map must have 1 `trigger_multiple` entity with the property `name` set to `mod_zone_start`.  
Having more than one entity with the property `name` set to `mod_zone_start` will result in a failed sanity check.  

#### End zone
The map must have 1 `trigger_multiple` entity with the property `name` set to `mod_zone_end`.  
Having more than one entity with the property `name` set to `mod_zone_end` will result in a failed sanity check.  

#### Checkpoints (optional)
Checkpoints work independently of all other zones which means that skipping checkpoints has no effect on the main run.  

Examples of entities
```CPP
// Example 1 (works!)
mod_zone_start
mod_zone_checkpoint_1
mod_zone_checkpoint_2
mod_zone_checkpoint_3
mod_zone_end

// Example 2 (does not work!)
mod_zone_start
mod_zone_checkpoint_1
mod_zone_checkpoint_3 // Error missing checkpoint 2
mod_zone_end

// Example 3 (does not work!)
mod_zone_start
mod_zone_checkpoint_2 // Error missing checkpoint 1
mod_zone_checkpoint_3
mod_zone_checkpoint_4
mod_zone_end
```

#### Bonus zones
Same logic applies to all bonus zones except you add `_bonus_X_` after `_zone_`  
The `X` defines which bonus the zone belongs to, if there is more than 1 bonus on the same map.  
```CPP
// Example of valid names where X represents a number
mod_zone_bonus_X_start
mod_zone_bonus_X_end
mod_zone_bonus_X_checkpoint_X
```

### Map properties
#### Giving your map a difficulty
- How to add custom key to map properties

You can find this in hammer `Topmenu -> Map -> Map properties...` (entity `worldspawn`)
![Step 1](http://i.imgur.com/biu9Ipf.png)  
![Step 2](http://i.imgur.com/9DTt3yR.png)  

- Map difficulty `mod_tier` -> `3` range from 1 to 6, where 1 is easy and 6 is hard.
- Map creator `mod_creator` -> `my name`
- Map creator's steamid64 `mod_creator_steamid64` -> `76561198244883534`

### Naming convention
- Map names should have the prefix `fly_`
- Refrain from adding suffix'es to map names e.g. `fly_mymap_v1, fly_mymap_v2, fly_mymap_fix, fly_mymap_<insert_name_of_commnuity_here>`
- Refrain from having numbers in map names e.g. `fly_mym4p`
- Do **not** use uppercase letters, spaces and special characters in map names e.g. `fly_mym$p, fly_MyMAp, fly_my map`

### TL;DR
#### trigger_multiple
- `mod_zone_start` - Must have 1, any maps with more than 1 or none will not be accepted
- `mod_zone_end` - Must have 1, any maps with more than 1 or none will not be accepted
- `mod_zone_checkpoint_X` - Optional, if you wish to implement checkpoints refer to [this section](#checkpoints-optional)
- `mod_zone_bonus_X_start` - Optional, if you wish to implement bonus zones refer to [this section](#bonus-zones)
- `mod_zone_bonus_X_end` - Optional, if you wish to implement bonus zones refer to [this section](#bonus-zones)
- `mod_zone_bonus_X_checkpoint_X` - Optional, if you wish to implement bonus zones refer to [this section](#bonus-zones)

If you wish to sanity check your map download ##this## tool then drag & drop the map onto it.

## Plugin guidelines
If you wish to make a timer for this gamemode please follow our standards.  
- Start zone `mod_zone_start`
  - The tick where `!(EntityFlags & FL_ONGROUND)` is when the timer starts, or if walk out of the zone while touching the ground.
    - A players timer should be stopped if the speed of the player is greater than 290 upon timer start. if this happens you probably did something wrong in the first place!
  - A player should not be able to run faster than 290 on ground inside a start zone.
  - If a player's timer is already started and he jumps back in the start zone **and** lands on the ground inside the start zone, he should be punished with a speed reset to 250.
- End zone `mod_zone_end`
  - The tick where a SDKHook `OnTouch` happens is the tick we use to measure the tick count from when he left the ground inside the start zone.
- Checkpoint start `mod_zone_checkpoint_X`
  - Reaching/initial touch on a checkpoint zone only marks what your main timer was at when reaching this area.
  - Please also read the [mapping guidelines on checkpoints](#checkpoints-optional), it will strengthen your knowledge and understanding of checkpoints.
- Bonus zones
  - They all work the same way "main" start/end/checkpoints do except they have a prefix of `mod_zone_bonus_X` where the X represents what bonus it is, so you can have multiple bonuses in 1 map.
  - Note `mod_zone_bonus_<bonus_level>_checkpoint_<checkpoint_number>`

- Ticks vs Time
  - How we calculate time used in a run is TBD
  
Other than that apply common sense to whatever you do :)
