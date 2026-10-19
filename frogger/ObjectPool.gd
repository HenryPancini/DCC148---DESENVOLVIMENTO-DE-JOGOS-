class_name ObjectPool
extends Node

@export var object_scene: PackedScene
@export var pool_size: int = 10

var objects: Array[Node2D]
var available: int


func _ready() -> void:
	objects.resize(pool_size)

	for i in range(pool_size):
		var obj = object_scene.instantiate()

		objects[i] = obj

		obj.process_mode = Node.PROCESS_MODE_DISABLED
		obj.hide()

		add_child(obj)

		obj.lost.connect(return_to_pool.bind(obj))

	available = pool_size


func get_from_pool() -> Node2D:
	if available == 0:
		return null

	var obj = objects[0]

	available -= 1

	objects[0] = objects[available]
	objects[available] = null

	obj.show()
	obj.process_mode = Node.PROCESS_MODE_INHERIT

	return obj


func return_to_pool(obj: Node2D) -> void:
	if available >= pool_size:
		return

	obj.call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED)
	obj.call_deferred("hide")

	objects[available] = obj
	available += 1
