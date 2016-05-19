PlayerAction.ShockAndAwe = {}
PlayerAction.ShockAndAwe.Priority = 1
function PlayerAction.ShockAndAwe.Function(player_manager, target_enemies, max_reload_increase, min_reload_increase, penalty, min_bullets, weapon_unit)
	local co = coroutine.running()
	local running = true
	local done = false
	local enemies_killed = 1
	do
		local function on_player_reload(weapon_unit)
			if done and alive(weapon_unit) then
				running = false
				local reload_multiplier = max_reload_increase
				local ammo = weapon_unit:base():get_ammo_remaining_in_clip()
				if player_manager:has_category_upgrade("player", "automatic_mag_increase") then
					ammo = ammo - player_manager:upgrade_value("player", "automatic_mag_increase", 0)
				end
				if ammo > min_bullets then
					local num_bullets = ammo - min_bullets
					local math_max = math.max
					for i = 1, num_bullets do
						reload_multiplier = math_max(min_reload_increase, reload_multiplier * penalty)
					end
				end
				player_manager:add_consumable_upgrade("shock_and_awe_reload_multiplier", 1, reload_multiplier)
			end
		end
		local function on_enemy_killed(equipped_unit, variant, killed_unit)
			if not alive(weapon_unit) or not running then
				return
			end
			enemies_killed = enemies_killed + 1
			if enemies_killed == target_enemies then
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
	end
	while running and alive(weapon_unit) and weapon_unit == player_manager:equipped_weapon_unit() do
		coroutine.yield(co)
	end
	player_manager:unregister_message(Message.OnSwitchWeapon, co)
	player_manager:unregister_message(Message.OnEnemyKilled, co)
	player_manager:unregister_message(Message.OnPlayerReload, co)
end
