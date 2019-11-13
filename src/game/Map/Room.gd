extends Object

class_name Room

var hazard:Hazard

func connect_room(other:Room):
    var combo_effect = hazard.get_combo_effect(other.hazard)
    if combo_effect == Hazard.COMBO_EFFECTS.DEADLY:
        pass # x.x