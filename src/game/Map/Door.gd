extends Spatial

class_name Door

const OPEN_TRANSLATION = Vector3(1, 2, 0)
const CLOSED_TRANSLATION = Vector3(1, 5, 0)

var is_open = false
var is_locked = false
var is_touching = false

var _right_ref
var _left_ref

var left setget _set_left, _get_left
var right setget _set_right, _get_right

onready var _main:MeshInstance = $Main
onready var _tween:Tween = $Tween

func _ready():
    add_to_group("doors")


func _input(event):
    if event.is_action_released("action") and is_touching:
        if is_open: close()
        else: open()


func open():
    is_open = true
    _tween_door()
    
    # Connect the rooms and trigger hazard combinations.
    self.left.connect_to(self.right)


func close():
    is_open = false
    _tween_door()

    # Connect the rooms and trigger hazard combinations.
    self.left.disconnect_from(self.right)


func _tween_door():
    var target_translation = CLOSED_TRANSLATION if is_open else OPEN_TRANSLATION
    _tween.interpolate_property(
        _main,
        "translation",
        _main.transform.origin,
        target_translation,
        0.3,
        Tween.TRANS_LINEAR,
        Tween.EASE_IN_OUT)
    
    _tween.start()


func _set_right(value):
    _right_ref = value


func _set_left(value):
    _left_ref = value
    

func _get_right():
    if _right_ref != null:
        return _right_ref
    else:
        # The door has not been connected to a room on its right side.
        # Instead, connect it to the hold (parent).
        _right_ref = self.left.hold
        return _right_ref


func _get_left():
    if _left_ref != null:
        return _left_ref
    else:
        # The door has not been connected to a room on its left side.
        # Instead, connect it to the hold (parent).
        _left_ref = self.right.hold
        return _left_ref
        

func _on_Area_body_entered(body):
    if body is KinematicBody:
        is_touching =  true


func _on_Area_body_exited(body):
    if body is KinematicBody:
        is_touching =  false
