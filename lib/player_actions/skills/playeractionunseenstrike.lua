PlayerAction.UnseenStrike = {}
PlayerAction.UnseenStrike.Priority = 1
function PlayerAction.UnseenStrike.Function(t, dt, player_manager, min_time, max_duration, crit_chance)
	local co = coroutine.running()
	local current_time = 0
	local function on_damage_taken()
		current_time = 0
	end
	player_manager:register_message(Message.OnPlayerDamage, co, on_damage_taken)
	while true do
		current_time = current_time + dt
		if min_time <= current_time then
			player_manager:add_coroutine(PlayerAction.UnseenStrikeStart, PlayerAction.UnseenStrikeStart, player_manager, max_duration, crit_chance)
			break
		end
		coroutine.yield(co)
	end
	player_manager:unregister_message(Message.OnPlayerDamage, co)
end
PlayerAction.UnseenStrikeStart = {}
PlayerAction.UnseenStrikeStart.Priority = 1
function PlayerAction.UnseenStrikeStart.Function(t, dt, player_manager, max_duration, crit_chance)
	local co = coroutine.running()
	local quit = false
	local current_time = 0
	local function on_damage_taken()
		quit = true
	end
	player_manager:register_message(Message.OnPlayerDamage, co, on_damage_taken)
	player_manager:add_to_crit_mul(crit_chance - 1)
	while not quit or max_duration >= current_time do
		current_time = current_time + dt
		if max_duration <= current_time and not quit then
			current_time = 0
		end
		coroutine.yield(co)
	end
	player_manager:sub_from_crit_mul(crit_chance - 1)
	player_manager:unregister_message(Message.OnPlayerDamage, co)
end
