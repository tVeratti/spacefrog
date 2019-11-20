extends Spatial

class_name Room

var Text = load("res://game/Utility/Text.tscn")

# External Connections (Siblings)
export(NodePath) var left_room_path
export(NodePath) var right_room_path
var left_room:Room
var right_room:Room

onready var hold = get_parent()

# Internal Connections (Children)
export(NodePath) var left_door_path
export(NodePath) var right_door_path

var _left_door_ref
var _right_door_ref
var left_door setget , _get_left_door
var right_door setget , _get_right_door

# Room Hazard
var hazard:Hazard
export(Hazard.TYPES) var hazard_type

onready var _area:Area = $Area

func _ready():
    add_to_group("rooms")
    
    hazard = Hazard.new(hazard_type)
    
#    NONE,
#    FIRE,
#    ELECTRICITY,
#    VACUUM,
#    BULKHEADS,
#    GRAVITY,
#    FLOODING,
#    FREEZING,
#    KEY_CARD
    
    var colors = [
        Color.white,
        Color.red,
        Color.yellow,
        Color.purple,
        Color.brown,
        Color.cyan,
        Color.aliceblue,
        Color.blueviolet
    ]
    
    $OmniLight.light_color = colors[hazard.type]
    

func initialize():
    # External Connections
    left_room = get_node(left_room_path) if left_room_path != '' else hold
    right_room = get_node(right_room_path)  if right_room_path != '' else hold
    
    # Assign this room as the `right` side of the left door
    self.left_door.right = self
    
    # Assign this room as the `left` side of the right door
    self.right_door.left = self


func connect_to(other):
    if hazard is Hazard and other != null and other.hazard is Hazard:
        var combo_effect = hazard.get_combo_effect(other.hazard)
        if combo_effect == Hazard.COMBO_EFFECTS.DEADLY:
            print('u ded')


func disconnect_from(other):
    if hazard is Hazard and other.hazard is Hazard:
        hazard.reset_effect()
        other.hazard.reset_effect()


func _get_left_door():
    if _left_door_ref != null:
        return _left_door_ref
    else:
        if left_door_path != '':
            _left_door_ref = get_node(left_door_path)
        else:
            _left_door_ref = self.left_room.right_door
        return _left_door_ref


func _get_right_door():
    if _right_door_ref != null:
        return _right_door_ref
    else:
        if right_door_path != '':
            _right_door_ref = get_node(right_door_path)
        else:
            _right_door_ref = self.right_room.right_door
        return _right_door_ref


func _on_Area_body_entered(body):
    if hazard.is_active and hazard.is_deadly:
        print('U DED')
