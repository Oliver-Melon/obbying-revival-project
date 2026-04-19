@tool
extends CSGBox3D
class_name DamageDealer

@export var damage:float = 10.0

func _ready():
	if not is_in_group("DamageDealer"):
		add_to_group("DamageDealer")
	pass
