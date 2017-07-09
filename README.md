# Fly

## Table of contents
- [Gamemode settings](#gamemode-settings)
- [Mapping guidelines](#mapping-guidelines)

## Gamemode settings
Tickrate: 64  
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

The values on `sv_friction, sv_backspeed & sv_stopspeed` are all taken from the default settings in Counter-Strike: Source.
## Mapping guidelines
- [Zones](#zones)
- [Start zone](#start-zone)
- [End zone](#end-zone)
- [Stages (optional)](#stages-(optional))
- [Checkpoints (optional)](#checkpoints-(optional))
- [TL;DR](#tl;dr)

### Zones
#### Basics of zoning
- There can only be unique names in the property field `name`, having more than 1 entity with the same `name` will result in sanity check fail.

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

### TL;DR
#### trigger_multiple
- mod_start_zone - Must have 1, any maps with more than 1 or none will not be accepted
- mod_end_zone - Must have 1, any maps with more than 1 or none will not be accepted
- mod_stage_start_X - Optional, if you wish to implement stages refer to [this section](#Stages-(optional))
- mod_stage_end_X - Optional, if you wish to implement stages refer to [this section](#Stages-(optional))
- mod_checkpoint_start_X - Optional, if you wish to implement checkpoints refer to [this section](#Checkpoints-(optional))
- mod_checkpoint_end_X - Optional, if you wish to implement checkpoints refer to [this section](#Checkpoints-(optional))

If you wish to sanity check your map download ##this## tool then drag & drop the map onto it.
