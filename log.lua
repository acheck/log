--[[

Copyright © 2015 Mihail Zuev <z.m.c@list.ru>. 
Author: Mihail Zuev <z.m.c@list.ru>.
 
All rights reserved.
 
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the <organization> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
                                                                                
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

--]]

local colors = {
	'\27[0m', -- No color, default color by current terminal
	'\27[36m',-- Blue
	'\27[32m',-- Green
	'\27[33m',-- Yellow
	'\27[31m',-- Red
	'\27[35m' -- Pink
}

--The Log object itself
local log = setmetatable({
	color = true, -- Indicates that we will use color output in the terminal
	file = nil, -- Path to log file
	level = 'trace', -- Default log level
	levels = {'trace','debug','info','warn','error','fatal'}
},{
	__index = function(t,k)
		-- Checking if we has approrpriate log level
		if t.levels[k] then
			-- Checking 'log' function
			if type(t.logger) == 'function' then
				-- Current level
				local level
				-- Local copy of 'log' function
				local logger = t.logger

				if type(k) == 'number' then
					level = k
				elseif type(k) == 'string' then
					level = t.levels[k]
				end

				-- A closure that allows us to set the current level as an environment variable
				return function(...)
					-- Set the current level as an environment variable and run it
					setfenv(logger,setmetatable({level = level},{__index = _G}))(...)
				end
			end
		end

		return nil
	end,
	-- Allow call 'log' function without specifying the log level
	__call = function(t,...)
		if type(t[t.level]) == 'function' then
			return t[t.level](...)
		else
			return t.logger(...)
		end
	end
})

-- Modify 'levels' array in to the hash
-- That will allow us to use the number when setting the logging level
for k,v in ipairs(log.levels) do
	if not log.levels[v] then
		log.levels[v] = k
	end
end

-- Main function that will proccess log message
log.logger = function(...)
	local level = level -- From Environment
	local ident = log.ident and log.ident or debug.getinfo(3, "S").source

	-- Not allowed levels less than the specified
	if level < (type(log.level) == 'string' and log.levels[string.lower(log.level)] or tonumber(log.level)) then
		return
	end

	-- Output to console
	print(
		string.format("%s%s [%s] %s:%s",
			log.color
				and colors[level]
				or "",
			os.date("%b %d %H:%M:%S"),
			string.upper(log.levels[level]),
			string.match(ident,"^.-/-([^%/]+)$"),
			log.color
				and "\27[0m"
				or ""
		),
		...
	)

	-- If set then prepare log.file property
	if log.file then
		if not log.fd then -- log.file set but not openned
			log.fd = io.open(log.file,"a")

			local stat, err = pcall(log.fd.setvbuf,log.fd,"no")

			if not stat then
				print(err)
			end
		end

		-- Output to log file
		if io.type(log.fd) == 'file' then -- log.file is set and it's opened
			log.fd:write(
				string.format("%s [%s] %s: ",
					os.date("%b %d %H:%M:%S"),
					string.upper(log.levels[level]),
					string.match(ident,"^.-/-([^%/]+)$")
				),
				string.format(
					string.gsub(
						string.format("%s%s",
							string.rep("%s\t",select('#',...)),
							"\n"
						)
						,'\t\n$','\n'
					)
					,...
				)
			)
		end
	end
end

-- Close the file descriptor associated with the log file
log.close = function()
	if io.type(log.fd) == 'file' then -- log.file is set and it's opened
		local stat, err = pcall(log.fd['close'],log.fd) -- Just in case

		if not stat then -- Just print error message and move on
			print(err)
		end
	end

	log.fd = nil
end

return log
