extends Spatial

const OPEN_SCALE = Vector3(1, 2, 0)
const CLOSED_SCALE = Vector3(1, 5, 0)

var is_open = false
var is_touching = false

onready var _main:MeshInstance = $Main
onready var _tween:Tween = $Tween


func _input(event):
    if event.is_action_released("test") and not is_open and is_touching:
        open()


func open():
    is_open = true

    _tween.interpolate_property(
        _main,
        "translation",
        OPEN_SCALE,
        CLOSED_SCALE,
        0.3,
        Tween.TRANS_LINEAR,
        Tween.EASE_IN_OUT)
    
    _tween.start()
    
    # Connect the rooms and trigger hazard combinations.
    #left.connect_to(right)

func _on_Area_body_entered(body):
    if body is KinematicBody:
        is_touching =  true


func _on_Area_body_exited(body):
    if body is KinematicBody:
        is_touching =  false
