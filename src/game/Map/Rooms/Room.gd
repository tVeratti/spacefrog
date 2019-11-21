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

export(NodePath) var panel_path
onready var _panel = $Panel

onready var _area:Area = $Area
onready var _light:OmniLight = $OmniLight

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
    
    _light.light_color = colors[hazard.type]
    

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


func open_to(other):
    if hazard is Hazard and other != null and other.hazard is Hazard:
        var combo_effect = hazard.get_combo_effect(other.hazard)
        
        if not hazard.is_active: deactivate_hazard()
        if not other.hazard.is_active: other.deactivate_hazard()
        
        if combo_effect == Hazard.COMBO_EFFECTS.DEADLY and is_within or other.is_within:
            print('u ded')


func close_to(other):
    if hazard is Hazard and other.hazard is Hazard:
        hazard.reset_effect()
        other.hazard.reset_effect()


func deactivate_hazard():
    if hazard is Hazard:
        hazard.deactivate()
        
        if self.left_door.is_open:
            close_to(self.left_room)
        
        if self.right_door.is_open:
            close_to(self.right_room)
        
        _light.omni_range = 0


func activate_hazard():
    if hazard is Hazard:
        hazard.activate()
        
        if self.left_door.is_open:
            open_to(self.left_room)
        
        if self.right_door.is_open:
            open_to(self.right_room)
            
        _light.omni_range = 20


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
    is_within = true
    if hazard.is_active and hazard.is_deadly:
        print('U DED')


func _on_Area_body_exited(body):
    is_within = false
