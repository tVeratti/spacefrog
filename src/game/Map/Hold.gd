extends Spatial

var hazard = Hazard.new(Hazard.TYPES.NONE)

func _ready():
    var rooms = get_tree().get_nodes_in_group("rooms")
    var doors = get_tree().get_nodes_in_group("doors")
    
    for room in rooms:
        # Connect all rooms now that they have all been mounted.
        room.initialize()

    for door in doors:
        if door.right == null:
            door.right = self
        if door.left == null:
            door.left = self

func connect_to(room):
    pass


func disconnect_from(room):
    pass