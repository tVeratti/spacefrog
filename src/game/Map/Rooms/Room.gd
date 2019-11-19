extends Spatial

class_name Room


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

var hazard:Hazard


func _ready():
    add_to_group("rooms")


func initialize():
    # External Connections
    left_room = get_node(left_room_path) if left_room_path != '' else hold
    right_room = get_node(right_room_path)  if right_room_path != '' else hold
    
    # Assign this room as the `right` side of the left door
    self.left_door.right = self
    
    # Assign this room as the `left` side of the right door
    self.right_door.left = self


func connect_to(other:Room):
    if hazard != null and other.hazard != null:
        var combo_effect = hazard.get_combo_effect(other.hazard)
        if combo_effect == Hazard.COMBO_EFFECTS.DEADLY:
            print('u ded')


func disconnect_from(other:Room):
    if hazard != null and other.hazard != null:
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

    
    