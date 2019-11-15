extends Spatial

const OPEN_SCALE = Vector3(1, 2, 0)
const CLOSED_SCALE = Vector3(1, 5, 0)

var is_open = false

onready var _main:MeshInstance = $Main
onready var _tween:Tween = $Tween


func _input(event):
    if event.is_action_released("test") and not is_open:
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