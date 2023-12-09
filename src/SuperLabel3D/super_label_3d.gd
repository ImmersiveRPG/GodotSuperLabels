
@tool
extends RigidBody3D

var _is_setup := false
var _outline_color := Color.BLACK
var _font_color := Color.WHITE
var _line_color := Color.WHITE
var _text := ""
@onready var _line : Line2D = $Line2D

@export var _attached_to_node_path : NodePath
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
	_line.points.clear()
	var src := self.global_transform.origin
	var dest : Vector3 = self.get_node(_attached_to_node_path).global_transform.origin

	#var offset := self.get_viewport().get_visible_rect().size * 0.5
	var src_2d := Global._camera.unproject_position(src)
	var dest_2d := Global._camera.unproject_position(dest)
	var points := PackedVector2Array()
	points.append(src_2d)
	points.append(dest_2d)
	_line.points = points
	#print([Global._line.global_position, Global._line.points, offset])

