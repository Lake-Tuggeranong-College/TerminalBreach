extends Node3D  # This script is on Node3D

@onready var hit_sound = get_node("../lobotomy")  # Go up one level and find the sound

var player: Node3D = null

func _ready():
	await get_tree().create_timer(0.1).timeout
	while player == null:
		player = get_tree().get_root().find_child("Player", true, false)
		await get_tree().create_timer(0.1).timeout

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		print("peen")
		if hit_sound:
			hit_sound.play()
		if body.has_method("take_damage"):
			body.take_damage(190)
