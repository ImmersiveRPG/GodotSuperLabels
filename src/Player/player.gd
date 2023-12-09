extends CharacterBody3D


const SPEED = 20.0
const JUMP_VELOCITY = 4.5
var _camera_x := 0.0
var _camera_y := 0.0
var _camera_x_new := 0.0
var _camera_y_new := 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Global._camera = $CameraMount/v/Camera3D

func _input(event : InputEvent) -> void:
	# Rotate camera with mouse
	if event is InputEventMouseMotion:
		_camera_x -= event.relative.x * Global.MOUSE_SENSITIVITY
		_camera_y = clampf(_camera_y - event.relative.y * Global.MOUSE_SENSITIVITY, Global.MOUSE_Y_MIN, Global.MOUSE_Y_MAX)

func _process(delta : float) -> void:
	# Get new camera angles
	_camera_x_new = lerp(_camera_x_new, _camera_x, delta * Global.MOUSE_ACCELERATION_X)
	_camera_y_new = lerp(_camera_y_new, _camera_y, delta * Global.MOUSE_ACCELERATION_Y)
	self.rotation_degrees.y = _camera_x_new

	# Set camera rotation
	$CameraMount/v.rotation_degrees.x = lerp($CameraMount/v.rotation_degrees.x, _camera_y, delta * Global.MOUSE_ACCELERATION_X)

func _physics_process(delta : float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	self.move_and_slide()


func _on_timer_start_timeout() -> void:
	while not Global._labels.is_empty():
		var label = Global._labels.pop_back()
		label.global_transform.origin = $Area3D.global_transform.origin
		label.get_node("TimerUpdateLine").start()
