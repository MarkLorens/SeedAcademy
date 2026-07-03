@tool
extends TextureProgressBar

## Progress shown by the bar (0-100). Also updates the "%" label.
@export_range(0.0, 100.0, 1.0) var progress: float = 0.0:
	set(v):
		progress = clampf(v, 0.0, 100.0)
		_refresh()

@onready var _label: Label = $ProgressLabel
@onready var _edge: TextureRect = $Edge

func _ready() -> void:
	resized.connect(_refresh)
	_refresh()

## Give the bar a level's art (see level_data.progress_fill / progress_edge).
## Either argument may be null to keep the current texture.
func set_level_textures(fill: Texture2D, edge: Texture2D) -> void:
	if fill != null:
		texture_progress = fill
	if edge != null and _edge != null:
		_edge.texture = edge
	_refresh()

func _refresh() -> void:
	value = progress
	if _label != null:
		_label.text = "%d%%" % roundi(progress)
	_update_edge()

# Keep the cap texture riding the tip of the fill.
func _update_edge() -> void:
	if _edge == null:
		return
	# No cap art, or the tip is hidden/at the bar's own rounded end.
	if _edge.texture == null or progress <= 1.0 or progress >= 99.0:
		_edge.visible = false
		return
	_edge.visible = true
	var h := size.y
	var w := h * _edge.texture.get_width() / float(_edge.texture.get_height())
	_edge.size = Vector2(w, h)
	_edge.position = Vector2(size.x * progress / 100.0 - w * 0.5, 0.0)
