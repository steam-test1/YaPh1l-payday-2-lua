PlayerStatsGui = PlayerStatsGui or class()
local system_font = "core/fonts/system_font"
local small_font = tweak_data.menu.pd2_small_font
local medium_font = tweak_data.menu.pd2_medium_font
local large_font = tweak_data.menu.pd2_large_font
local massive_font = tweak_data.menu.pd2_massive_font
local system_font_size = 12
local small_font_size = tweak_data.menu.pd2_small_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local ICON_TEXTURE_WIDTH = 64
local ICON_TEXTURE_HEIGHT = 64
local ICON_TEXT_WIDTH = ICON_TEXTURE_WIDTH + 26 + 40
local ICON_TEXT_HEIGHT = system_font_size * 2
local ICON_PADDING_WIDTH = 16
local ICON_PADDING_HEIGHT = 16
local ICON_WIDTH = math.max(ICON_TEXTURE_WIDTH, ICON_TEXT_WIDTH) + ICON_PADDING_WIDTH * 2
local ICON_HEIGHT = ICON_TEXTURE_HEIGHT + ICON_TEXT_HEIGHT + ICON_PADDING_HEIGHT * 2
local make_fine_text = function(text)
	local x, y, w, h = text:text_rect()
	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end
PlayerStatsGui.WINDOWS = {}
PlayerStatsGui.WINDOWS.desktop = {
	x = nil,
	y = nil,
	w = nil,
	h = nil,
	bg_texture = "desktop_bg",
	header_left_text = "FedNet 2.1.0.0b",
	header_right_text = "You are currently logged in as Com_G_Hauk",
	icons = {
		["1_1"] = {
			text = "@menu_stats_player_folder;",
			open_window = "main_suspect",
			texture = "icon_char",
			over_texture = "icon_char_over"
		},
		["2_1"] = {
			text = "Modus Operandi [Loadout]",
			texture = "icon_folder",
			over_texture = "icon_folder_over"
		},
		["1_2"] = {
			text = "Heist Database",
			texture = "icon_folder",
			over_texture = "icon_folder_over"
		},
		["2_2"] = {
			text = "",
			texture = "icon_folder",
			over_texture = "icon_folder_over"
		},
		["1_3"] = {
			text = "Firearms Database",
			texture = "icon_weapons",
			over_texture = "icon_weapons_over"
		},
		["2_4"] = {
			text = "Agency Assets [UPDATED]",
			texture = "icon_folder",
			over_texture = "icon_folder_over"
		},
		["2_5"] = {
			text = "Internal memos",
			texture = "icon_folder",
			over_texture = "icon_folder_over"
		}
	}
}
PlayerStatsGui.WINDOWS.main_suspect = {
	x = 225,
	y = 50,
	w = 800,
	h = 600,
	bg_texture = nil,
	window_footer = "window_footer",
	header_left_text = "FedNet | Root > @menu_stats_player_folder;",
	header_right_text = "",
	add_close_btn = true,
	title_text = "@menu_stats_player_title;",
	content = {
		{
			type = "text",
			text = "BLOCK 1",
			align = "center",
			font = medium_font,
			font_size = medium_font_size
		},
		{type = "divider", h = 10},
		{
			type = "text_value",
			text = "Player Time",
			value = "_get_player_time"
		},
		{
			type = "text_value",
			text = "Player Level",
			value = "_get_player_level"
		},
		{
			type = "text_value",
			text = "Player Rank",
			value = "_get_player_rank"
		},
		{type = "divider", h = 10},
		{
			type = "pie_chart",
			size = 150,
			data = "_get_heists_pie_chart_data"
		},
		{type = "divider", h = 10},
		{
			type = "image",
			texture = "icon_weapons_over",
			text = "Some weapon$NL;100%$NL;145 / 544",
			w = 100,
			h = 100
		},
		{type = "divider", h = 10},
		{type = "divider", h = 10},
		{
			type = "text",
			text = "BLOCK 1",
			align = "center",
			font = medium_font,
			font_size = medium_font_size
		},
		{type = "divider", h = 10},
		{
			type = "text_value",
			text = "Player Time",
			value = "_get_player_time"
		},
		{
			type = "text_value",
			text = "Player Level",
			value = "_get_player_level"
		},
		{
			type = "text_value",
			text = "Player Rank",
			value = "_get_player_rank"
		},
		{type = "divider", h = 10},
		{
			type = "pie_chart",
			size = 150,
			data = "_get_heists_pie_chart_data"
		},
		{type = "divider", h = 10},
		{
			type = "image",
			texture = "icon_weapons_over",
			text = "Some weapon$NL;100%$NL;145 / 544",
			w = 100,
			h = 100
		}
	}
}
function PlayerStatsGui:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._node = node
	self._panel = self._ws:panel():panel()
	self._fullscreen_panel = self._fullscreen_ws:panel():panel()
	self._window_stack = {}
	local prefix = "guis/dlcs/gordon/textures/pd2/stats/"
	self._textures = {
		desktop_bg = {
			texture = prefix .. "fbifiles_bg",
			texture_rect = {
				0,
				0,
				1706,
				1024
			},
			index = nil,
			ready = false
		},
		icon_char = {
			texture = prefix .. "fbifiles_icon_char",
			index = nil,
			ready = false
		},
		icon_char_over = {
			texture = prefix .. "fbifiles_icon_char_over",
			index = nil,
			ready = false
		},
		icon_folder = {
			texture = prefix .. "fbifiles_icon_folder",
			index = nil,
			ready = false
		},
		icon_folder_over = {
			texture = prefix .. "fbifiles_icon_folder_over",
			index = nil,
			ready = false
		},
		icon_weapons = {
			texture = prefix .. "fbifiles_icon_weapons",
			index = nil,
			ready = false
		},
		icon_weapons_over = {
			texture = prefix .. "fbifiles_icon_weapons_over",
			index = nil,
			ready = false
		},
		window_header_l = {
			texture = prefix .. "fbifiles_window_header_l",
			index = nil,
			ready = false
		},
		window_header_m = {
			texture = prefix .. "fbifiles_window_header_m",
			index = nil,
			ready = false
		},
		window_header_r = {
			texture = prefix .. "fbifiles_window_header_r",
			index = nil,
			ready = false
		},
		window_footer = {
			texture = prefix .. "fbifiles_window_header_m",
			rotation = 0,
			index = nil,
			ready = false
		},
		close_btn = {
			texture = prefix .. "fbifiles_window_header_l",
			index = nil,
			ready = false
		},
		close_btn_over = {
			texture = prefix .. "fbifiles_window_header_r",
			index = nil,
			ready = false
		}
	}
	self._requesting = true
	local texture_loaded_clbk = callback(self, self, "clbk_texture_loaded")
	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready then
			texture_data.index = managers.menu_component:request_texture(texture_data.texture, texture_loaded_clbk)
		end
	end
	self._requesting = false
	self:_chk_load_complete()
end
function PlayerStatsGui:_set_window_icon_position(window, icon, x, y)
	if not type(x) == "number" or not type(y) == "number" then
		return
	end
	if not window.icons then
		return
	end
	if window.icons[y] and window.icons[y][x] then
		return
	end
	local old_x = icon._x
	local old_y = icon._y
	if window.icons[old_y] and window.icons[old_y][old_x] then
		window.icons[old_y][old_x] = nil
		if table.size(window.icons[old_y]) == 0 then
			window.icons[old_y] = nil
		end
	end
	window.icons[y] = window.icons[y] or {}
	window.icons[y][x] = icon
	icon.panel:set_position((x - 1) * ICON_WIDTH, (y - 1) * ICON_HEIGHT)
	icon._x = x
	icon._y = y
end
function PlayerStatsGui:_create_window_icon(window, icon_data, pos)
	if not window.panel or not alive(window.panel) then
		return
	end
	local content_panel = window.panel:child("content_panel")
	if not alive(content_panel) then
		return
	end
	local icon_texture = icon_data.texture and self._textures[icon_data.texture] or self._textures.icon_folder
	local icon_over_texture = icon_data.over_texture and self._textures[icon_data.over_texture] or self._textures.icon_folder_over
	local icon_text = icon_data.text and managers.localization:format_text(icon_data.text) or ""
	local panel = content_panel:panel({
		w = ICON_WIDTH,
		h = ICON_HEIGHT,
		layer = 1
	})
	local icon_bitmap = panel:bitmap({
		name = "icon_bitmap",
		texture = icon_texture.texture,
		texture_rect = icon_texture.texture_rect,
		w = ICON_TEXTURE_WIDTH,
		h = ICON_TEXTURE_HEIGHT,
		layer = 1
	})
	local icon_bitmap_over = panel:bitmap({
		name = "icon_bitmap_over",
		texture = icon_over_texture.texture,
		texture_rect = icon_over_texture.texture_rect,
		w = ICON_TEXTURE_WIDTH,
		h = ICON_TEXTURE_HEIGHT,
		visible = false,
		layer = 1
	})
	local icon_text = panel:text({
		name = "icon_text",
		w = ICON_TEXT_WIDTH,
		h = ICON_TEXT_HEIGHT,
		text = icon_text,
		font = system_font,
		font_size = system_font_size,
		layer = 1,
		align = "center",
		vertical = "top",
		color = tweak_data.screen_colors.text,
		wrap = true,
		word_wrap = true
	})
	local icon_text_over = panel:rect({
		name = "icon_text_over",
		color = Color.white,
		visible = false
	})
	icon_bitmap:set_top(ICON_PADDING_HEIGHT)
	icon_bitmap:set_center_x(panel:w() / 2)
	icon_bitmap_over:set_top(ICON_PADDING_HEIGHT)
	icon_bitmap_over:set_center_x(panel:w() / 2)
	icon_text:set_top(icon_bitmap:bottom())
	icon_text:set_center_x(panel:w() / 2)
	local _, _, tw, th = icon_text:text_rect()
	if tw == 0 or th == 0 then
		icon_text_over:set_size(0, 0)
		icon_text_over:set_alpha(0)
	else
		icon_text_over:set_size(tw + 2, th + 2)
	end
	icon_text_over:set_top(icon_bitmap:bottom() - 1)
	icon_text_over:set_center_x(panel:w() / 2)
	local select_x = math.min(icon_bitmap:left(), icon_text:left())
	local select_y = math.min(icon_bitmap:top(), icon_text:top())
	local select_w = math.max(icon_bitmap:right(), icon_text:right()) - select_x
	local select_h = math.max(icon_bitmap:bottom(), icon_text:bottom()) - select_y
	local select_panel = panel:panel({
		name = "select_panel",
		x = select_x,
		y = select_y,
		w = select_w,
		h = select_h
	})
	local icon = {}
	icon.panel = panel
	icon.open_window = icon_data.open_window
	icon.data = icon_data
	local positions = string.split(pos, "_")
	local x = math.clamp(math.floor(tonumber(positions[1])), 1, window._max_icons_columns)
	local y = math.clamp(math.floor(tonumber(positions[2])), 1, window._max_icons_rows)
	self:_set_window_icon_position(window, icon, x, y)
end
function PlayerStatsGui:close_window()
	if #self._window_stack > 1 then
		local window = table.remove(self._window_stack)
		if window then
			window.panel:parent():remove(window.panel)
		end
	end
end
function PlayerStatsGui:open_window(name)
	local params = self.WINDOWS[name]
	if not params then
		return false
	end
	local window = {}
	local layer = #self._window_stack * 10
	local x = params.x or self._fullscreen_panel:x()
	local y = params.y or self._fullscreen_panel:y()
	local w = math.max(params.w or params.width or self._fullscreen_panel:w(), 1)
	local h = math.max(params.h or params.height or self._fullscreen_panel:h(), 1)
	local panel = self._fullscreen_panel:panel({
		x = x,
		y = y,
		w = w,
		h = h,
		layer = layer
	})
	window.panel = panel
	local bg_texture = params.bg_texture and self._textures[params.bg_texture]
	local window_header_l = params.window_header_l and self._textures[params.window_header_l] or self._textures.window_header_l
	local window_header_m = params.window_header_m and self._textures[params.window_header_m] or self._textures.window_header_m
	local window_header_r = params.window_header_r and self._textures[params.window_header_r] or self._textures.window_header_r
	local window_footer = params.window_footer and self._textures[params.window_footer]
	local close_btn = params.close_btn and self._textures[params.close_btn] or self._textures.close_btn
	local close_btn_over = params.close_btn_over and self._textures[params.close_btn_over] or self._textures.close_btn_over
	local header_left_text = params.header_left_text and managers.localization:format_text(params.header_left_text) or ""
	local header_right_text = params.header_right_text and managers.localization:format_text(params.header_right_text) or ""
	local add_close_btn = params.add_close_btn or false
	local title_text = params.title_text and managers.localization:format_text(params.title_text) or false
	local icons = params.icons
	local content = params.content
	if bg_texture then
		panel:bitmap({
			name = "bg",
			texture = bg_texture.texture,
			texture_rect = bg_texture.texture_rect,
			w = panel:w(),
			h = panel:h(),
			layer = 0
		})
	else
		panel:rect({
			name = "bg",
			color = Color.black,
			alpha = 0.6,
			w = panel:w(),
			h = panel:h(),
			layer = 0
		})
	end
	local header_panel = panel:panel({
		name = "header",
		h = 32,
		layer = 2
	})
	header_panel:bitmap({
		name = "header_l",
		texture = window_header_l.texture,
		texture_rect = window_header_l.texture_rect,
		rotation = window_header_l.rotation,
		w = 32,
		h = 32
	})
	header_panel:bitmap({
		name = "header_m",
		texture = window_header_m.texture,
		texture_rect = window_header_m.texture_rect,
		rotation = window_header_m.rotation,
		w = header_panel:w() - 64,
		h = 32,
		x = 32
	})
	header_panel:bitmap({
		name = "header_r",
		texture = window_header_r.texture,
		texture_rect = window_header_r.texture_rect,
		rotation = window_header_r.rotation,
		x = header_panel:w() - 32,
		w = 32,
		h = 32
	})
	header_panel:text({
		name = "left_text",
		text = header_left_text,
		font = system_font,
		font_size = system_font_size,
		x = 24,
		h = 24,
		layer = 1,
		align = "left",
		vertical = "center",
		color = tweak_data.screen_colors.text
	})
	header_panel:text({
		name = "right_text",
		text = header_right_text,
		font = system_font,
		font_size = system_font_size,
		h = 24,
		w = header_panel:w() - 5,
		layer = 1,
		align = "right",
		vertical = "center",
		color = tweak_data.screen_colors.text
	})
	if add_close_btn then
		local close_btn = panel:bitmap({
			name = "close_btn",
			w = 18,
			h = 18,
			texture = close_btn.texture,
			texture_rect = close_btn.texture_rect,
			layer = 4,
			color = Color.black,
			alpha = 0.8
		})
		local close_btn_over = panel:bitmap({
			name = "close_btn_over",
			w = 18,
			h = 18,
			texture = close_btn_over.texture,
			texture_rect = close_btn_over.texture_rect_over,
			layer = 4,
			color = Color.white,
			alpha = 0.8,
			visible = false
		})
		close_btn:set_righttop(panel:w() - 3, 3)
		close_btn_over:set_righttop(panel:w() - 3, 3)
	end
	local header_h = 24
	local footer_h = 0
	if window_footer then
		local footer = panel:bitmap({
			name = "footer",
			texture = window_footer.texture,
			texture_rect = window_footer.texture_rect,
			rotation = window_footer.rotation,
			w = panel:w(),
			h = 8,
			layer = 2
		})
		footer:set_leftbottom(0, panel:h())
		footer_h = 8
	end
	if title_text then
		local title_panel = panel:panel({
			name = "title",
			w = panel:w(),
			h = large_font_size + 28,
			layer = 1,
			y = 24
		})
		title_panel:text({
			text = title_text,
			font = large_font,
			font_size = large_font_size,
			y = 8,
			h = title_panel:h() - 8,
			align = "center",
			vertical = "center",
			color = tweak_data.screen_colors.text,
			layer = 1
		})
		title_panel:rect({
			color = tweak_data.screen_colors.ghost_color:with_alpha(0.7),
			layer = 0
		})
		header_h = title_panel:bottom()
	end
	local w = math.min(panel:w(), self._panel:w())
	local h = math.min(panel:h() - header_h - footer_h, self._panel:h() - header_h)
	local content_panel = panel:panel({
		name = "content_panel",
		w = w,
		h = h,
		layer = 1
	})
	content_panel:set_center(panel:w() / 2, (panel:h() - header_h - footer_h) / 2 + header_h)
	content_panel:set_position(math.round(content_panel:x()), math.round(content_panel:y()))
	local num_columns = math.floor(content_panel:w() / ICON_WIDTH)
	local num_rows = math.floor(content_panel:h() / ICON_HEIGHT)
	window._max_icons_columns = num_columns
	window._max_icons_rows = num_rows
	if icons and 0 < table.size(icons) then
		window.icons = {}
		for pos, icon_data in pairs(icons) do
			self:_create_window_icon(window, icon_data, pos)
		end
	end
	local scroll_panel = content_panel:panel({
		name = "scroll_panel",
		layer = 1
	})
	if content then
		local panel, type
		local x = 10
		local y = 10
		window.content = {}
		for _, data in ipairs(content) do
			type = data.type
			if not data.unlock or callback(self, self, data.unlock)() then
				panel = scroll_panel:panel({
					name = _,
					x = x,
					y = y,
					w = content_panel:w() - 20,
					h = 0
				})
				if type == "text_value" then
					local text = panel:text({
						name = "text",
						text = (data.text and managers.localization:format_text(data.text) or "") .. ": ",
						font = data.font or small_font,
						font_size = data.font_size or small_font_size,
						color = data.color or tweak_data.screen_colors.text
					})
					local value = panel:text({
						name = "value",
						text = callback(self, self, data.value)(),
						font = data.font or small_font,
						font_size = data.font_size or small_font_size,
						color = data.color or tweak_data.screen_colors.text
					})
					make_fine_text(text)
					make_fine_text(value)
					text:set_position(0, 0)
					value:set_position(text:right(), 0)
					panel:set_size(math.max(text:right(), value:right()), math.max(text:bottom(), value:bottom()))
				elseif type == "image" then
					local texture = data.texture and self._textures[data.texture] or self._textures.icon_folder
					local image = panel:bitmap({
						name = "image",
						w = data.width or data.w,
						h = data.height or data.h,
						texture = texture.texture,
						texture_rect = texture.texture_rect,
						color = data.color or Color.white,
						alpha = data.alpha or 1
					})
					local text = panel:text({
						name = "text",
						text = data.text and managers.localization:format_text(data.text) or "",
						font = data.font or small_font,
						font_size = data.font_size or small_font_size,
						color = data.color or tweak_data.screen_colors.text
					})
					make_fine_text(text)
					text:set_left(image:right() + 5)
					text:set_center_y(image:center_y())
					panel:set_size(math.max(image:right(), text:right()), math.max(image:bottom(), text:bottom()))
				elseif type == "pie_chart" then
					panel:set_h(data.size or 50)
					local pie_chart_data = callback(self, self, data.data)()
					local pie_chart = managers.menu_component:create_pie_chart(panel, pie_chart_data, {
						w = data.width or data.w,
						data.height or data.h
					})
				elseif type == "text" then
					local text = panel:text({
						name = "text",
						text = data.text and managers.localization:format_text(data.text) or "",
						align = data.align or "left",
						font = data.font or small_font,
						font_size = data.font_size or small_font_size,
						color = data.color or tweak_data.screen_colors.text
					})
					local _, _, _, h = text:text_rect()
					text:set_h(h)
					panel:set_size(text:right(), text:bottom())
				elseif type == "divider" then
					panel:set_h(data.height or data.h or 0)
				end
				y = panel:bottom()
			end
			table.insert(window.content, {panel = panel, type = type})
		end
		scroll_panel:set_h(y)
	end
	self._window_stack[#self._window_stack + 1] = window
	self:update_content_visibility()
end
function PlayerStatsGui:_create_start_window()
	self:open_window("desktop")
end
function PlayerStatsGui:clbk_texture_loaded(tex_name)
	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready and tex_name == Idstring(texture_data.texture) then
			texture_data.ready = true
		end
	end
	self:_chk_load_complete()
end
function PlayerStatsGui:_chk_load_complete()
	if self._requesting then
		return
	end
	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready then
			return
		end
	end
	self:_create_start_window()
end
function PlayerStatsGui:_get_icon_from_pos(x, y)
	local active_window = self._window_stack[#self._window_stack]
	if active_window and active_window.icons and active_window.panel and alive(active_window.panel) then
		local content_panel = active_window.panel:child("content_panel")
		local pos_x = math.ceil((x - content_panel:x()) / ICON_WIDTH)
		local pos_y = math.ceil((y - content_panel:y()) / ICON_HEIGHT)
		if pos_x > 0 and pos_x <= active_window._max_icons_columns and pos_y > 0 and pos_y <= active_window._max_icons_rows then
			return active_window.icons[pos_y] and active_window.icons[pos_y][pos_x]
		end
	end
end
function PlayerStatsGui:mouse_released(button, x, y)
	if self._icon_pressed and self._icon_pressed.open_window then
		local x, y = managers.mouse_pointer:modified_fullscreen_16_9_mouse_pos()
		local icon = self:_get_icon_from_pos(x, y)
		if icon == self._icon_pressed then
			self:open_window(self._icon_pressed.open_window)
		end
	end
	self._icon_pressed = nil
end
function PlayerStatsGui:mouse_pressed(button, x, y)
	local x, y = managers.mouse_pointer:modified_fullscreen_16_9_mouse_pos()
	local icon = self:_get_icon_from_pos(x, y)
	if icon and icon.over then
		self._icon_pressed = icon
	else
		self._icon_pressed = nil
		local active_window = self._window_stack[#self._window_stack]
		local close_btn = active_window.panel:child("close_btn")
		local close_btn_over = active_window.panel:child("close_btn_over")
		if alive(close_btn) and close_btn:inside(x, y) then
			self:close_window()
		end
	end
end
function PlayerStatsGui:mouse_moved(o, x, y)
	local used = false
	local pointer = "arrow"
	local active_window = self._window_stack[#self._window_stack]
	if not active_window or not alive(active_window.panel) then
		return used, pointer
	end
	local x, y = managers.mouse_pointer:modified_fullscreen_16_9_mouse_pos()
	local icon = self:_get_icon_from_pos(x, y)
	if icon and icon.panel:child("select_panel"):inside(x, y) then
		icon.panel:set_debug(true)
		if not icon.over then
			icon.over = true
			icon.panel:child("icon_bitmap"):hide()
			icon.panel:child("icon_bitmap_over"):show()
			icon.panel:child("icon_text"):set_color(Color.black)
			icon.panel:child("icon_text_over"):show()
			managers.menu_component:post_event("highlight")
			if self._selected_icon then
				self._selected_icon.over = false
				self._selected_icon.panel:child("icon_bitmap"):show()
				self._selected_icon.panel:child("icon_bitmap_over"):hide()
				self._selected_icon.panel:child("icon_text"):set_color(Color.white)
				self._selected_icon.panel:child("icon_text_over"):hide()
			end
			self._selected_icon = icon
		end
		used = true
		pointer = "link"
	elseif self._selected_icon and self._selected_icon.over then
		self._selected_icon.over = false
		self._selected_icon.panel:child("icon_bitmap"):show()
		self._selected_icon.panel:child("icon_bitmap_over"):hide()
		self._selected_icon.panel:child("icon_text"):set_color(Color.white)
		self._selected_icon.panel:child("icon_text_over"):hide()
		self._selected_icon = nil
	end
	if not used then
		local close_btn = active_window.panel:child("close_btn")
		local close_btn_over = active_window.panel:child("close_btn_over")
		if alive(close_btn) and alive(close_btn_over) then
			local inside = close_btn:inside(x, y)
			if inside then
				if close_btn:visible() then
					close_btn:hide()
					close_btn_over:show()
				end
				used = true
				pointer = "link"
			elseif close_btn_over:visible() then
				close_btn:show()
				close_btn_over:hide()
			end
		end
	end
	return used, pointer
end
function PlayerStatsGui:back_callback()
	local block_back = #self._window_stack > 1 and true or false
	if block_back then
		self:close_window()
	end
	return block_back
end
function PlayerStatsGui:input_focus()
end
function PlayerStatsGui:update_content_visibility()
	local active_window = self._window_stack[#self._window_stack]
	if active_window and active_window.content and alive(active_window.panel) then
		local content_panel = active_window.panel:child("content_panel")
		local scroll_panel = content_panel:child("scroll_panel")
		for _, content in ipairs(active_window.content) do
			if content.type == "pie_chart" then
				content.panel:set_visible(content.panel:top() + scroll_panel:top() >= 0 and content.panel:bottom() + scroll_panel:top() <= content_panel:h())
			end
		end
	end
end
function PlayerStatsGui:close()
	for tex_id, texture_data in pairs(self._textures) do
		if texture_data.index then
			managers.menu_component:unretrieve_texture(texture_data.texture, texture_data.index)
			texture_data.ready = false
		end
	end
	if alive(self._panel) then
		self._ws:panel():remove(self._panel)
		self._panel = nil
	end
	if alive(self._fullscreen_panel) then
		self._fullscreen_ws:panel():remove(self._fullscreen_panel)
		self._fullscreen_panel = nil
	end
end
function PlayerStatsGui:_get_player_time()
	return "_get_player_time"
end
function PlayerStatsGui:_get_player_level()
	local player_level = managers.experience:current_level()
	return tostring(player_level)
end
function PlayerStatsGui:_get_player_rank()
	local player_rank = managers.experience:current_rank()
	return managers.experience:rank_string(player_rank)
end
function PlayerStatsGui:_get_heists_pie_chart_data()
	local data = {}
	for i = 1, 4 do
		table.insert(data, {
			name = "NAME" .. tostring(i),
			value = i * 2
		})
	end
	return data
end
