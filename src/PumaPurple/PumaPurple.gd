# Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is licensed under the MIT License
# https://github.com/ImmersiveRPG/GodotSuperLabels

extends Node3D

enum Mood {
	Idle,
	Spin,
	Move,
}

const SPEED := 40.0
const ROTATION_SPEED := 6.0

var _mood := Mood.Idle
var _destination : Node3D = null
var _dest_angle := Vector3.ZERO

func _physics_process(delta : float) -> void:
	match _mood:
		Mood.Idle:
			pass
		Mood.Spin:
			self.rotation.y += delta * ROTATION_SPEED
		Mood.Move:
			self.global_transform.origin = self.global_transform.origin.move_toward(_destination.global_transform.origin, SPEED * delta)
			Global.inverse_rotate_to_face_on_y(self, _destination,  ROTATION_SPEED * delta, deg_to_rad(2.0))

func _on_timer_change_mood_timeout() -> void:
	_mood = Mood.values().pick_random()

	if _mood == Mood.Move:
		var positions = $"../Positions".get_children()
		_destination = positions.pick_random()
