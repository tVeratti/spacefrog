extends Object

class_name Hazard

enum TYPES {
    NONE,
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
    TYPES.FIRE,
    TYPES.ELECTRICITY,
    TYPES.VACUUM
]

# Secondary Hazards do not directly impact the life support systems.
# These hazards serve only to complicate the resolution of the primary hazards.
const SECONDARY = [
    TYPES.BULKHEADS,
    TYPES.GRAVITY,
    TYPES.FLOODING,
    TYPES.FREEZING,
    TYPES.KEY_CARD
]

enum COMBO_EFFECTS { NOTHING, END, DEADLY }

var type setget set_type
var is_active = true
var is_deadly = false
var is_draining = false


func _init(new_type, default_active = true):
    self.type = new_type
    self.is_active = default_active

    if self.type == null:
        is_active = false


# A combo effect is applied to the hazard and the player within the room.
func get_combo_effect(other):
    var effect
    match(type):
        TYPES.NONE: effect = _get_combo_NONE(other.type)
        TYPES.FIRE: effect = _get_combo_FIRE(other.type)
        TYPES.ELECTRICITY: effect = _get_combo_ELECTRICITY(other.type)
        TYPES.VACUUM: effect = COMBO_EFFECTS.DEADLY
        _: effect = COMBO_EFFECTS.NOTHING
    
    if effect == COMBO_EFFECTS.END:
        is_active = false
        is_deadly = false
    elif effect == COMBO_EFFECTS.DEADLY:
        # Set both combined hazards to deadly.
        is_deadly = true
        other.is_deadly = true
    
    return effect


func reset_effect():
    is_deadly = _get_base_effect(type)


func _get_combo_NONE(other):
    match(other):
        TYPES.VACUUM:
            return COMBO_EFFECTS.DEADLY
        _:
            return COMBO_EFFECTS.NOTHING
            

func _get_combo_FIRE(other):
    match(other):
        TYPES.FLOODING, TYPES.VACUUM:
            return COMBO_EFFECTS.END
        _:
            return COMBO_EFFECTS.NOTHING


func _get_combo_ELECTRICITY(other):
    match(other):
        TYPES.FLOODING:
            return COMBO_EFFECTS.DEADLY
        _:
            return COMBO_EFFECTS.NOTHING


func _get_combo_FLOODING(other):
    match(other):
        TYPES.ELECTRICITY:
            return COMBO_EFFECTS.DEADLY
        _:
            return COMBO_EFFECTS.NOTHING


func _get_base_effect(base_type):
     match(type):
        TYPES.FIRE, TYPES.ELECTRICITY, TYPES.VACUUM:
            return true
        _:
            return false


func set_type(new_type = TYPES.NONE):
    type = new_type
    is_deadly = _get_base_effect(new_type)
   