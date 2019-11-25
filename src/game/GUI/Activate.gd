extends Control

onready var _label:Label = $Label
onready var _tween:Tween = $Tween
var _viewport:Viewport

func set_viewport(viewport):
    _viewport = viewport

func show_hint(node:Spatial, text:String):
    
    var position_2D = _viewport.get_camera().unproject_position(node.transform.origin)
    
    # Force label to invisible before beginning tween.
    modulate = Color(1,1,1, 0)
    rect_position = position_2D
    
    _label.text = text
    _tween.interpolate_property(
        self,
        "modulate", 
        Color(1, 1, 1, 0),
        Color(1, 1, 1, 1),
        0.3, 
        Tween.TRANS_LINEAR,
        Tween.EASE_IN)
    
    _tween.start()
        