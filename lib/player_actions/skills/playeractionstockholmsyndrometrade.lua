PlayerAction.StockholmSyndromeTrade = {}
PlayerAction.StockholmSyndromeTrade.Priority = 1
function PlayerAction.StockholmSyndromeTrade.Function(pos, peer_id)
	managers.hint:show_hint("skill_stockholm_syndrome_trade")
	local controller = managers.controller:create_controller("player_custody", nil, false)
	controller:enable()
	local quit = false
	local previous_state = game_state_machine:current_state_name()
	local co = coroutine.running()
	while not quit do
		if controller:get_input_pressed("jump") then
			if Network:is_server() then
				managers.player:init_auto_respawn_callback(pos, peer_id, true)
				managers.player:change_stockholm_syndrome_count(-1)
			else
				managers.network:session():send_to_host("auto_respawn_player", pos, peer_id)
				managers.network:session():send_to_host("sync_set_super_syndrome", peer_id, false)
			end
			quit = true
		end
		local current_state = game_state_machine:current_state_name()
		if previous_state == "ingame_waiting_for_respawn" and current_state ~= previous_state then
			quit = true
		end
		previous_state = current_state
		coroutine.yield(co)
	end
	controller:destroy()
	controller = nil
end
StockholmSyndromeTradeAction = StockholmSyndromeTradeAction or class()
function StockholmSyndromeTradeAction:init(pos, peer_id)
	self._pos = pos
	self._peer_id = peer_id
end
function StockholmSyndromeTradeAction:on_enter()
	self._controller = managers.controller:create_controller("player_custody", nil, false)
	self._controller:enable()
	self._previous_state = game_state_machine:current_state_name()
	self._quit = false
	self._request_hostage_trade = false
	managers.player:register_message(Message.CanTradeHostage, "request_stockholm_syndrome", callback(self, self, "_request_stockholm_syndrome_results"))
	managers.hint:show_hint("stockholm_syndrome_hint")
end
function StockholmSyndromeTradeAction:on_exit()
	managers.player:unregister_message(Message.CanTradeHostage, "request_stockholm_syndrome")
	self._controller:destroy()
	self._controller = nil
	self._pos = nil
	self._peer_id = nil
	self._previous_state = nil
	self._quit = nil
	self._request_hostage_trade = nil
end
function StockholmSyndromeTradeAction:update(t, dt)
	if managers.groupai:state():hostage_count() <= 0 then
		self._quit = true
	elseif not self._request_hostage_trade and self._controller:get_input_pressed("jump") then
		local pm = managers.player
		if Network:is_server() then
			if not managers.trade:trade_in_progress() then
				pm:init_auto_respawn_callback(self._pos, self._peer_id, false)
				managers.player:change_stockholm_syndrome_count(-1)
				self._quit = true
			end
		else
			managers.network:session():send_to_host("request_stockholm_syndrome", self._pos, self._peer_id)
		end
		self._request_hostage_trade = true
	end
	local current_state = game_state_machine:current_state_name()
	if self._previous_state == "ingame_waiting_for_respawn" and current_state ~= self._previous_state then
		self._quit = true
	end
	self._previous_state = current_state
	return self._quit
end
function StockholmSyndromeTradeAction:_request_stockholm_syndrome_results(can_trade)
	if can_trade then
		self._quit = true
		managers.player:change_stockholm_syndrome_count(-1)
	else
		self._request_hostage_trade = false
	end
end
