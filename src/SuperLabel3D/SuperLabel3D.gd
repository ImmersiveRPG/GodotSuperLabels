# Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is licensed under the MIT License
# https://github.com/ImmersiveRPG/GodotSuperLabels

@tool
extends RigidBody3D

var _is_setup := false
var _outline_color := Color.BLACK
var _font_color := Color.WHITE
var _line_color := Color.WHITE
var _points := PackedVector2Array()
var _points_empty := PackedVector2Array()
@export var _dock_distance : float = 50.0
@export var _visibility_distance : float = 100.0
var _text : String = ""
@onready var _line : Line2D = $Line2D

@export var _attached_to_node_path : NodePath
var _attached_to : Node3D

@export var font_color : Color = _font_color:
	get:
		if _is_setup:
			_font_color = $Label3D.modulate
		return _font_color
	set(value):
		_font_color = value
		if _is_setup:
			$Label3D.modulate = _font_color

@export var outline_color : Color = _outline_color:
	get:
		if _is_setup:
			_outline_color = $Label3D.outline_modulate
		return _outline_color
	set(value):
		_outline_color = value
		if _is_setup:
			$Label3D.outline_modulate = _outline_color

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

func _init() -> void:
	_points.resize(2)

func _ready() -> void:
	_is_setup = true

	self.text = _text
	self.font_color = _font_color
	self.outline_color = _outline_color
	self.line_color = _line_color
	_attached_to = self.get_node(_attached_to_node_path)

func _physics_process(delta : float) -> void:
	self.linear_velocity = self.linear_velocity.lerp(Vector3.ZERO, delta)
	self.angular_velocity = self.angular_velocity.lerp(Vector3.ZERO, delta)

func set_color(font_color_ : Color, outline_color_ : Color, line_color_ : Color) -> void:
	self.font_color = font_color_
	self.outline_color = outline_color_
	self.line_color = line_color_

func set_text(text_ : String) -> void:
	self.text = text_


func _on_timer_update_line_timeout() -> void:
	if not _is_setup: return
	var camera : Camera3D = Global._camera
	if camera == null: return

	_line.points = _points_empty # FIXME: Having to do this is stupid
	var src := self.global_transform.origin
	var dest : Vector3 = _attached_to.global_transform.origin
	var distance := camera.global_transform.origin.distance_to(dest)
	#print([self, _attached_to])
	#self.get_viewport().get_camera_3d()

	#var is_in_dock_range := distance <= _dock_distance
	var is_in_visibility_range := distance <= _visibility_distance
	var is_in_frustum := camera.is_position_in_frustum(dest)
	var is_visible := is_in_visibility_range and is_in_frustum

	if is_visible:
		self.visible = true
		var src_2d := camera.unproject_position(src)
		var dest_2d := camera.unproject_position(dest)
		_points.set(0, src_2d)
		_points.set(1, dest_2d)
		_line.points = _points
		#print([Global._line.global_position, Global._line.points])


func _on_timer_update_distance_timeout() -> void:
	if not _is_setup: return
	var camera : Camera3D = Global._camera
	if camera == null: return

	#var src := self.global_transform.origin
	var dest : Vector3 = _attached_to.global_transform.origin
	var distance := camera.global_transform.origin.distance_to(dest)

	var is_in_dock_range := distance <= _dock_distance
	var is_in_visibility_range := distance <= _visibility_distance
	var is_in_frustum := camera.is_position_in_frustum(dest)
	var is_visible := is_in_visibility_range and is_in_frustum

	#if not Engine.is_editor_hint():
	if is_visible:
		self.visible = true
	else:
		self.visible = false

	if is_in_dock_range:
		if Global._labels.find(self) == -1:
			#print("Adding %s" % [self.name])
			Global._labels.append(self)
			self.global_transform.origin = Global._label_container.global_transform.origin
			$TimerUpdateLine.start()
	else:
		if Global._labels.find(self) != -1:
			#print("Removing %s" % [self.name])
			Global._labels.erase(self)
			$TimerUpdateLine.stop()
			_line.points = _points_empty # FIXME: Having to do this is stupid
		self.global_transform.origin = dest + Vector3(0, 5, 0)
		self.linear_velocity = Vector3.ZERO
		self.angular_velocity = Vector3.ZERO

