extends CheckButton


func _on_toggled(toggled_on: bool) -> void:
	GameManager.RPC = toggled_on
	print(GameManager.RPC)
