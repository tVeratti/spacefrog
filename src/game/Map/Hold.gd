extends Spatial

func _ready():
    var rooms = get_tree().get_nodes_in_group("rooms")
    
    for room in rooms:
        # Connect all rooms now that they have all been mounted.
        room.initialize()


func connect_to(room):
    pass


func disconnect_from(room):
    pass