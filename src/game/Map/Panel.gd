extends Spatial

var is_disabled = true
var is_active = false setget , _get_is_active

var is_touching = false

# This panel controls a hazard from another room, which will
# be stored here as the `corresponding_room`. The path for this
# is set as an exported variable of a Room.
var corresponding_room:Room

onready var _mesh:MeshInstance = $MeshInstance


func connect_to(corresponding_room):
    if corresponding_room == null: return
    if not corresponding_room.hazard is Hazard: return

    self.corresponding_room = corresponding_room
    is_disabled = false


func _input(event):
    if event.is_action_released("action") and is_touching:
        if !self.is_active: activate()
        else: deactivate()


func activate():
    print('activate', is_disabled)
    if not is_disabled:
        corresponding_room.deactivate_hazard()
        _update_indicator()


func deactivate():
    if not is_disabled:
        corresponding_room.activate_hazard()
        _update_indicator()
        

func _update_indicator():
    var material = SpatialMaterial.new()
    material.albedo_color = Color.green if self.is_active else Color.white
    _mesh.set_surface_material(0, material)


func _get_is_active():
    if not is_disabled and corresponding_room.hazard is Hazard:
        return !corresponding_room.hazard.is_active
    else: return false


func _on_Area_body_entered(body):
    is_touching = true
    print('panel entered')


func _on_Area_body_exited(body):
    is_touching = false
    print('panel exited')
