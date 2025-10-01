extends Node
class_name GameManager
# Add these variables
@onready var hand_display: HandDisplay = $UI/CurrentPlayerHand
@onready var opponent_hand_display: OpponentsHandDisplay = $UI/OpponentHand

signal phase_changed(new_phase: int)
signal turn_started(player_index: int)
signal turn_ended(player_index: int)
@onready var camera_controller: CameraController = $GameWorld/Camera2D
@onready var board: Node2D = $GameWorld/Board
@onready var players: Array[Player] = [Player.new(), Player.new()]
@onready var current_player_index: int = 0
@onready var current_phase: int = TurnPhases.UNTAP_STEP
@onready var turn_count: int = 0
@onready var priority_player_index: int = 0
@onready var is_first_turn: bool = true  # Track if this is the first turn

# Phase timing (in seconds)
var phase_timers: Dictionary = {
	TurnPhases.UPKEEP_STEP: 10.0,
	TurnPhases.FIRST_MAIN_PHASE: 60.0,
	TurnPhases.SECOND_MAIN_PHASE: 60.0,
}

var current_phase_timer: float = 0.0
var is_waiting_for_response: bool = false

func _ready():
	initialize_game()
	start_game_with_opening_hands()
	setup_hand_displays()
	start_turn()
	
func _process(delta):
	if not is_waiting_for_response:
		current_phase_timer -= delta
		if current_phase_timer <= 0:
			advance_phase()
	$UI/TurnUI/waiting.text = "Phase: %s" % str(is_waiting_for_response)
# NEW: Setup hand displays
func setup_hand_displays():
	# Setup current player's hand display
	if hand_display:
		hand_display.setup(get_current_player())
	
	# Setup opponent's hand display (face down)
	if opponent_hand_display:
		opponent_hand_display.setup(get_opposing_player())
		# You might want to show opponent's hand as face down cards

func initialize_game():
	# Setup players and decks
	for i in range(players.size()):
		players[i].player_name = "Player %d" % (i + 1)
		players[i].life_total = 20
		setup_player_deck(players[i])
	
	# Determine who goes first
	current_player_index = randi() % players.size()
	priority_player_index = current_player_index

func setup_player_deck(player: Player):
	# Create a simple test deck
	var card_scene = preload("res://scenes/cards/Card.tscn")
	
	# Add lands
	for i in range(15):
		var card = card_scene.instantiate()
		card.card_data = {
			"name": "Forest",
			"mana_cost": "",
			"type": "Land - Forest",
			"rules_text": "{T}: Add {G}"
		}
		player.library.append(card)
	
	# Add creatures
	for i in range(15):
		var card = card_scene.instantiate()
		card.card_data = {
			"name": "Grizzly Bears",
			"mana_cost": "{1}{G}",
			"type": "Creature - Bear",
			"power": 2,
			"toughness": 2
		}
		player.library.append(card)
	
	# Add spells
	for i in range(10):
		var card = card_scene.instantiate()
		card.card_data = {
			"name": "Giant Growth",
			"mana_cost": "{G}",
			"type": "Instant",
			"rules_text": "Target creature gets +3/+3 until end of turn."
		}
		player.library.append(card)
	
	player.shuffle_library()
	
	# Draw starting hand
	print("%s's deck shuffled (%d cards)" % [player.player_name, player.library.size()])

func start_turn():
	turn_count += 1
	current_phase = TurnPhases.UNTAP_STEP
	current_phase_timer = 0.0  # Untap is instant
	
	emit_signal("turn_started", current_player_index)
	print("Turn %d started for %s" % [turn_count, get_current_player().player_name])
	
	execute_current_phase()

func execute_current_phase():
	match current_phase:
		TurnPhases.UNTAP_STEP:
			untap_step()
		TurnPhases.UPKEEP_STEP:
			upkeep_step()
		TurnPhases.DRAW_STEP:
			draw_step()
		TurnPhases.FIRST_MAIN_PHASE:
			main_phase(true)
		TurnPhases.BEGINNING_OF_COMBAT_STEP:
			beginning_of_combat_step()
		TurnPhases.DECLARE_ATTACKERS_STEP:
			declare_attackers_step()
		TurnPhases.DECLARE_BLOCKERS_STEP:
			declare_blockers_step()
		TurnPhases.COMBAT_DAMAGE_STEP:
			combat_damage_step()
		TurnPhases.END_OF_COMBAT_STEP:
			end_of_combat_step()
		TurnPhases.SECOND_MAIN_PHASE:
			main_phase(false)
		TurnPhases.END_STEP:
			end_step()
		TurnPhases.CLEANUP_STEP:
			cleanup_step()
	
	emit_signal("phase_changed", current_phase)
	update_ui()

func untap_step():
	print("Untap Step")
	var player = get_current_player()
	
	# Untap all permanents
	for card in player.battlefield:
		card.untap()
	
	# Reset "until end of turn" effects
	player.has_played_land_this_turn = false
	
	advance_phase()

func upkeep_step():
	print("Upkeep Step")
	print($UI/TurnUI/PhaseLabel.text)
	current_phase_timer = phase_timers.get(TurnPhases.UPKEEP_STEP, 10.0)
	is_waiting_for_response = true
	
	# Trigger upkeep abilities here
	trigger_abilities("upkeep")

func draw_step():
	print("Draw Step")
	var player = get_current_player()
	
	# Magic: The Gathering draw rules:
	# - First turn of the game: Active player does NOT draw (skip draw)
	# - All other turns: Active player draws 1 card
	# - Both players start with 7 cards from initial draw
	
	if is_first_turn and turn_count == 1:
		# First turn of the game - active player skips draw
		print("%s skips draw (first turn of game)" % player.player_name)
	else:
		# Normal draw - draw 1 card
		var drawn_card = player.draw_card()
		if drawn_card:
			print("%s draws: %s" % [player.player_name, drawn_card.card_data.get("name", "Unknown")])
		else:
			print("%s cannot draw - library empty!" % player.player_name)
	
	advance_phase()

func main_phase(is_first_main: bool):
	var phase_name = "First Main Phase" if is_first_main else "Second Main Phase"
	print(phase_name)
	
	current_phase_timer = phase_timers.get(
		TurnPhases.FIRST_MAIN_PHASE if is_first_main else TurnPhases.SECOND_MAIN_PHASE, 
		60.0
	)
	is_waiting_for_response = true
	
	# The player can play lands and cast spells during this phase
	# This is handled through UI interactions

func beginning_of_combat_step():
	print("Beginning of Combat")
	current_phase_timer = 15.0
	is_waiting_for_response = true
	
	trigger_abilities("beginning_of_combat")

func declare_attackers_step():
	print("Declare Attackers")
	current_phase_timer = 30.0
	is_waiting_for_response = true
	
	# Player declares attackers here
	# This would be handled through UI

func declare_blockers_step():
	print("Declare Blockers")
	current_phase_timer = 30.0
	is_waiting_for_response = true
	
	# Opponent declares blockers here
	# This would be handled through UI

func combat_damage_step():
	print("Combat Damage")
	resolve_combat_damage()
	advance_phase()

func end_of_combat_step():
	print("End of Combat")
	advance_phase()

func end_step():
	print("End Step")
	current_phase_timer = 15.0
	is_waiting_for_response = true
	
	trigger_abilities("end_step")

func cleanup_step():
	print("Cleanup Step")
	
	var player = get_current_player()
	
	# Discard down to maximum hand size (usually 7)
	var max_hand_size = 7
	while player.hand.size() > max_hand_size:
		# In a real game, player would choose which card to discard
		if player.hand.size() > 0:
			player.discard_card(player.hand.size() - 1)
	
	# Remove "until end of turn" effects
	clear_temporary_effects()
	# After first turn cleanup, the first turn is complete
	if is_first_turn and turn_count == 1:
		is_first_turn = false
		print("First turn completed - normal draw rules now apply")
	end_turn()

func advance_phase():
	# Move to next phase
	var next_phase = get_next_phase(current_phase)
	
	if next_phase == TurnPhases.UNTAP_STEP:
		# We've completed the turn cycle
		end_turn()
	else:
		current_phase = next_phase
		execute_current_phase()

func get_next_phase(current_phase: int) -> int:
	match current_phase:
		TurnPhases.UNTAP_STEP: return TurnPhases.UPKEEP_STEP
		TurnPhases.UPKEEP_STEP: return TurnPhases.DRAW_STEP
		TurnPhases.DRAW_STEP: return TurnPhases.FIRST_MAIN_PHASE
		TurnPhases.FIRST_MAIN_PHASE: return TurnPhases.BEGINNING_OF_COMBAT_STEP
		TurnPhases.BEGINNING_OF_COMBAT_STEP: return TurnPhases.DECLARE_ATTACKERS_STEP
		TurnPhases.DECLARE_ATTACKERS_STEP: return TurnPhases.DECLARE_BLOCKERS_STEP
		TurnPhases.DECLARE_BLOCKERS_STEP: return TurnPhases.COMBAT_DAMAGE_STEP
		TurnPhases.COMBAT_DAMAGE_STEP: return TurnPhases.END_OF_COMBAT_STEP
		TurnPhases.END_OF_COMBAT_STEP: return TurnPhases.SECOND_MAIN_PHASE
		TurnPhases.SECOND_MAIN_PHASE: return TurnPhases.END_STEP
		TurnPhases.END_STEP: return TurnPhases.CLEANUP_STEP
		TurnPhases.CLEANUP_STEP: return TurnPhases.UNTAP_STEP
		_: return TurnPhases.UNTAP_STEP



# In the end_turn function, update hand displays when player changes
func end_turn():
	emit_signal("turn_ended", current_player_index)
	
	print("=== Turn %d ended for %s ===" % [turn_count, get_current_player().player_name])
	print("Hand size: %d, Battlefield: %d, Library: %d" % [
		get_current_player().hand.size(),
		get_current_player().battlefield.size(), 
		get_current_player().library.size()
	])
	
	# Switch to next player
	current_player_index = (current_player_index + 1) % players.size()
	priority_player_index = current_player_index
	
	# Update hand displays for new current player
	setup_hand_displays()
	
	start_turn()
	
func start_game_with_opening_hands():
	print("=== Setting up opening hands ===")
	
	# Each player draws 7 cards for their opening hand
	for player in players:
		for i in range(7):
			var drawn_card = player.draw_card()
			if drawn_card:
				print("%s draws: %s" % [player.player_name, drawn_card.card_data.get("name", "Unknown")])
			else:
				print("ERROR: %s cannot draw full opening hand!" % player.player_name)
		
		print("%s's opening hand: %d cards" % [player.player_name, player.hand.size()])
	
	# Optional: Implement mulligan system here
	print("=== Opening hands complete ===")

func get_current_player() -> Player:
	return players[current_player_index]

func get_opposing_player() -> Player:
	return players[(current_player_index + 1) % players.size()]

# Player Actions (called from UI)
func player_passes_priority():
	if is_waiting_for_response:
		priority_player_index = (priority_player_index + 1) % players.size()
		
		if priority_player_index == current_player_index:
			# All players have passed, advance phase
			is_waiting_for_response = false
			current_phase_timer = 0.0

func player_plays_card(card: Card):
	if is_waiting_for_response and get_current_player().play_card_from_hand(card):
		# Card was successfully played
		update_ui()

func player_attacks_with(creatures: Array[Card]):
	if current_phase == TurnPhases.DECLARE_ATTACKERS_STEP:
		# Set attacking creatures
		# This would be more complex in a real implementation
		pass

# Combat System
func resolve_combat_damage():
	# Simplified combat resolution
	var attacker = get_current_player()
	var defender = get_opposing_player()
	
	# This is a very simplified combat system
	# In reality, you'd need to handle blocking, trample, first strike, etc.
	print("Resolving combat damage...")

# Helper functions
func trigger_abilities(ability_type: String):
	# Trigger abilities based on type (upkeep, beginning_of_combat, etc.)
	pass

func clear_temporary_effects():
	# Clear "until end of turn" effects
	pass

func update_ui():
	# Update the game UI to reflect current state
	print("Current Phase: %s" % TurnPhases.get_phase_name(current_phase))
	print("Current Player: %s" % get_current_player().player_name)
	
	# Update hand displays
	if hand_display:
		hand_display.update_hand_display()
	if opponent_hand_display:
		opponent_hand_display.update_hand_display()
	
	# Show hand sizes
	print("Player hand: %d cards" % get_current_player().hand.size())
	print("Opponent hand: %d cards" % get_opposing_player().hand.size())
