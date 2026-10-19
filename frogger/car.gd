extends Area2D
var moving:bool=false
@export var tilemap: TileMapLayer
@export var speed:float
@export var isleft:bool
var direction:Vector2i
@export var car_pool: Node
signal lost
func _ready() -> void:
	if isleft==false:
		direction=Vector2i.LEFT
	else:
		direction=Vector2i.RIGHT
func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage()
	if moving:
		return
	move_one_cell(direction)


func move_one_cell(direction: Vector2i):
	moving = true

	var local_position = tilemap.to_local(global_position)
	var current_cell = tilemap.local_to_map(local_position)
	var target_cell = current_cell + direction
	if target_cell.x < -10 or target_cell.x > 8:
		moving = false
		lost.emit()
		return
	var target_position = tilemap.map_to_local(target_cell)
	var target_global = tilemap.to_global(target_position)

	var tween = create_tween()
	tween.tween_property(self, "global_position", target_global, speed)

	await tween.finished
	moving = false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()
