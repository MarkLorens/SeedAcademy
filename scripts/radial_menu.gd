extends Control

@export var background_color : Color = Color(0.96, 0.96, 0.96, 1.0)
@export var line_color : Color = Color(0.0, 0.6, 0.75, 1.0)

# Get Parent Button (Radial Button)
@onready var btn : = $".."

func _ready() -> void:
	assert(btn, "CRITICAL: Radial button node was not found!")

func _process(_delta: float) -> void:	
	# Draw if Button is pressed
	if btn.open_t > 0.0 or btn.is_open:
		queue_redraw()

func _draw() -> void:		
	var alpha = btn.open_t
	if alpha <= 0.001:
		return

	# Draw around the button center, converted into this control's local space.
	var center: Vector2 = get_global_transform().affine_inverse() * btn.button_center()
	var chars = btn.CHARS
	var n = chars.size()
	var start = deg_to_rad(btn.ARC_START_DEG)
	var step = deg_to_rad(btn.ARC_TOTAL_DEG / n)
	
	print(btn.ARC_TOTAL_DEG)

	var font := ThemeDB.fallback_font
	var font_size := 20

	for i in range(n):
		var a0 = start + step * i
		var a1 = start + step * (i + 1)
		var is_hov = i == btn.hovered_idx
		var r_in = btn.INNER_R
		var r_out = btn.OUTER_R + (16.0 if is_hov else 0.0)

		# Build the slice polygon (inner arc out to outer arc).
		var pts = PackedVector2Array()
		var segs = 24
		
		for s in range(segs + 1):
			var a = lerp(a0, a1, float(s) / segs)
			pts.append(center + Vector2(cos(a), sin(a)) * r_in)
		for s in range(segs, -1, -1):
			var a = lerp(a0, a1, float(s) / segs)
			pts.append(center + Vector2(cos(a), sin(a)) * r_out)

		var fill_a = (1.0 if is_hov else 0.85) * alpha
		
		draw_colored_polygon(pts, Color(line_color.r, line_color.g, line_color.b, fill_a))
		draw_polyline(pts + PackedVector2Array([pts[0]]),
			Color(1, 1, 1, alpha), (3.0 if is_hov else 1.5), true)

		# Slice label, placed at the mid-angle / mid-radius.
		var mid_a = (a0 + a1) * 0.5
		var label_r = (r_in + r_out) * 0.5
		var label_pos = center + Vector2(cos(mid_a), sin(mid_a)) * label_r
		var text = str(chars[i].form_name)
		var ts = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		
		draw_string(font, label_pos - Vector2(ts.x * 0.5, -ts.y * 0.25),
			text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1, 1, 1, alpha))
