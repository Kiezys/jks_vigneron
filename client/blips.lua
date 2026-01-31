local blips = {}
local universalBlips = {}

-- Fonction pour créer les blips universels (non bloqués par le métier)
function createUniversalBlips()
    for blipName, blipConfig in pairs(Config.UniversalBlips) do
        if not universalBlips[blipName] then
            local blip = AddBlipForCoord(blipConfig.coords.x, blipConfig.coords.y, blipConfig.coords.z)
            SetBlipSprite(blip, blipConfig.sprite)
            SetBlipDisplay(blip, blipConfig.display)
            SetBlipScale(blip, blipConfig.scale)
            SetBlipColour(blip, blipConfig.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(blipConfig.name)
            EndTextCommandSetBlipName(blip)
            universalBlips[blipName] = blip
        end
    end
end

-- Fonction pour créer tous les blips liés au métier
function createAllBlips()
    -- Créer les blips depuis la configuration des zones de récolte
    for _, zone in ipairs(Config.HarvestZones) do
        local blipName = zone.id .. '_zone'
        if not blips[blipName] then
            local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
            SetBlipSprite(blip, zone.blipSprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, zone.blipColor)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Récolte " .. zone.name)
            EndTextCommandSetBlipName(blip)
            blips[blipName] = blip
        end
    end
end

-- Fonction pour supprimer tous les blips de métier
function removeAllBlips()
    for blipName, _ in pairs(blips) do
        if blips[blipName] then
            RemoveBlip(blips[blipName])
            blips[blipName] = nil
        end
    end
end

-- Fonction pour gérer l'affichage des blips en fonction du job
function handleJobBlips()
    if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.General.requiredJob then
        createAllBlips()  -- Crée les blips spécifiques au vigneron
    else
        removeAllBlips()  -- Supprime les blips de vigneron si le joueur change de job
    end
end

-- Crée les blips universels lors du chargement initial du joueur
Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(500)
    end

    ESX.PlayerData = ESX.GetPlayerData()

    -- Crée les blips universels, sans restrictions de métier
    createUniversalBlips()

    -- Crée les blips spécifiques au job si nécessaire
    handleJobBlips()
end)

-- Crée les blips lorsque le joueur est chargé
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer

    -- Crée les blips universels, sans restrictions de métier
    createUniversalBlips()

    -- Crée les blips spécifiques au job si nécessaire
    handleJobBlips()
end)

-- Gère les changements de job
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
    handleJobBlips()
end)
