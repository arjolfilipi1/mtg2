class_name Player
extends Node

var player_name: String = "Player"
var life_total: int = 20
var hand: Array[Card] = []
var library: Array[Card] = []
var graveyard: Array[Card] = []
var battlefield: Array[Card] = []
var mana_pool: Dictionary = {}
var has_played_land_this_turn: bool = false

func draw_card() -> Card:
	if library.size() > 0:
		var card = library.pop_front()
		hand.append(card)
		return card
	else:
		# Player loses the game if they can't draw
		print("GAME OVER: %s loses the game (deck empty)" % player_name)
		return null

func play_card_from_hand(card: Card) -> bool:
	if hand.has(card):
		# Check if it's a land
		if card.card_data.get("type", "").to_lower().contains("land"):
			if has_played_land_this_turn:
				print("Already played a land this turn")
				return false
			has_played_land_this_turn = true
		
		hand.remove_at(hand.find(card))
		battlefield.append(card)
		print("%s plays %s" % [player_name, card.card_data.get("name", "Unknown")])
		return true
	return false

func discard_card(card_index: int) -> Card:
	if hand.size() > card_index:
		var card = hand[card_index]
		hand.remove_at(card_index)
		graveyard.append(card)
		return card
	return null

func shuffle_library():
	library.shuffle()
