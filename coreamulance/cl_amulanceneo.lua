ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
	  TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	  Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job

	Citizen.Wait(5000)

end)

function OpenBillingMenu()

	ESX.UI.Menu.Open(
	  'dialog', GetCurrentResourceName(), 'billing',
	  {
		title = "Facture"
	  },
	  function(data, menu)
  
		local amount = tonumber(data.value)
		local player, distance = ESX.Game.GetClosestPlayer()
  
		if player ~= -1 and distance <= 3.0 then
  
		  menu.close()
		  if amount == nil then
			  ESX.ShowNotification("~r~Facture\n~w~Montant invalide")
		  else
			  TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_police', _U('billing'), amount)
			  Citizen.Wait(100)
			  ESX.ShowNotification("~g~Facture\n~w~Vous avez bien envoyer une facture")
		  end
  
		else
		ESX.ShowNotification("~r~Facture\n~w~Aucun joueur proche")
		end
  
	  end,
	  function(data, menu)
		  menu.close()
	  end
	)
  end

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

function drawnotifcolor(text, color)
    Citizen.InvokeNative(0x92F0DA1E27DB96DC, tonumber(color))
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, true)
end

---------------------------------------------------
local F5ambulance = {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {0, 120, 0}, Blocked = false , Title = "ambulance" },
	Data = { currentMenu = "ACTIONS DISPONIBLES", GetPlayerName() }, 
    Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
			local slide = btn.slidenum
			local btn = btn.name
			local check = btn.unkCheckbox
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
			
			
    if btn == "Informations" then
	     OpenMenu("Informations")
	elseif btn == "Votre service" then 
			functionCheckBox()
	elseif btn == "Annuler l'appel" then
            functionCheckBox2()
		elseif slide == 1 and btn == "Objet" then
			ExecuteCommand('invalido')
		elseif slide == 2 and btn == "Objet" then         
			TriggerEvent('animation2')
		elseif slide == 3 and btn == "Objet" then
			TriggerEvent('animation3')
	elseif btn == "Appeler des renforts" then
	       	local plyPos = GetEntityCoords(GetPlayerPed(-1), true)
			TriggerServerEvent("call:makeCall", "ambulance", {x=plyPos.x,y=plyPos.y,z=plyPos.z}, "Besoin de renforts", GetPlayerServerId(player))
	elseif btn == "Gestion civil" then
	     	 OpenMenu("Gestion civil")
	elseif btn == "Réanimer quelqu'un" then
	       revivePlayer(closestPlayer)
    elseif btn == "Soigner quelqu'un" then 
          Soigner(closestPlayer)
		elseif btn == "Donner une facture" then
			OpenBillingMenu()	
end
end


	},
	
	Menu = { 
		["ACTIONS DISPONIBLES"] = { 
			b = { 
				{name = "Donner une facture", ask = ">", askX = true}, 
			    {name = "Gestion civil", ask = ">", askX = true}, 
				{name = "Objet", slidemax = Objet},			
			    {name = "Appeler des renforts", ask = "", askX = true}, 
				{name = "Informations", ask = ">", askX = true},
			}
        },
		["Gestion civil"] = { 
			b = { 
			    {name = "Réanimer quelqu'un", ask = ">", askX = true},
				{name = "Soigner quelqu'un", ask = ">", askX = true},
			}
        },
		["Informations"] = { 
			b = { 
			    {name = "Votre service", checkbox = false},
				{name = "Annuler l'appel", checkbox = false},
			}
        },
		["Gestion véhicule"] = { 
			b = { 
			    {name = "Crocheter un véhicule", ask = "", askX = true},
			}
        }	
	}
}
function Soigner(closestPlayer)
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
							if closestPlayer == -1 or closestDistance > 1.0 then
								ESX.ShowNotification('~r~Conseil~w~ : rapprochez-vous !')
								else 
										local closestPlayerPed = GetPlayerPed(closestPlayer)
										local health = GetEntityHealth(closestPlayerPed)
		
										if health > 0 then
											local playerPed = PlayerPedId()
		
											TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
											Citizen.Wait(10000)
											ClearPedTasks(playerPed)
		
											TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'big')
											ESX.ShowNotification('~g~Vous avez soigner quelqu\'un.')
										else
											ESX.ShowNotification('~r~Vous êtes dans le inconscient !')
					end
		end
end

RegisterNetEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(healType, quiet)
	local playerPed = PlayerPedId()
	local maxHealth = GetEntityMaxHealth(playerPed)

	if healType == 'small' then
		local health = GetEntityHealth(playerPed)
		local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))
		SetEntityHealth(playerPed, newHealth)
	elseif healType == 'big' then
		SetEntityHealth(playerPed, maxHealth)
	end

	if not quiet then
		ESX.ShowNotification('~g~Vous avez été soigner par quelqu\'un.')
	end
end)

function GetPed(ped)
            PedARevive = ped
        end

function revivePlayer(closestPlayer)
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        if closestPlayer == -1 or closestDistance > 3.0 then
          ESX.ShowNotification('~r~Conseil~w~ : rapprochez-vous !')
        else
		local closestPlayerPed = GetPlayerPed(closestPlayer)
		local health = GetEntityHealth(closestPlayerPed)
		if health == 0 then
		local playerPed = GetPlayerPed(-1)
		Citizen.CreateThread(function()
		ESX.ShowNotification('~g~Vous êtes entrain de réanimer la personne !')
		TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
		Wait(10000)
		ClearPedTasks(playerPed)
		if GetEntityHealth(closestPlayerPed) == 0 then
		TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
		else
		ESX.ShowNotification('~r~Vous êtes dans le coma !')
		end
	   end)
		else
			ESX.ShowNotification('~r~Vous êtes dans le inconscient !')
		end
	end
end

RegisterNetEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	TriggerServerEvent('esx_ambulance:setDeathStatus', false)

	Citizen.CreateThread(function()
		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(50)
		end

		local formattedCoords = {
			x = ESX.Math.Round(coords.x, 1),
			y = ESX.Math.Round(coords.y, 1),
			z = ESX.Math.Round(coords.z, 1)
		}
		
		ESX.SetPlayerData('lastPosition', formattedCoords)
		TriggerServerEvent('esx:updateLastPosition', formattedCoords)
		SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	ClearPedBloodDamage(ped)

	TriggerServerEvent('esx:onPlayerSpawn')
	StopScreenEffect("DeathFailOut")
	ShakeCinematicCam("", 0)
	TriggerEvent('esx:onPlayerSpawn')
	TriggerEvent('playerSpawned')
	RenderScriptCams(0, 0, 0, 0, 0)
		SetTimecycleModifier('')
		DoScreenFadeIn(800)
end)
end)

local Flico = true
function functionCheckBox2()
    Flico = not Flico 
    if not Flico then  
        TriggerEvent("call:cancelCall") 
        drawnotifcolor("Vous avez annulé L\'appel", 6)    
        TriggerServerEvent('esx_service:disableService', 'ambulance') 
    elseif Flico then  
        TriggerServerEvent("player:serviceOn", "ambulance")
        drawnotifcolor("Vous pouvez maintenant accepter à nouveau les appels", 18)   
    end
end

local Flico = true
function functionCheckBox()
    Flico = not Flico
    if not Flico then  
        TriggerServerEvent("player:serviceOn", "ambulance") 
					drawnotifcolor("Vous êtes désormais en service", 18)
    elseif Flico then  
        TriggerServerEvent('esx_service:disableService', 'ambulance')
		drawnotifcolor("Vous êtes désormais plus en service", 6)
		
    end
end
	 


--------------------------------------------------------------------------------------------



local Thomas = {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, Blocked = false , Title = "Outils de secours" },
	Data = { currentMenu = "ACTIONS DISPONIBLES", GetPlayerName() }, 
    Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
			local slide = btn.slidenum
			local btn = btn.name
			local check = btn.unkCheckbox
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
			
				
		if btn == "> Trousse de soin" then
		      TriggerServerEvent('ambulance:trousse')
		  
		  
		  
		  
		  
end
end
 


   




	},
	
	Menu = { 
		["ACTIONS DISPONIBLES"] = { 
			b = { 
				{name = "> Trousse de soin", ask = "~g~0$", askX = true}, 
			}
        }
	}
}


local posthomas = {
	{ x = 308.4185, y = -595.8259, z = 43.2840 }
}

Citizen.CreateThread(function()
    local attente = 150
    while true do
        Wait(attente)

        for k in pairs(posthomas) do

            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, posthomas[k].x, posthomas[k].y, posthomas[k].z)

			if dist <= 2.0 then
				attente = 1
				ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour ~b~interagir avec thomas")
				if IsControlJustPressed(1,38) and PlayerData.job and PlayerData.job.name == 'ambulance' then 
                    CreateMenu(Thomas)
				end
				break
            else
                attente = 150
            end
        end
    end
end)


local Vestaire = { 
	{x = 302.89, y = -597.70, z = 43.29},
}
local shop = {
	{x = 340.13, y = -585.95, z = 28.79},
}
local shop2 = {
	{x = 341.34, y = -583.19, z = 28.79},
}
local garage = {
    {x = 321.27, y = -558.37, z = 28.79},
}

local boss = {
    {x = 327.63, y = -594.67, z = 28.79}
}


	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			if IsControlJustPressed(1,167) and PlayerData.job and PlayerData.job.name == 'ambulance' then
				CreateMenu(F5ambulance)
			end
	
		
			for k in pairs(Vestaire) do
				local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
				local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Vestaire[k].x, Vestaire[k].y, Vestaire[k].z)
				DrawMarker(6, 302.89, -597.70,43.29-0.95, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 100)
				if dist <= 1.2 and PlayerData.job and PlayerData.job.name == 'ambulance' then
					ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour ouvrir votre ~b~casier~s~")
					if IsControlJustPressed(1,38) then 
						CreateMenu(MyMenus)
					end
				end
			end
			for k in pairs(shop) do
	
				local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
				local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, shop[k].x, shop[k].y, shop[k].z)
	
				if dist <= 1.2 and onDuty and PlayerData.job and PlayerData.job.name == 'ambulance' then
					ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour acc der au ~b~Ambulancier~s~")
					if IsControlJustPressed(1,38) then 
						CreateMenu(shopambulanceMenu)
					end
				end
			end
			for k in pairs(shop2) do
	
				local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
				local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, shop2[k].x, shop2[k].y, shop2[k].z)
	
				if dist <= 1.2  then 
					ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour accéder au ~b~Ambulancier~s~")
					if IsControlJustPressed(1,38) then 
						CreateMenu(shop2ambulanceMenu)
					end
				end
			end
			for k in pairs(garage) do
	
				local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
				local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, garage[k].x, garage[k].y, garage[k].z)
	
				if dist <= 1.2 and onDuty and PlayerData.job and PlayerData.job.name == 'ambulance' then
					ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour accéder au ~b~garage~s~")
					if IsControlJustPressed(1,38) then 
						CreateMenu(GarageambulanceMenu)
					end
				end
			end
			for k in pairs(boss) do
	
				local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
				local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, boss[k].x, boss[k].y, boss[k].z)
	
				if dist <= 1.2 and onDuty and PlayerData.job and PlayerData.job.name == 'ambulance' and PlayerData.job.grade_name == 'boss' then
					ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour accéder   l'ordinateur de ~b~l'entreprise~s~")
					if IsControlJustPressed(1,38) then 
						CreateMenu(BossambulanceMenu)
					end
				end
			end
		end
	end)






	local GarageambulanceMenu = {
		Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {232, 36, 82}, Title = "Garage Ambulance" },
		Data = { currentMenu = "Garage Ambulance", "Test" },
		Events = {
			onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
				PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
				local slide = btn.slidenum
				local btn = btn.name
				local check = btn.unkCheckbox
				if btn == "Vehicule Ambulance" then
					SetVehicleWindowTint(vehicle, 5)
					ESX.ShowNotification('Vous avez sorti un vehicule de ambulance')
					Citizen.Wait(1)
					spawnCar("ambulance")
					CloseMenu(force)
				elseif btn == "Vehicule Dodge Ambulance" then
						SetVehicleWindowTint(vehicle, 5)
						ESX.ShowNotification('Vous avez sorti un vehicule de ambulance')
						Citizen.Wait(1)
						spawnCar("dodgeems")
						CloseMenu(force)
				elseif btn == "Garage personnel" then 
					ESX.ShowNotification('~r~ERROR 401: Indisponible, veuillez contactez un d veloppeur')
			end
		end,
	},
		Menu = {
			["Garage Ambulance"] = {
				b = {
	
					{name = "Vehicule Ambulance", ask = ">", askX = true},
					{name = "Vehicule Dodge Ambulance", ask = ">", askX = true}
				}
			}
		}
	}

















entrepriseambulance = {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {2, 99, 3}, Title = "ambulance" },
	Data = { currentMenu = "ACTIONS DISPONIBLES", GetPlayerName() }, 
    Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
			PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
			local slide = btn.slidenum
			local btn = btn.name
			local check = btn.unkCheckbox
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
			
			
		if btn == "Informations" then                                      
            OpenMenu("Informations")
        elseif btn == "Gestion" then                                      
            OpenMenu("Gestion")	
         elseif btn == "Liste des rangs" then                                      
            OpenMenu("Liste des rangs")
end
            if btn == "Recruter quelqu'un" and PlayerData.job.grade_name == 'patron' then
                if closestPlayer == -1 or closestDistance > 3.0 then
                ESX.ShowNotification('~r~Aucun joueur à coté de vous !')
                else
                TriggerServerEvent('ambulance:bossrecrute', GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name, 0)
                end
            elseif btn == "Virer quelqu'un" and PlayerData.job.grade_name == 'patron' then
                if closestPlayer == -1 or closestDistance > 3.0 then
                ESX.ShowNotification('~r~Aucun joueur à coté de vous !')
                else
                TriggerServerEvent('ambulance:bossvirer', GetPlayerServerId(closestPlayer))
                end
            elseif btn == "Promouvoire quelqu'un" and PlayerData.job.grade_name == 'patron' then
                 if closestPlayer == -1 or closestDistance > 3.0 then
                 ESX.ShowNotification('~r~Aucun joueur à coté de vous !')
                 else
                 TriggerServerEvent('ambulance:bosspromo', GetPlayerServerId(closestPlayer))
                 end
            elseif btn == "Destituer quelqu'un" and PlayerData.job.grade_name == 'patron' then
                  if closestPlayer == -1 or closestDistance > 3.0 then
                  ESX.ShowNotification('~r~Aucun joueur à coté de vous !')
                  else 
                  TriggerServerEvent('ambulance:bossdes', GetPlayerServerId(closestPlayer))
                  end
            elseif btn == "Compte entreprise" then
                ESX.PlayerData = ESX.GetPlayerData()
                ESX.ShowNotification('~g~Votre compte est de ~s~'..ESX.PlayerData.money.."$")
			elseif btn == "Liste des membres" then
			       entrepriseambulance.Menu["Liste des membres"].b = {}
                   ESX.TriggerServerCallback('getmembreambulance', function(resultambulance)
				   for k, v in pairs(resultambulance) do
				   if v.job == "ambulance" then
				   table.insert(entrepriseambulance.Menu["Liste des membres"].b, {name = v.name})
				   
				 end 
                 end
                 OpenMenu("Liste des membres")				 
				 end)	
            				
      
 


    
end
end

	},
	
	Menu = { 
		["ACTIONS DISPONIBLES"] = { 
			b = { 
                {name = "Informations", ask = ">", askX = true}, 
                {name = "Gestion", ask = ">", askX = true}, 
                {name = "Liste des rangs", ask = ">", askX = true}, 
				{name = "Liste des membres", ask = ">", askX = true}, 
			}
        },
		["Liste des membres"] = { 
			b = {}
        },
		["Informations"] = { 
			b = { 
                {name = "Nom", ask = "ambulance", askX = true}, 
                {name = "Devise", ask = "-", askX = true},
			}
        },
		["Gestion"] = { 
			b = { 
                {name = "Recruter quelqu'un", ask = "", askX = true}, 
                {name = "Virer quelqu'un", ask = "", askX = true},
				{name = "Promouvoire quelqu'un", ask = "", askX = true},
				{name = "Destituer quelqu'un", ask = "", askX = true},
			}
        },
		["Liste des rangs"] = { 
			b = { 
                {name = "PATRON", ask = "-", askX = true}, 
                {name = "EMPLOYE", ask = "-", askX = true},
				{name = "RECRUE", ask = "-", askX = true},
			}
        }
	}
}

Citizen.CreateThread(function()

    TriggerEvent('chat:addSuggestion', '/ambulance', 'Menu de gestion de votre entreprise', {})

end)

RegisterCommand("ambulance", function()
     if PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' then
	 CreateMenu(entrepriseambulance)
	 end
end)

