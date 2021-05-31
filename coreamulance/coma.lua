ESX = nil
local isDead = true
local firstSpawn = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

function playerDied()
	TriggerServerEvent('salty_death:updatePlayer',true)
	isDead = true
end

function killPlayer()
	SetEntityHealth(GetPlayerPed(-1),0)
	playerDied()
end

function playerAlive()
	TriggerServerEvent('salty_death:updatePlayer',false)
	isDead = false
end

AddEventHandler('baseevents:onPlayerDied', function(killerType, coords)
	playerDied()
end)

AddEventHandler('baseevents:onPlayerKilled', function(killerId, data)
	playerDied()
end)

AddEventHandler("playerSpawned", function()
	if firstSpawn then
		ESX.TriggerServerCallback('salty_death:isDead', function(isDeadDB)
			if isDeadDB then
				killPlayer()
			end
		end)
		firstSpawn = false
	end
end)

function DrawAdvancedText(x,y ,w,h,sc, text, r,g,b,a,font,jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
	N_0x4e096588b13ffeca(jus)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
	DrawText(x - 0.1+w, y - 0.02+h)
end

function IsDead()
	local playerPed = GetPlayerPed(-1)
	if isInDead then
	else
	
	end
	isInDead = not isInDead
	TriggerServerEvent('dead:start', isInDead)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		if IsControlJustPressed(1, 38) and IsEntityDead(GetPlayerPed(-1)) then
		    local plyPos = GetEntityCoords(GetPlayerPed(-1), true)
			local text = '~p~L\'individu compose le 117'  
            TriggerServerEvent('3dme:shareDisplay', text) 
            ESX.ShowNotification('Vous avez appelé un EMS')
			TriggerServerEvent("call:makeCall", "ems", {x=plyPos.x,y=plyPos.y,z=plyPos.z}, "~r~Appel COMA", GetPlayerServerId(player))
		end
    end
end)

local secondsRemaining = 300

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		if IsControlJustPressed(1, 246) and secondsRemaining < 1 then
	        NetworkResurrectLocalPlayer(321.3976, -584.0179, 43.2840, true, true, false)
			SetEntityHealth(GetPlayerPed(-1), 100)
			RemoveLoadingPrompt()
			SetTimecycleModifier("")
			SetPedComponentVariation(GetPlayerPed(-1), 4, 56, 0, 2)
	        SetPedComponentVariation(GetPlayerPed(-1), 6, 16, 10, 2)
	        SetPedComponentVariation(GetPlayerPed(-1), 11, 114, 0, 2)
	        SetPedComponentVariation(GetPlayerPed(-1), 3, 14, 0, 2)
	        SetPedComponentVariation(GetPlayerPed(-1), 8, 15, 0, 2)
			RemoveAllPedWeapons(GetPlayerPed(-1),true)
			ESX.ShowNotification('~r~Coma :~s~\nVous avez réaparu à l\'hopital de Los Santos.')
		end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		if IsEntityDead(GetPlayerPed(-1))then
			ESX.ShowNotification('~r~Coma :~s~\nVoulez-vous contacter une amabulance !')
			ESX.ShowNotification('Appeler: ~g~E~s~ ou ~r~Y')	
			SetTimecycleModifier("Drunk")
	        if secondsRemaining > 1 then 
			DrawAdvancedText(1.01, 0.550, 0.002, 0.4, 0.500, "TEMPS RESTANT : ".. secondsRemaining .. " secondes", 255, 255, 255, 255, 4, 0)
			DrawRect(0.912, 0.946, 0.135, 0.034, 0, 0, 0, 150)
	        end
		end
    end
end)

function startAttitude(lib, anim)
    ESX.Streaming.RequestAnimSet(lib, function()
        SetPedMovementClipset(PlayerPedId(), anim, true)
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if secondsRemaining > 0 and IsEntityDead(GetPlayerPed(-1)) then 
            secondsRemaining = secondsRemaining -1
        end
    end
end)
