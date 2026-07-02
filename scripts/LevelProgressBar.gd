@tool
extends TextureProgressBar

## Progress shown by the bar (0-100). Also updates the "%" label.
@export_range(0.0, 100.0, 1.0) var progress: float = 0.0:
	set(v):
		progress = clampf(v, 0.0, 100.0)
		_refresh()

@onready var _label: Label = $ProgressLabel

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	value = progress
	if _label != null:
		_label.text = "%d%%" % roundi(progress)
