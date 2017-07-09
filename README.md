# Fly

## Table of contents
- [Gamemode settings](#gamemode-settings)
- [Mapping guidelines](#mapping-guidelines)
- [Plugin guidelines](#plugin-guidelines)

## Gamemode settings
Tickrate: TBD  
```CPP
sv_accelerate 5
sv_airaccelerate 1000
sv_wateraccelerate 1000
sv_maxvelocity 3500

sv_staminamax 0
sv_staminajumpcost 0
sv_staminalandcost 0

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
- [Zones](#zones)
- [Start zone](#start-zone)
- [End zone](#end-zone)
- [Stages (optional)](#stages-optional)
- [Checkpoints (optional)](#checkpoints-optional)
- [Map properties](#map-properties)
- [Naming convention](#naming-convention)
- [Zones TL;DR](#tldr)

### Zones
#### Basics of zoning
- There can only be unique names in the property field `name`, having more than 1 entity with the same `name` will result in sanity check fail.
- It is the mappers job to mark/draw zones if they wish to do so!
- Do not place a booster inside your start zone, they need to be atleast 72 units apart from eachother!

#### Start zone
The map must have 1 `trigger_multiple` entity with the property `name` set to `mod_start_zone`.  
Having more than entity with the property `name` set to `mod_start_zone` will result in a failed sanity check.  

#### End zone
The map must have 1 `trigger_multiple` entity with the property `name` set to `mod_end_zone`.  
Having more than entity with the property `name` set to `mod_end_zone` will result in a failed sanity check.  

#### Stages (optional)
To start of `mod_start_zone` acts as a `mod_stage_start_1` and `mod_end_zone` acts as a `mod_stage_end_<last_stage>` if ``.  

Examples of entities
```CPP
// Example 1 (works!)
mod_start_zone // this zone will act as a mod_stage_start_1 aswell.
mod_stage_end_1
mod_stage_start_2
mod_stage_end_2
mod_stage_start_3
mod_end_zone // this zone will act as a mod_stage_end_3 aswell.

// Example 2 (does not work!)
mod_start_zone
mod_stage_start_1 // Error mod_stage_start_1 is already implemented in mod_start_zone
mod_stage_end_1
mod_stage_start_2
mod_stage_end_2
mod_stage_start_3
mod_stage_end_3
mod_end_zone // Error missing mod_stage_start_4 but previous was mod_stage_end_3

// Example 3 (does not work!)
mod_start_zone // this zone will act as a mod_stage_start_1 aswell.
mod_stage_end_1
mod_end_zone // Error missing mod_stage_start_2 but previous was mod_stage_end_1
```

##### Side effects
- Players cannot finish a stage without finishing the previous stage e.g. finishing stage 1 then 3 then 2 is not possible.

#### Checkpoints (optional)
Checkpoints work independently of all other zones which means that skipping checkpoints has no effect on the stages or main run.  

With checkpoints you have to set both start and end zone all the time.

Examples of entities
```CPP
// Example 1 (works!)
mod_start_zone
mod_checkpoint_start_1
mod_checkpoint_end_1
mod_checkpoint_start_2
mod_checkpoint_end_2
mod_end_zone

// Example 2 (does not work!)
mod_start_zone
mod_checkpoint_end_1 // Error expected to have mod_checkpoint_start_1
mod_checkpoint_start_2
mod_end_zone // Error expected to have mod_checkpoint_end_2

// Example 3 (works!)
mod_start_zone
mod_stage_end_1
mod_checkpoint_start_1
mod_checkpoint_end_1
mod_checkpoint_start_2
mod_checkpoint_end_2
mod_stage_start_2
mod_checkpoint_start_3
mod_checkpoint_end_3
mod_checkpoint_start_4
mod_checkpoint_end_4
mod_end_zone
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
- Do **not** use uppercase letters, numbers, spaces and special characters in map names e.g. `fly_mym4p, fly_mym$p, fly_MyMAp, fly_my map`

### TL;DR
#### trigger_multiple
- mod_start_zone - Must have 1, any maps with more than 1 or none will not be accepted
- mod_end_zone - Must have 1, any maps with more than 1 or none will not be accepted
- mod_stage_start_X - Optional, if you wish to implement stages refer to [this section](#stages-optional)
- mod_stage_end_X - Optional, if you wish to implement stages refer to [this section](#stages-optional)
- mod_checkpoint_start_X - Optional, if you wish to implement checkpoints refer to [this section](#checkpoints-optional)
- mod_checkpoint_end_X - Optional, if you wish to implement checkpoints refer to [this section](#checkpoints-optional)

If you wish to sanity check your map download ##this## tool then drag & drop the map onto it.

## Plugin guidelines
If you wish to make a timer for this game mode please follow our standards.  
- Start zone `mod_start_zone`
  - The tick where `!(EntityFlags & FL_ONGROUND)` is when the timer starts.
    - A players timer should be stopped if the speed of the player is greater than 290 upon timer start. if this happens you probably did something wrong in the first place!
  - A player should not be able to run faster than 290 on ground inside a start zone.
  - If a player's timer is already started and he jumps back in the start zone **and** lands on the ground inside the start zone, he should be punished with a speed reset to 250.
- End zone `mod_end_zone`
  - The tick where a SDKHook `OnTouch` happens is the tick we use to measure the tick count from when he left the ground inside the start zone.
- Stages start `mod_stage_start_X`
  - Use the same logic as you used for start zones, except the speed punishments.
  - It should not be possible to start a new stage without finishing the previous.
  - Please also read the [mapping guidelines on stages](#stages-optional), it will strengthen your knowledge and understanding of stages.
- Stages end `mod_start_end_X`
  - Use the same logic as you used for end zones.
- Checkpoint start `mod_checkpoint_start_X`
  - Use the same logic as you used for start zones, except the speed punishments.
  - Please also read the [mapping guidelines on checkpoints](#checkpoints-optional), it will strengthen your knowledge and understanding of checkpoints.
- Ticks vs Time
  - Use ticks instead of time e.g. `ticks * tick_interval` to get a precise time.
  
Other than that apply common sense to whatever you do :)
