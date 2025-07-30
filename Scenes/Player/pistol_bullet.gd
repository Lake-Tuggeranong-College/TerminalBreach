extends Area3D
signal enemy_hit
var speed: float = 75.0
var damage: int = 75
@export var lifetime: float = 5.0
var ccd_enabled = true
var direction: Vector3
var step_size = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
		direction = transform.basis.z.normalized()  # Assuming forward is along Z
		set_timer(lifetime)
		set_as_top_level(true)
		#set_position(translation + direction * speed * get_process_delta_time())
		#connect("body_entered", self, "_on_body_entered")

	await get_tree().create_timer(3.0).timeout
	destroy()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_transform.origin -= transform.basis.z.normalized() * speed * delta
	var remaining_distance = speed * delta
	
		
		# Manually check for collisions
	var collisions = get_overlapping_bodies()



func set_timer(time: float):
	#await(get_tree().create_timer(time), "timeout")
	var timer = get_tree().create_timer(time)
	queue_free()
	

func _on_body_entered(body):
	#print("bullet hit")
	#print (body.name)

	if body.has_method("take_damage"):
		#print("ow")
		body.take_damage(damage)

		enemy_hit.emit()
		destroy()

func destroy():
	queue_free()
