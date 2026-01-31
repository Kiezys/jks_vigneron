
DebugPrint("Initialisation du système de tonneaux")

local barrelEntity = nil
local carryingBarrel = false

RegisterNetEvent('jks_attach_barrel_to_player')
AddEventHandler('jks_attach_barrel_to_player', function()
    DebugPrint("Attachement de tonneau au joueur")
    
    local ped = PlayerPedId()
    local model = GetHashKey('prop_wooden_barrel')

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end

    barrelEntity = CreateObject(model, GetEntityCoords(ped), true, true, true)

    -- Attacher le tonneau aux mains du joueur
    AttachEntityToEntity(barrelEntity, ped, GetPedBoneIndex(ped, 60309), 0.1, 0.0, 0.2, 90.0, 90.0, 0.0, true, true, false, true, 1, true)
    
    SetEntityAsMissionEntity(barrelEntity, true, true)
    
    carryingBarrel = true
    StartCarryBarrelAnimation()
end)

RegisterNetEvent('jks_vigneron:removeBarrelProps')
AddEventHandler('jks_vigneron:removeBarrelProps', function()
    DebugPrint("Suppression des props de tonneau")
    removeBarrelFromPlayer()  -- Supprime le tonneau et arrête l'animation
end)

function removeBarrelFromPlayer()
    DebugPrint("Suppression du tonneau du joueur")
    
    local ped = PlayerPedId()
    
    -- Supprimer le props du tonneau
    if barrelEntity and DoesEntityExist(barrelEntity) then
        DebugPrint("Suppression de l'entité tonneau")
        DetachEntity(barrelEntity, true, true)
        DeleteEntity(barrelEntity)
        barrelEntity = nil
    end
    
    -- Arrêter l'animation de port du tonneau
    if carryingBarrel then
        ClearPedTasks(ped)  -- Arrête l'animation
    end

    carryingBarrel = false
end

function StartCarryBarrelAnimation()
    Citizen.CreateThread(function()
        RequestAnimDict("anim@heists@box_carry@")
        while not HasAnimDictLoaded("anim@heists@box_carry@") do
            Citizen.Wait(100)
        end

        local ped = PlayerPedId()

        while carryingBarrel do
            -- Si l'animation n'est pas active, on la relance
            if not IsEntityPlayingAnim(ped, "anim@heists@box_carry@", "idle", 3) then
                TaskPlayAnim(ped, "anim@heists@box_carry@", "idle", 8.0, -8.0, -1, 50, 0, false, false, false)
            end
            Citizen.Wait(1000)
        end
    end)
end

-- Zone pour récupérer/déposer des tonneaux vides
exports.ox_target:addSphereZone({
    coords = vector3(-1936.0340576172, 2041.7132568359, 140.70919799805),
    radius = 2.0,
    groups = Config.General.requiredGroups,
    options = {
        {
            name = 'recuperer_tonneau_vide',
            icon = 'fa-solid fa-box',
            label = 'Récupérer un tonneau',
            groups = Config.General.requiredGroups,
            onSelect = function()
                TriggerServerEvent('jks_vigneron:recupererTonneauVide')
            end,
        },
        {
            name = 'deposer_tonneau_vide',
            icon = 'fa-solid fa-box-open',
            label = 'déposer un tonneau',
            groups = Config.General.requiredGroups,
            onSelect = function()
                TriggerServerEvent('jks_vigneron:deposeTonneauVide')
            end,
        },
        {
            name = 'commander_tonneaux',
            icon = 'fa-solid fa-shopping-cart',
            label = 'Commander des tonneaux',
            groups = Config.General.requiredGroups,
            canInteract = function()
                local playerData = ESX.GetPlayerData()
                return playerData.job.grade >= Config.BarrelOrders.minGrade
            end,
            onSelect = function()
                -- Vérifier la capacité du stash avant d'afficher l'input
                ESX.TriggerServerCallback('jks_vigneron:getStashCapacity', function(capacityInfo)
                    local maxPossible = capacityInfo.maxBarrels
                    local currentCount = capacityInfo.currentBarrels or 0
                    
                    if maxPossible <= 0 then
                        ESX.ShowNotification('Le stockage est plein! Impossible de commander des tonneaux.', 'error')
                        return
                    end
                    
                    local input = lib.inputDialog('Commander des tonneaux', {
                        {
                            type = 'number',
                            label = 'Quantité de tonneaux',
                            description = 'Prix: ' .. Config.BarrelOrders.pricePerBarrel .. '$ par tonneau\nStockage: ' .. currentCount .. '/' .. (capacityInfo.maxBarrels + currentCount) .. ' tonneaux',
                            min = 1,
                            max = maxPossible,
                            default = math.min(5, maxPossible)
                        }
                    })
                    
                    if input and input[1] then
                        local quantity = input[1]
                        if quantity > 0 and quantity <= maxPossible then
                            TriggerServerEvent('jks_vigneron:commanderTonneaux', quantity)
                        else
                            ESX.ShowNotification('Quantité invalide', 'error')
                        end
                    end
                end)
            end,
        }
    }
})