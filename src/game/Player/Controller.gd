extends KinematicBody

const ACCELERATION = 10
const ACCELERATION_AIR = 0.2
const GRAVITY = 100

const FRICTION = 0.2
const FRICTION_AIR = 0.05

const SPEED_NORMAL = 30
const SPEED_SPRINT = 60
const SPEED_CLIMB = 10

const MAX_JUMP_FORCE = 70
const JUMP_CHARGE_RATE = 4
const JUMP_CHARGE_DEADZONE = JUMP_CHARGE_RATE * 10
const JUMP_VELOCITY_ACCELERATION = 0.2

const JUMP_VELOCITY_MAXIMUM = 10
const JUMP_VELOCITY_MINIMUM = 3

enum STATES { WAIT, CROUCH, WALK, SPRINT, JUMP, CLIMB }
var _state = STATES.WAIT

var _velocity = Vector3.ZERO
var _jump_velocity = Vector3.ZERO
var _jump_force = 0
var _jump_direction = 1

var _gravity_direction = Vector3.DOWN
var _is_climbing = false
var _prev_grav = _gravity_direction

onready var _jump_preview:ImmediateGeometry = $JumpPreview
onready var _mesh:MeshInstance = $MeshInstance
onready var _collision:CollisionShape = $CollisionShape
onready var _ray:RayCast = $RayCast


# Called when the node enters the scene tree for the first time.
func _ready():
    set_state(STATES.WAIT)
    reset_jump_velocity()


func _physics_process(delta):
    var on_floor = is_on_floor()
    var on_wall = is_on_wall()
    
    var is_moving_right = Input.is_action_pressed("right")
    var is_moving_left = Input.is_action_pressed("left")
    var is_sprinting = Input.is_action_pressed("sprint")
    
    var is_charging_jump = Input.is_action_pressed("jump")
    var is_jumping = Input.is_action_just_released("jump")

    var direction = 1 if is_moving_right else -1 if is_moving_left else 0
    if direction != 0: _jump_direction = direction
        
    if on_floor:
        if is_jumping: jump(direction)
        elif is_charging_jump: charge_jump(direction, on_wall)                
        else: move(direction, is_sprinting)
        
        if is_moving_right: _mesh.rotation_degrees = Vector3(0, -90, 0)
        elif is_moving_left: _mesh.rotation_degrees = Vector3(0, 90, 0)
    
    elif on_wall:
        climb(direction, is_charging_jump)

    else:
        _is_climbing = false
        _gravity_direction = Vector3.DOWN
        if is_moving_right:
            _velocity.x += ACCELERATION_AIR
        elif is_moving_left:
            _velocity.x -= ACCELERATION_AIR
        else:
            _velocity.x = lerp(_velocity.x, 0, FRICTION_AIR)
    
    _velocity += _gravity_direction * GRAVITY * delta
    _ray.cast_to = _velocity.normalized() * 4
    
    _velocity = move_and_slide(Vector3(_velocity.x, _velocity.y, 0), Vector3.UP)


func charge_jump(direction, on_wall):
    # Update jump force (cumulative)
    # The jump forve will be applied to the jump velocity.
    _jump_force = min(_jump_force + JUMP_CHARGE_RATE, MAX_JUMP_FORCE)
    
    if _jump_force > JUMP_CHARGE_DEADZONE:
        if direction != 0:
            # Increase horizontal velocity
            _jump_velocity.x += 0.1 * _jump_direction
    
        _jump_velocity.x = min(_jump_velocity.x, JUMP_VELOCITY_MAXIMUM)
        _jump_velocity.x = max(_jump_velocity.x, -JUMP_VELOCITY_MAXIMUM)

        # Slow down and crouch...
        _velocity.x = lerp(_velocity.x, 0, FRICTION)
        if abs(_velocity.x) < 200 and not on_wall:
            set_state(STATES.CROUCH)
    
    _jump_preview.clear()
    _jump_preview.begin(Mesh.PRIMITIVE_LINES)
    _jump_preview.add_vertex(Vector3.ZERO)
    _jump_preview.add_vertex(Vector3(
            _jump_velocity.x,
            _jump_velocity.y,
            0).normalized() * (_jump_force / 10))
    _jump_preview.end()


func jump(direction):
    set_state(STATES.JUMP)

    # Get the clamped jump force with x velocity to boost it.
    var launch_force = max(_jump_force, JUMP_CHARGE_DEADZONE)
    var launch_velocity = _jump_velocity
    
    # Make sure the y velocity is always upward.
    launch_velocity.y = abs(launch_velocity.y)
    
    # Normalize the velocity to blend the directions and avoid
    # abuse of additive diagonal velocity.
    launch_velocity = launch_velocity.normalized()
    
    # Multiply the normalized velocity to get the distance of
    # the charged jump force.
    launch_velocity *= launch_force
    
    # Add in current x velocity to get momentum bonus.
    launch_velocity.x += _velocity.x
     
    _velocity = launch_velocity
    
    # Reset jump forces
    reset_jump_velocity()


func reset_jump_velocity():
    _jump_preview.clear()
    _jump_force = 0
    _jump_velocity = Vector3(0, 1, 0)


func move(direction, is_sprinting):
    set_state(STATES.SPRINT if is_sprinting else STATES.WALK)

    if direction != 0:
        _velocity.x += direction * ACCELERATION
    else:
        _velocity.x = lerp(_velocity.x, 0, FRICTION)
    
    # Clamp _velocity values
    var max_speed = SPEED_SPRINT if is_sprinting else SPEED_NORMAL
    _velocity.x = min(_velocity.x, max_speed)
    _velocity.x = max(_velocity.x, -max_speed)


func climb(direction, is_charging_jump):
    set_state(STATES.CLIMB)
  
    # Check if the player has collided with a surface.
    # Use the opposite of that surface's normal as the new gravity.
    var collision = test_move(transform, _velocity)
    if collision:
        if not _is_climbing:
            _velocity = Vector3.ZERO
            _is_climbing = true
            _gravity_direction = -_ray.get_collision_normal()
    
    # Add a small amount of acceleration when climbing in either direction.
    if direction == 1:
        _velocity.y += SPEED_CLIMB * _gravity_direction.x
    elif direction == -1:
        _velocity.y -= SPEED_CLIMB * _gravity_direction.x
    else:
        _velocity.y = lerp(_velocity.y, 0, 0.15)

#    var rotation = 90 if _velocity.y > 0 else -90
#    rotation_degrees = Vector3(0, 0, rotation)
    # Clamp climbing velocity within maximum speed range
    _velocity.y = min(_velocity.y, SPEED_CLIMB)
    _velocity.y = max(_velocity.y, -SPEED_CLIMB)
    

func set_state(new_state):
    if new_state == _state: return 
    _state = new_state
