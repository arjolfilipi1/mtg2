class_name TurnPhases

enum {
	BEGINNING_PHASE,
	UNTAP_STEP,
	UPKEEP_STEP,
	DRAW_STEP,
	FIRST_MAIN_PHASE,
	COMBAT_PHASE,
	BEGINNING_OF_COMBAT_STEP,
	DECLARE_ATTACKERS_STEP,
	DECLARE_BLOCKERS_STEP,
	COMBAT_DAMAGE_STEP,
	END_OF_COMBAT_STEP,
	SECOND_MAIN_PHASE,
	END_PHASE,
	END_STEP,
	CLEANUP_STEP
}

static func get_phase_name(phase: int) -> String:
	match phase:
		UNTAP_STEP: return "Untap Step"
		UPKEEP_STEP: return "Upkeep Step"
		DRAW_STEP: return "Draw Step"
		FIRST_MAIN_PHASE: return "First Main Phase"
		BEGINNING_OF_COMBAT_STEP: return "Beginning of Combat"
		DECLARE_ATTACKERS_STEP: return "Declare Attackers"
		DECLARE_BLOCKERS_STEP: return "Declare Blockers"
		COMBAT_DAMAGE_STEP: return "Combat Damage"
		END_OF_COMBAT_STEP: return "End of Combat"
		SECOND_MAIN_PHASE: return "Second Main Phase"
		END_STEP: return "End Step"
		CLEANUP_STEP: return "Cleanup Step"
		_: return "Unknown Phase"
