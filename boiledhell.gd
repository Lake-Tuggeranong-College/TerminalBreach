extends StaticBody3D
var health =  9223372036854775807

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@rpc("any_peer")
func take_damageB(amount: int):
	if not is_multiplayer_authority(): return
	health -= amount
