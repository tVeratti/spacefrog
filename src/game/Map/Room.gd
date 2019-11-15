extends Node

class_name Room

var hazard:Hazard

export(NodePath) var left_door_path
export(NodePath) var right_door_path

var left_door:Door
var right_door:Door


func _ready():
    left_door = get_node(left_door_path)
    right_door = get_node(right_door_path)


func connect_to(other:Room):
    if hazard != null and other.hazard != null:
        var combo_effect = hazard.get_combo_effect(other.hazard)
        if combo_effect == Hazard.COMBO_EFFECTS.DEADLY:
            pass # x.x