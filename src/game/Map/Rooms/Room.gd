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

var is_within = false

# Room Hazard
var hazard:Hazard
export(Hazard.TYPES) var hazard_type
var is_deadly setget , _get_is_deadly

export(NodePath) var panel_path
onready var _panel = $Panel

onready var _area:Area = $Area
onready var _light:MeshInstance = $TypeIndicator
onready var _focus:Spatial = $FocusTarget
var camera:Camera

func _ready():
    add_to_group("rooms")
    
    hazard = Hazard.new(hazard_type)
    
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
    
    var material = SpatialMaterial.new()
    material.albedo_color = colors[hazard.type]
    _light.set_surface_material(0, material)
    

func connect_nodes():
    # External Connections
    left_room = get_node(left_room_path) if left_room_path != '' else hold
    right_room = get_node(right_room_path)  if right_room_path != '' else hold
    
    # Assign this room as the `right` side of the left door
    self.left_door.right = self
    
    # Assign this room as the `left` side of the right door
    self.right_door.left = self

    # Attach the panel to the corresponding room/hazard
    if _panel != null and panel_path != '':
        var corresponding_panel_room = get_node(panel_path)
        _panel.connect_to(corresponding_panel_room)
    elif _panel != null:
        _panel.queue_free()


func open_to(other):
    var self_effect = hazard.get_combo_effect(other.hazard)
    var other_effect = other.hazard.get_combo_effect(hazard)
    
    if self_effect == Hazard.COMBO_EFFECTS.END:
        deactivate_hazard()
    
    if other_effect == Hazard.COMBO_EFFECTS.END:
        other.deactivate_hazard()
    
    if self_effect == Hazard.COMBO_EFFECTS.DEADLY or \
       other_effect == Hazard.COMBO_EFFECTS.DEADLY:
        print('u ded')


func deactivate_hazard():
    if hazard is Hazard:
        hazard.deactivate()
        camera.start_cinematic_target(_focus)
        _light.visible = false


func activate_hazard():
    if hazard is Hazard:
        hazard.activate()
        camera.start_cinematic_target(_focus)
        _light.visible = true


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
            

func _get_is_deadly():
    if hazard.is_deadly and hazard.is_active:
        return true
    
    if self.left_door.is_open:
        var left_room = self.left_door.left
        var left_effect = hazard.get_combo_effect(left_room.hazard)
        if left_effect == Hazard.COMBO_EFFECTS.DEADLY:
            return true
    
    if self.right_door.is_open:
        var right_room = self.right_door.right
        var right_effect = hazard.get_combo_effect(right_room.hazard)
        if right_effect == Hazard.COMBO_EFFECTS.DEADLY:
                return true
    
    return false


func _on_Area_body_entered(body):
    is_within = true
    if self.is_deadly:
        print('U DED')


func _on_Area_body_exited(body):
    is_within = false
