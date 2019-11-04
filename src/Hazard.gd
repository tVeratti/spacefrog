extends Object

class_name Hazard

enum {
    FIRE,
    ELECTRICITY,
    VACUUM,
    BULKHEADS,
    GRAVITY,
    FLOODING,
    FREEZING,
    KEY_CARD
}

# Primary Hazards impact the overall life support sustainability.
# The longer these hazards are active, the more the life support is drained.
const PRIMARY = [
    FIRE,
    ELECTRICITY,
    VACUUM
]

# Secondary Hazards do not directly impact the life support systems.
# These hazards serve only to complicate the resolution of the primary hazards.
const SECONDARY = [
    BULKHEADS,
    GRAVITY,
    FLOODING,
    FREEZING,
    KEY_CARD
]

enum COMBO_EFFECTS { NOTHING, END, DEADLY }

var type
var _is_active = false
var _is_deadly = false
var _is_draining = false


# A combo effect is applied to the hazard and the player within the room.
func get_combo_effect(other):
    var effect
    match(type):
        FIRE: effect = get_combo_FIRE(other.type)
        ELECTRICITY: effect = get_combo_ELECTRICITY(other.type)
        _: effect = COMBO_EFFECTS.NOTHING
    
    if effect == COMBO_EFFECTS.END:
        _is_active = false
    elif effect == COMBO_EFFECTS.DEADLY:
        # Set both combined hazards to deadly.
        set_deadly(true)
        other.set_deadly(true)
    
    return effect


func get_combo_FIRE(other):
    match(other):
        FLOODING, VACUUM:
            return COMBO_EFFECTS.END
        _:
            return COMBO_EFFECTS.NOTHING


func get_combo_ELECTRICITY(other):
    match(other):
        FLOODING:
            return COMBO_EFFECTS.DEADLY
        _:
            return COMBO_EFFECTS.NOTHING


func get_combo_FLOODING(other):
    match(other):
        ELECTRICITY:
            return COMBO_EFFECTS.DEADLY
        _:
            return COMBO_EFFECTS.NOTHING


func set_deadly(is_deadly):
    _is_deadly = is_deadly