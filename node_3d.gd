extends Node3D

var player: Node3D = null  # Declare at the top, not @onready

func _ready():
	# Wait until the player exists in the scene tree
	await get_tree().create_timer(0.1).timeout
	while player == null:
		player = get_tree().get_root().find_child("Player", true, false)
		await get_tree().create_timer(0.1).timeout

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		print("peen")
		# Example damage logic:
		if body.has_method("take_damage"):
			body.take_damage(190)
