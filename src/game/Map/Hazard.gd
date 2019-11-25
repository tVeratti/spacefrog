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

var _is_active
var is_active = true setget _set_active, _get_active

var is_ended = false
var is_deadly = false
var is_draining = false
var can_spread = false

func _init(new_type, default_active = true):
    self.type = new_type
    self.is_active = default_active

    if self.type == null:
        self.is_active = false


func deactivate():
    self.is_active = false


func activate():
    self.is_active = true


# Combo effect is what the current hazard has applied to it.
# This is seperate from if the hazard is deadly on its own.
func get_combo_effect(other):
    var effect
    
    if other.is_active:
        match(type):
            TYPES.FIRE: effect = _get_combo_FIRE(other)
            TYPES.ELECTRICITY: effect = _get_combo_ELECTRICITY(other)
            TYPES.FLOODING: effect = _get_combo_FLOODING(other)
            _: effect = COMBO_EFFECTS.NOTHING
    
    return effect


func _get_combo_NONE(other):
    match(other.type):
        TYPES.VACUUM:
            return COMBO_EFFECTS.DEADLY
        _:
            return COMBO_EFFECTS.NOTHING
            

func _get_combo_FIRE(other):
    match(other.type):
        TYPES.FLOODING:
            return COMBO_EFFECTS.END
        TYPES.VACUUM:
            # The fire ends, but both rooms are deadly
            # due to the VACUUM being combined.
            self.is_active = false
            return COMBO_EFFECTS.DEADLY
        _:
            return COMBO_EFFECTS.NOTHING


func _get_combo_ELECTRICITY(other):
    match(other.type):
        TYPES.FLOODING:
            return COMBO_EFFECTS.DEADLY
        _:
            return COMBO_EFFECTS.NOTHING


func _get_combo_FLOODING(other):
    match(other.type):
        TYPES.ELECTRICITY:
            return COMBO_EFFECTS.DEADLY
        _:
            return COMBO_EFFECTS.NOTHING


func _get_base_deadly(base_type):
     match(base_type):
        TYPES.FIRE, TYPES.ELECTRICITY, TYPES.VACUUM:
            return true
        _:
            return false


func set_type(new_type = TYPES.NONE):
    type = new_type
    is_deadly = _get_base_deadly(new_type)


func _get_active():
    return _is_active


func _set_active(value):
    _is_active = value
   