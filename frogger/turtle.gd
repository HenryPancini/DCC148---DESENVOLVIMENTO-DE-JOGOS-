extends CharacterBody2D
var moving:bool=false
@export var tilemap: TileMapLayer
@export var speed:float
@export var isleft:bool
var direction:Vector2i
func _ready() -> void:
	if isleft==false:
		direction=Vector2i.LEFT
	else:
		direction=Vector2i.RIGHT
func _physics_process(delta: float) -> void:
	if moving:
		return
	move_one_cell(direction)

func move_one_cell(direction: Vector2i):
	moving = true

	var local_position = tilemap.to_local(global_position)
	var current_cell = tilemap.local_to_map(local_position)
	var target_cell = current_cell + direction
	target_cell.x = clampi(target_cell.x, -9, 9)
	target_cell.y = clampi(target_cell.y, -5 ,8)
	var target_position = tilemap.map_to_local(target_cell)
	var target_global = tilemap.to_global(target_position)

	var tween = create_tween()
	tween.tween_property(self, "global_position", target_global, speed)

	await tween.finished
	moving = false
