extends Control

@onready var hold_btn: TextureButton = $HoldButton
@onready var radial: Control = $RadialMenu
@onready var player = $"../../../../Player"

@export var INNER_R  := 50
@export var OUTER_R  := 125

# Arc geometry: start at 225° (up-left) and sweep through the top to 360°/0° (right).
@export var ARC_START_DEG := 247.5
var ARC_TOTAL_DEG := 382.5 - ARC_START_DEG
var CHARS : Array

var is_open     := false
var hovered_idx := -1
var chosen_idx  := -1
var open_t      := 0.0

signal character_selected(index: int, data: Dictionary)

func _ready() -> void:
	assert(hold_btn, "CRITICAL: HOLD BUTTON node was not found!")
	hold_btn.button_down.connect(_on_hold_down)
	hold_btn.button_up.connect(_on_hold_up)
	
	assert(player, "CRITICAL: PLAYER node was not found for RADIAL BUTTON")
	CHARS = player.forms

func _on_hold_down() -> void:
	# When the button is pressed it will open at restart the idx	
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

	if open_t > 0.0 or is_open:
		radial.queue_redraw()

func _commit_selection() -> void:
	is_open = false
	if hovered_idx >= 0:
		chosen_idx = hovered_idx
		character_selected.emit(chosen_idx)
	hovered_idx = -1

# Visual rect of the button (accounts for its scale so the center matches the sprite).
func _button_rect() -> Rect2:
	return Rect2(hold_btn.global_position, hold_btn.size * hold_btn.scale)

func button_center() -> Vector2:
	return _button_rect().get_center()

func _update_hover(screen_pos: Vector2) -> void:
	var center := button_center()
	var offset := screen_pos - center
	
	# Get Mouse/Finger Angle Position
	var ang := fposmod(rad_to_deg(offset.angle()), 360.0)

	# Check if location outside of menu	
	var rel := ang - ARC_START_DEG
	if rel < 0.0:
		rel += 360.0
	if rel > ARC_TOTAL_DEG:
		hovered_idx = -1
		return
	
	# Get the hovered_idx
	var step := ARC_TOTAL_DEG / CHARS.size()
	hovered_idx = clampi(int(rel / step), 0, CHARS.size() - 1)
