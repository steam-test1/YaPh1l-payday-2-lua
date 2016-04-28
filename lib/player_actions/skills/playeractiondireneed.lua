PlayerAction.DireNeed = {}
PlayerAction.DireNeed.Priority = 1
function PlayerAction.DireNeed.Function(t, dt, is_armor_regenerating_func, target_time)
	local co = coroutine.running()
	local quit = false
	managers.player:send_message(Message.SetWeaponStagger, nil, true)
	local function on_enemy_shot()
		quit = true
	end
	managers.player:register_message(Message.OnEnemyShot, co, on_enemy_shot)
	while is_armor_regenerating_func() and not quit do
		coroutine.yield(co)
	end
	local current_time = 0
	while target_time >= current_time and not quit do
		current_time = current_time + dt
		coroutine.yield(co)
	end
	managers.player:send_message(Message.SetWeaponStagger, nil, false)
	managers.player:unregister_message(Message.OnEnemyShot, co)
end
