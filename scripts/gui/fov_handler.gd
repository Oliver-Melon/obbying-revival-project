extends HSlider

@onready var textHolder = $Value
var old_text := ""
var is_sliders_enabled := true

func _ready():
	self.value = GameManager.data.fov
	old_text = str(self.value)
	_on_value_text_changed(old_text)
	GameManager.sliders_enabled_changed.connect(_on_sliders_enabled_changed)
	pass

func _on_value_text_changed(new_text: String) -> void:
	if not is_sliders_enabled:
		return
	var old_column = textHolder.caret_column
	if new_text.is_valid_int():
		old_text = new_text
		value = old_text.to_int()
	else:
		textHolder.caret_column = old_column
		textHolder.text = old_text

func _on_value_changed(n: float) -> void:
	old_text = str(n)
	var old_column = textHolder.caret_column
	if textHolder.text != old_text:
		textHolder.text = old_text
		textHolder.caret_column = old_column
	GameManager.data.fov = n

func _on_sliders_enabled_changed(enabled: bool) -> void:
	is_sliders_enabled = enabled
	if enabled:
		mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	editable = enabled
