extends Control

@onready var hold_btn: TextureButton = $HoldButton
@onready var radial: Control = $RadialMenu

@export var player : CharacterBody2D

# Angle (screen space, 0°=right / 90°=down / 180°=left / 270°=up) where segment 0
# begins. 225° puts segment 0 at 225–315° (centered on "up" = top of the wheel),
# then 315–45° (right), 45–135° (bottom), 135–225° (left).
@export var ARC_START_DEG := 225

# The wheel art is always drawn as 4 fixed segments, even before every form is
# unlocked. Hovering maps to one of these 4 slots; only unlocked slots commit.
const SEGMENTS := 4
var CHARS : Array

var is_open     := false
var hovered_idx := -1
var open_t      := 0.0

signal character_selected(index: int)

func _ready() -> void:
	assert(hold_btn, "CRITICAL: HOLD BUTTON node was not found!")
	hold_btn.button_down.connect(_on_hold_down)
	hold_btn.button_up.connect(_on_hold_up)
	
	assert(player, "CRITICAL: PLAYER node was not found for RADIAL BUTTON")
	CHARS = player.forms
	player.forms_changed.connect(_on_forms_changed)

func _on_forms_changed(forms: Array) -> void:
	CHARS = forms

func _on_hold_down() -> void:
	is_open = true
	hovered_idx = -1
	
func _on_hold_up() -> void:
	if is_open:
		_commit_selection()

func _process(delta: float) -> void:
	if is_open:
		open_t = min(open_t + delta / 0.08, 1.0)
		_update_hover(get_global_mouse_position())
	else:
		open_t = max(open_t - delta / 0.10, 0.0)

func _commit_selection() -> void:
	is_open = false
	# Only commit if the hovered segment maps to an unlocked form.
	if hovered_idx >= 0 and hovered_idx < CHARS.size():
		character_selected.emit(hovered_idx)
	hovered_idx = -1

# Visual rect of the button (accounts for its scale so the center matches the sprite).
func _button_rect() -> Rect2:
	return Rect2(hold_btn.global_position, hold_btn.size * hold_btn.scale)

func button_center() -> Vector2:
	return _button_rect().get_center()

func _update_hover(screen_pos: Vector2) -> void:
	var center := button_center()
	var offset := screen_pos - center

	# Mouse/finger angle in screen space (0°=right, 90°=down, 180°=left, 270°=up).
	var ang := fposmod(rad_to_deg(offset.angle()), 360.0)

	# Rotate so segment 0 starts at ARC_START_DEG, wrapping so the slice that
	# crosses 0° (315–45°) buckets correctly, then split into 4 equal slices.
	var rel := fposmod(ang - ARC_START_DEG, 360.0)
	var step := 360.0 / SEGMENTS
	hovered_idx = clampi(int(rel / step), 0, SEGMENTS - 1)
