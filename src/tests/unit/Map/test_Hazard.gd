extends "res://addons/gut/test.gd"

func test_get_combo_FIRE_BULKHEADS():
    var current = Hazard.new(Hazard.FIRE)
    var other = Hazard.new(Hazard.BULKHEADS)
    
    assert_eq(current.get_combo_effect(other), Hazard.COMBO_EFFECTS.NOTHING)
    
    assert_true(current.is_active, 'current should be active')
    assert_true(current.is_deadly, 'current should be deadly')
    
    assert_true(other.is_active, 'other should be active')
    assert_false(other.is_deadly, 'other should not be deadly')


func test_get_combo_FIRE_ELECTRICITY():
    var current = Hazard.new(Hazard.FIRE)
    var other = Hazard.new(Hazard.ELECTRICITY)
    
    assert_eq(current.get_combo_effect(other), Hazard.COMBO_EFFECTS.NOTHING)
    
    assert_true(current.is_active, 'current should be active')
    assert_true(current.is_deadly, 'current should be deadly')
    
    assert_true(other.is_active, 'other should be active')
    assert_true(other.is_deadly, 'other should be deadly')


func test_get_combo_FIRE_FIRE():
    var current = Hazard.new(Hazard.FIRE)
    var other = Hazard.new(Hazard.FIRE)
    
    assert_eq(current.get_combo_effect(other), Hazard.COMBO_EFFECTS.NOTHING)
    
    assert_true(current.is_active, 'current should be active')
    assert_true(current.is_deadly, 'current should be deadly')
    
    assert_true(other.is_active, 'other should be active')
    assert_true(other.is_deadly, 'other should be deadly')
    

func test_get_combo_FIRE_FLOODING():
    var current = Hazard.new(Hazard.FIRE)
    var other = Hazard.new(Hazard.FLOODING)
    
    assert_eq(current.get_combo_effect(other), Hazard.COMBO_EFFECTS.END)
    
    assert_false(current.is_active, 'current should not be active')
    assert_false(current.is_deadly, 'current should not be deadly')
    
    assert_true(other.is_active, 'other should be active')
    assert_false(other.is_deadly, 'other should not be deadly')