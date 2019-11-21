extends Spatial

var hazard = Hazard.new(Hazard.TYPES.NONE)
var is_within = true

func _ready():
    var rooms = get_tree().get_nodes_in_group("rooms")
    var doors = get_tree().get_nodes_in_group("doors")
    
    # Connect all rooms & doors now that they have all been mounted.
    for room in rooms:
        room.connect_nodes()


    for door in doors:
        if door.right == null:
            door.right = self
        if door.left == null:
            door.left = self


func open_to(room):
    pass


func close_to(room):
    pass