extends Camera2D
class_name CameraController

# Camera movement speed
var pan_speed: float = 500.0
var zoom_speed: float = 0.1
var min_zoom: float = 0.5
var max_zoom: float = 2.0

func _ready():
	# Make sure this is the current camera
	make_current()
	
	# Set initial zoom and position
	zoom = Vector2(1.0, 1.0)
	position = Vector2(640, 360)  # Center of 1280x720 screen

func _input(event):
	# Zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_camera(zoom_speed)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_camera(-zoom_speed)
	
	# Pan with arrow keys or WASD
	if event is InputEventKey and event.pressed:
		var direction = Vector2.ZERO
		if event.keycode == KEY_W or event.keycode == KEY_UP:
			direction.y -= 1
		if event.keycode == KEY_S or event.keycode == KEY_DOWN:
			direction.y += 1
		if event.keycode == KEY_A or event.keycode == KEY_LEFT:
			direction.x -= 1
		if event.keycode == KEY_D or event.keycode == KEY_RIGHT:
			direction.x += 1
		
		if direction != Vector2.ZERO:
			position += direction.normalized() * pan_speed * (1.0 / zoom.x)

func zoom_camera(zoom_delta: float):
	var new_zoom = zoom + Vector2(zoom_delta, zoom_delta)
	new_zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	zoom = new_zoom
