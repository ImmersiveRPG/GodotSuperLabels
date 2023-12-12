# Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is licensed under the MIT License
# https://github.com/ImmersiveRPG/GodotSuperLabels


extends Node

var _camera : Camera3D = null
var _labels := []
var _label_container = null

const MOUSE_SENSITIVITY := 0.1
const MOUSE_ACCELERATION_X := 10.0
const MOUSE_ACCELERATION_Y := 10.0
const MOUSE_Y_MAX := 70.0
const MOUSE_Y_MIN := -60.0

func xlerp_angle(from : float, to : float, weight : float, threshold : float) -> float:
	from = lerp_angle(from, to, weight)

	var diff := absf(absf(from) - absf(to))
	if rad_to_deg(diff) <= rad_to_deg(threshold):
		from = to

	return from

func inverse_rotate_to_face_on_y(thing : Node3D, target : Node3D, weight : float, threshold : float) -> bool:
	var direction : Vector3 = thing.global_transform.origin - target.global_transform.origin
	var rotation_target := atan2(-direction.x, -direction.z)
	thing.rotation.y = Global.xlerp_angle(thing.rotation.y, rotation_target, weight, threshold)

	return is_equal_approx(thing.rotation.y, rotation_target)
