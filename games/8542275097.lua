local rise = shared.rise
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and rise then
		rise:CreateNotification('Rise', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
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

rise.Place = 8768229691
if isfile('rise/games/'..rise.Place..'.lua') then
	loadstring(readfile('rise/games/'..rise.Place..'.lua'), 'skywars')()
else
	if not shared.RiseDeveloper then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/illusionHD-dev/rise/'..readfile('rise/profiles/commit.txt')..'/games/'..rise.Place..'.lua', true)
		end)
		if suc and res ~= '404: Not Found' then
			loadstring(downloadFile('rise/games/'..rise.Place..'.lua'), 'skywars')()
		end
	end
end