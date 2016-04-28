PlayerAction.FullyLoaded = {}
PlayerAction.FullyLoaded.Priority = 1
function PlayerAction.FullyLoaded.Function(t, dt, player_manager, pickup_chance, increase)
	local player_unit = player_manager:player_unit()
	local gained_throwable = false
	local chance = pickup_chance
	local function on_ammo_pickup(unit)
		if unit == player_unit then
			local rand = math.random()
			if rand < chance then
				gained_throwable = true
				player_manager:add_grenade_amount(1, true)
				return true
			else
				chance = chance * increase
			end
		end
		return false
	end
	if not on_ammo_pickup(player_unit) then
		local co = coroutine.running()
		player_manager:register_message(Message.OnAmmoPickup, co, on_ammo_pickup)
		while not gained_throwable do
			coroutine.yield(co)
		end
		player_manager:unregister_message(Message.OnAmmoPickup, co)
	end
end
