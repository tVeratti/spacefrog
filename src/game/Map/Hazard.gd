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

func _init(new_type, default_active = true):
    self.type = new_type
    self.is_active = default_active

    if self.type == null:
        self.is_active = false


func deactivate():
    self.is_active = false


func activate():
    self.is_active = true


# Combo effects change when two hazards combine. These are only active
# while the rooms are open to each other.
func get_combo_effect(other):
    var effect
    
    if other.is_active:
        match(type):
            TYPES.NONE: effect = _get_combo_NONE(other)
            TYPES.FIRE: effect = _get_combo_FIRE(other)
            TYPES.ELECTRICITY: effect = _get_combo_ELECTRICITY(other)
            TYPES.VACUUM: effect = COMBO_EFFECTS.DEADLY
            _: effect = COMBO_EFFECTS.NOTHING
    elif type == TYPES.VACUUM and self.is_active:
        effect = COMBO_EFFECTS.DEADLY
    

    if effect == COMBO_EFFECTS.DEADLY:
        # Set both combined hazards to deadly.
        is_deadly = true
        other.is_deadly = true
    
    return effect


func reset_effect():
    is_deadly = _get_base_effect(type)


func _get_combo_NONE(other):
    match(other.type):
        TYPES.VACUUM:
            return COMBO_EFFECTS.DEADLY
        _:
            return COMBO_EFFECTS.NOTHING
            

func _get_combo_FIRE(other):
    match(other.type):
        TYPES.FLOODING:
            self.is_ended = true
            return COMBO_EFFECTS.NOTHING
        TYPES.VACUUM:
            # The fire ends, but both rooms are deadly
            # due to the VACUUM being combined.
            self.is_ended = true
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


func _get_base_effect(base_type):
     match(type):
        TYPES.FIRE, TYPES.ELECTRICITY, TYPES.VACUUM:
            return true
        _:
            return false


func set_type(new_type = TYPES.NONE):
    type = new_type
    is_deadly = _get_base_effect(new_type)


func _get_active():
    return _is_active and not is_ended


func _set_active(value):
    _is_active = value
   