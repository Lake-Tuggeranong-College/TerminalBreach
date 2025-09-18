extends MeshInstance3D

var toggle = false
var interactable = true
@export var animation_player: AnimationPlayer

func interact():
	if interactable == true:
		interactable = false
		toggle = !toggle
		if toggle == false:
			animation_player.play("door_close")
		if toggle == true:
			animation_player.play("door_open")
		await get_tree().create_timer(5.0, false).timeout
		interactable = true
