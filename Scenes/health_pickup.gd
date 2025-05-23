extends Node3D

@export var lifetime: float = 2
var pickup_health_percent = 0.2


# Called when the node enters the scene tree for the first time.
func _ready():
	float_object_up()
	await get_tree().create_timer(3.0).timeout
	queue_free()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func float_object_up():
	var tween = create_tween()
	tween.tween_property(self, "position", position +Vector3(0,0.5,0), 2).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(float_object_down)

func float_object_down():
	var tween = create_tween()
	tween.tween_property(self, "position", position +Vector3(0,-0.5,0), 2).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(float_object_up)


func _on_body_entered(body: Node3D) -> void:
	#if the current health is below pickup_health_percent% of the max health, the plyaer gains pickup_health_percent times max_health
	#this only happens if the player's health won't exeed the max health when then get the pickup
	#in more simple terms, the player gains 20 health if they collide with the pickup
	#the pickup then disappears
	if body.has_method("health_pickup"):
		if body.health < body.max_health: 
		#print("player collide")
			body.health_pickup(pickup_health_percent)
			queue_free()

func set_timer(time: float):
	#await(get_tree().create_timer(time), "timeout")
	var timer = get_tree().create_timer(time)
	queue_free()
