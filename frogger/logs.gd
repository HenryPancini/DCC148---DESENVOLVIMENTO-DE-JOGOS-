extends Area2D
var moving:bool=false
@export var tilemap: TileMapLayer
@export var speed:float
@export var isleft:bool
var direction:Vector2i
@export var log_pool: Node
signal lost
func _ready() -> void:
	add_to_group("logs")
	if isleft==false:
		direction=Vector2i.LEFT
	else:
		direction=Vector2i.RIGHT
func _physics_process(delta: float) -> void:
	if moving:
		return
	move_one_cell(direction)
signal moving_platform(delta_position: Vector2)

func move_one_cell(direction: Vector2i):
	moving = true

	var local_position = tilemap.to_local(global_position)
	var current_cell = tilemap.local_to_map(local_position)
	var target_cell = current_cell + direction

	if target_cell.x > 12 or target_cell.x<-12:
		moving = false
		lost.emit()
		return

	var target_position = tilemap.map_to_local(target_cell)
	var target_global = tilemap.to_global(target_position)

	var tween = create_tween()
	tween.tween_property(self, "global_position", target_global, speed)

	var previous_position = global_position

	while tween.is_running():
		await get_tree().process_frame

		if not is_instance_valid(self):
			return

		var displacement = global_position - previous_position
		previous_position = global_position

		if displacement != Vector2.ZERO:
			moving_platform.emit(displacement)

	moving = false
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.current_platform != self:
			if body.current_platform != null:
				var old_platform = body.current_platform
				if old_platform.moving_platform.is_connected(body._on_platform_moving):
					old_platform.moving_platform.disconnect(body._on_platform_moving)

			body.current_platform = self

			if not moving_platform.is_connected(body._on_platform_moving):
				moving_platform.connect(body._on_platform_moving)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.current_platform == self:
			if moving_platform.is_connected(body._on_platform_moving):
				moving_platform.disconnect(body._on_platform_moving)

			body.current_platform = null
