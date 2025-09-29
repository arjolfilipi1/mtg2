extends Control

@onready var game_manager: GameManager
@onready var phase_label: Label = $PhaseLabel
@onready var turn_label: Label = $TurnLabel
@onready var pass_button: Button = $PassButton

func _ready():
	game_manager = get_node("/root/GameManager")
	game_manager.phase_changed.connect(_on_phase_changed)
	game_manager.turn_started.connect(_on_turn_started)

func _on_phase_changed(new_phase: int):
	phase_label.text = "Phase: %s" % TurnPhases.get_phase_name(new_phase)
	turn_label.text = "Turn: %d - %s" % [game_manager.turn_count, game_manager.get_current_player().player_name]

func _on_turn_started(player_index: int):
	update_ui()

func _on_pass_button_pressed():
	game_manager.player_passes_priority()

func update_ui():
	# Update UI elements based on current game state
	pass
