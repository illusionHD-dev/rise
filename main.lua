repeat task.wait() until game:IsLoaded()
if shared.rise then shared.rise:Uninject() end

local rise
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and rise then
		rise:CreateNotification('Rise', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/illusionHD-dev/rise/'..readfile('rise/profiles/commit.txt')..'/'..select(1, path:gsub('rise/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after rise updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	rise.Init = nil
	rise:Load()
	task.spawn(function()
		repeat
			rise:Save()
			task.wait(10)
		until not rise.Loaded
	end)

	local teleportedServers
	rise:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.RiseIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.risereload = true
				if shared.RiseDeveloper then
					loadstring(readfile('rise/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/illusionHD-dev/rise/'..readfile('rise/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
			if shared.RiseDeveloper then
				teleportScript = 'shared.RiseDeveloper = true\n'..teleportScript
			end
			if shared.RiseCustomProfile then
				teleportScript = 'shared.RiseCustomProfile = "'..shared.RiseCustomProfile..'"\n'..teleportScript
			end
			rise:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.risereload then
		if not rise.Categories then return end
		if rise.Settings.GUI.Options['GUI bind indicator'].Enabled then
			rise:CreateNotification('Finished Loading', rise.RiseButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(rise.GUIBind.Keys, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('rise/profiles/gui.txt') then
	writefile('rise/profiles/gui.txt', 'new')
end
local gui = 'new'--readfile('rise/profiles/gui.txt')

if not isfolder('rise/assets/'..gui) then
	makefolder('rise/assets/'..gui)
end
rise = loadstring(downloadFile('rise/guis/'..gui..'.lua'), 'gui')()
shared.rise = rise

if not shared.RiseIndependent then
	loadstring(downloadFile('rise/games/universal.lua'), 'universal')()
	if isfile('rise/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('rise/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
	else
		if not shared.RiseDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/illusionHD-dev/rise/'..readfile('rise/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('rise/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
			end
		end
	end
	finishLoading()
else
	rise.Init = finishLoading
	return rise
end