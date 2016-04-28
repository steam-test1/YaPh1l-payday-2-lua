PlayerAction.ShockAndAwe = {}
PlayerAction.ShockAndAwe.Priority = 1
function PlayerAction.ShockAndAwe.Function(t, dt, player_manager, target_enemies, max_reload_increase, min_reload_increase, penalty, min_bullets)
	local co = coroutine.running()
	local running = true
	local done = false
	local enemies_killed = 1
	local function on_player_reload(weapon_unit)
		if done then
			running = false
		end
	end
	local function on_enemy_killed(weapon_unit, variant)
		if not weapon_unit and not running then
			return
		end
		local ammo = weapon_unit:base():get_ammo_remaining_in_clip()
		enemies_killed = enemies_killed + 1
		if enemies_killed >= target_enemies then
			local reload_increase = max_reload_increase
			if ammo > min_bullets then
				local num_bullets = ammo - min_bullets
				local math_max = math.max
				for i = 1, num_bullets do
					reload_increase = math_max(min_reload_increase, reload_increase * penalty)
				end
			end
			weapon_unit:base():set_temp_reload_multiplier(reload_increase)
			player_manager:unregister_message(Message.OnEnemyKilled, co)
			done = true
		end
	end
	local function on_switch_weapon_quit()
		running = false
	end
	player_manager:register_message(Message.OnSwitchWeapon, co, on_switch_weapon_quit)
	player_manager:register_message(Message.OnEnemyKilled, co, on_enemy_killed)
	player_manager:register_message(Message.OnPlayerReload, co, on_player_reload)
	while running do
		coroutine.yield(co)
	end
	player_manager:unregister_message(Message.OnSwitchWeapon, co)
	player_manager:unregister_message(Message.OnEnemyKilled, co)
	player_manager:unregister_message(Message.OnPlayerReload, co)
	player_manager.shock_and_awe_active = false
end
