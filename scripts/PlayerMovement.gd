extends CharacterBody2D

const GRAVITY: int = 4200

@onready var radial_button: Control = $"../LevelUI/CanvasLayer/MarginContainer/RadialButton"
@onready var action_button: TextureButton = $"../LevelUI/CanvasLayer/MarginContainer2/ActionButton/TextureButton"
@export var forms: Array[FormData] = []

var current_form_index: int = 0
var current_form: FormData

func _ready() -> void:
	$AttackCol.hide()
	set_form(0)
	
	assert(radial_button, "CRITICAL: Radial button node was not found!")
	radial_button.character_selected.connect(_on_form_selected)
	
	assert(action_button, "CRITICAL: Action button node was not found!")
	action_button.pressed.connect(action_pressed)

# Fired by the radial menu when a slice is chosen on release.
func _on_form_selected(index: int) -> void:
	if index >= 0 and index < self.forms.size():
		self.set_form(index)

# Fired by action button
func action_pressed() -> void:
	self.current_form.action_script.execute(self, self.current_form)
	
func set_form(index: int) -> void:
	current_form_index = index
	current_form = forms[index]
	$Sprite2D.texture = current_form.form_texture

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * current_form.gravity_scale * delta
	move_and_slide()
