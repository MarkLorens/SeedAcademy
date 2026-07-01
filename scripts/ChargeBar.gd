extends Node2D
class_name ChargeBar

@export var bar_size: Vector2 = Vector2(300, 40)   # local units (Player is scaled 0.3 -> ~90x12 px)
@export var bg_color: Color = Color(0, 0, 0, 0.6)
@export var fill_color: Color = Color(0.3, 0.9, 0.3)
@export var border_color: Color = Color(1, 1, 1, 0.85)

var ratio: float = 0.0

func set_ratio(value: float) -> void:
	ratio = clampf(value, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var origin := -bar_size * 0.5                       # center horizontally on the node
	var bg := Rect2(origin, bar_size)
	draw_rect(bg, bg_color, true)                       # background
	draw_rect(Rect2(origin, Vector2(bar_size.x * ratio, bar_size.y)), fill_color, true)  # fill
	draw_rect(bg, border_color, false, 3.0)             # border outline
