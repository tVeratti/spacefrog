extends Object

var left:Room
var right:Room
var is_open:Boolean = false


func _init(left_room:Room, right_room:Room):
    self.left = left_room
    self.right = right_room


func open():
    is_open = true

    # Connect the rooms and trigger hazard combinations.
    left.connect_to(right)