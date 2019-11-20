extends Spatial

onready var _label = $Viewport/GUI/Label


func set_text(value):
    _label.text = value
    
