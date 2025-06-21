local ExeENV = getfenv(1)

local function PatchFunctions()
	local Patches = {
		[pcall] = function(OldFunc, Func, ...)
			local Response = { OldFunc(Func, ...) }
			local Success, Error = Response[1], Response[2]

			if not Success and iscclosure(Func) then
				local NewError = Error
					:gsub(':%d+: ', '')
					:gsub(', got %a+', '')
					:gsub('invalid argument', 'missing argument')
				Response[2] = NewError
			end

			return unpack(Response, 1, table.maxn(Response))
		end,
		[getfenv] = function(OldFunc, Level, ...)
			local Response = { OldFunc(Level, ...) }
			local ENV = Response[1]

			if not checkcaller() and ENV == ExeENV then
				return OldFunc(99999, ...)
			end

			return unpack(Response, 1, table.maxn(Response))
		end,
	}

	for Func, CallBack in pairs(Patches) do
		local OldFunc = clonefunction(Func)
		hookfunction(
			Func,
			newcclosure(function(...)
				return CallBack(OldFunc, ...)
			end)
		)
	end

	for _, v in pairs(game:GetDescendants()) do
		if
			v:IsA('RemoteFunction')
			and not (
				v.Name:find('Get')
				or v.Name:find('Function')
				or v.Name:find('WhisperChat')
				or v.Name:find('Edit')
				or v.Name:find('Teleport')
			)
		then
			v.OnClientInvoke = function(...) end
		end
	end

		firesignal(game:GetService("ReplicatedStorage").RemoteEvents.NotificationEvent.OnClientEvent, 'VXRSA successfully loaded.')
end
PatchFunctions()
