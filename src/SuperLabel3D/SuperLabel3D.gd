# Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is licensed under the MIT License
# https://github.com/ImmersiveRPG/GodotSuperLabels

@tool
extends RigidBody3D

var _is_setup := false
var _outline_color := Color.BLACK
var _font_color := Color.WHITE
var _line_color := Color.WHITE
@export var _visibility_distance : float = 20.0
var _text : String = ""
@onready var _line : Line2D = $Line2D

@export var _attached_to_node_path : NodePath
var _attached_to : Node3D

@export var line_color : Color = _line_color:
	get:
		if _is_setup:
			_line_color = $Line2D.default_color
		return _line_color
	set(value):
		_line_color = value
		if _is_setup:
			$Line2D.default_color = _line_color

@export_multiline var text: String = _text:
	get:
		if _is_setup:
			_text = $Label3D.text
		return _text
	set(value):
		_text = value
		if _is_setup:
			$Label3D.text = _text

func _ready() -> void:
	_is_setup = true

	self.text = _text
	self.line_color = _line_color
	$Label3D.outline_modulate = _outline_color
	$Label3D.modulate = _line_color
	_attached_to = self.get_node(_attached_to_node_path)

	if not Engine.is_editor_hint():
		Global._labels.append(self)

func _physics_process(delta : float) -> void:
	self.linear_velocity = self.linear_velocity.lerp(Vector3.ZERO, delta)

func set_color(outline_color : Color, font_color : Color) -> void:
	_outline_color = outline_color
	_font_color = font_color

func set_text(value : String) -> void:
	self.text = value
	$Label3D.outline_modulate = _outline_color
	$Label3D.modulate = _font_color


func _on_timer_update_line_timeout() -> void:
	if not _is_setup: return

	_line.points.clear()
	var src := self.global_transform.origin
	var dest : Vector3 = _attached_to.global_transform.origin
	var distance := src.distance_to(dest)
	#print([self, _attached_to])
	#self.get_viewport().get_camera_3d()

	var is_in_range := distance <= _visibility_distance
	var is_in_frustum := Global._camera.is_position_in_frustum(dest)
	var is_visible := is_in_range and is_in_frustum

	var points := PackedVector2Array()
	if is_visible:
		self.visible = true
		var src_2d := Global._camera.unproject_position(src)
		var dest_2d := Global._camera.unproject_position(dest)
		points.append(src_2d)
		points.append(dest_2d)
		#print([Global._line.global_position, Global._line.points])
	else:
		self.visible = false

	_line.points = points
