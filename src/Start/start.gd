extends Node3D

@onready var _screen_box = $ScreenBox

func _ready() -> void:
	Global._camera = $Camera3D

func _physics_process(delta : float) -> void:
	if Input.is_action_pressed("right"):
		_screen_box.global_transform.origin.x += delta * 2.0
	if Input.is_action_pressed("left"):
		_screen_box.global_transform.origin.x -= delta * 2.0
	if Input.is_action_pressed("up"):
		_screen_box.global_transform.origin.z -= delta * 2.0
	if Input.is_action_pressed("down"):
		_screen_box.global_transform.origin.z += delta * 2.0
