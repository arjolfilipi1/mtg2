extends Control
class_name OpponentsHandDisplay

@onready var hand_container: HBoxContainer = $"../OpponentHand/HandContainer"
@onready var card_scene = preload("res://scenes/cards/Card.tscn")

var player: Player
var card_displays: Array[Card] = []

func _ready():
	# This will be connected to the player's hand updates
	pass

func setup(player_ref: Player):
	player = player_ref
	update_hand_display()

func update_hand_display():
	# Clear existing card displays
	for card_display in card_displays:
		if is_instance_valid(card_display):
			card_display.queue_free()
	card_displays.clear()
	
	# Create new card displays for each card in hand
	for i in range(player.hand.size()):
		var card_instance = card_scene.instantiate()
		hand_container.add_child(card_instance)
		
		# Set card data
		card_instance.card_data = player.hand[i].card_data
		
		# Position and setup
		card_instance.position = Vector2(i * 120, 0)  # Stagger cards
		card_instance.scale = Vector2(0.8, 0.8)  # Scale down for hand
		
		# Connect signals for interaction
		card_instance.connect("input_event", _on_card_input.bind(card_instance, i))
		
		card_displays.append(card_instance)

func _on_card_input(event: InputEvent, card: Card, hand_index: int):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Card clicked - try to play it
			if player.play_card_from_hand(player.hand[hand_index]):
				update_hand_display()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Right click to view card details
			show_card_details(card)

func show_card_details(card: Card):
	print("Card: %s" % card.card_data.get("name", "Unknown"))
	print("Mana Cost: %s" % card.card_data.get("mana_cost", ""))
	print("Type: %s" % card.card_data.get("type", ""))
	if card.card_data.has("rules_text"):
		print("Rules: %s" % card.card_data.get("rules_text", ""))
	if card.card_data.has("power") and card.card_data.has("toughness"):
		print("Power/Toughness: %d/%d" % [card.card_data.power, card.card_data.toughness])
