DebugPrint("Initialisation du système de missions de livraison")

local deliveryMission = {
    active = false,
    quantity = 0,
    price = 0,
    blip = nil,
    zoneId = nil,
    commandeRecuperee = false,
    depositBlip = nil,
    depositZoneId = nil
}

-- Démarrer la mission de récupération
RegisterNetEvent('jks_vigneron:startDeliveryMission')
AddEventHandler('jks_vigneron:startDeliveryMission', function(quantity, price)
    DebugPrint("Démarrage mission de livraison", {quantity = quantity, price = price})
    
    deliveryMission.active = true
    deliveryMission.quantity = quantity
    deliveryMission.price = price
    
    -- Créer le blip de destination
    deliveryMission.blip = AddBlipForCoord(Config.DeliveryZone.coords.x, Config.DeliveryZone.coords.y, Config.DeliveryZone.coords.z)
    SetBlipSprite(deliveryMission.blip, Config.DeliveryZone.blip.sprite)
    SetBlipDisplay(deliveryMission.blip, 4)
    SetBlipScale(deliveryMission.blip, Config.DeliveryZone.blip.scale)
    SetBlipColour(deliveryMission.blip, Config.DeliveryZone.blip.color)
    SetBlipAsShortRange(deliveryMission.blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.DeliveryZone.blip.name)
    EndTextCommandSetBlipName(deliveryMission.blip)
    
    -- Créer le waypoint automatique
    SetNewWaypoint(Config.DeliveryZone.coords.x, Config.DeliveryZone.coords.y)
    
    -- Supprimer l'ancienne zone si elle existe
    if deliveryMission.zoneId then
        exports.ox_target:removeZone(deliveryMission.zoneId)
    end
    
    -- Ajouter la zone ox_target pour récupérer la commande
    deliveryMission.zoneId = exports.ox_target:addSphereZone({
        coords = Config.DeliveryZone.coords,
        radius = Config.DeliveryZone.radius,
        groups = Config.General.requiredGroups,
        options = {
            {
                name = 'recuperer_commande_tonneaux',
                icon = 'fa-solid fa-truck',
                label = 'Récupérer la commande',
                groups = Config.General.requiredGroups,
                canInteract = function()
                    return deliveryMission.active
                end,
                onSelect = function()
                    TriggerServerEvent('jks_vigneron:recupererCommande', deliveryMission.quantity)
                end,
            }
        }
    })
    
    -- Notification avec instructions
    ESX.ShowNotification('Mission de récupération démarrée! Allez à la zone marquée sur la carte.', 'info', 8000)
end)

-- Commande récupérée - créer le blip de dépôt
RegisterNetEvent('jks_vigneron:commandeRecuperee')
AddEventHandler('jks_vigneron:commandeRecuperee', function(quantity)
    DebugPrint("Commande récupérée", {quantity = quantity})
    
    deliveryMission.commandeRecuperee = true
    
    -- Supprimer le blip de récupération
    if deliveryMission.blip then
        RemoveBlip(deliveryMission.blip)
        deliveryMission.blip = nil
    end
    
    -- Supprimer la zone de récupération
    if deliveryMission.zoneId then
        exports.ox_target:removeZone(deliveryMission.zoneId)
        deliveryMission.zoneId = nil
    end
    
    -- Créer le blip de dépôt
    deliveryMission.depositBlip = AddBlipForCoord(Config.DepositZone.coords.x, Config.DepositZone.coords.y, Config.DepositZone.coords.z)
    SetBlipSprite(deliveryMission.depositBlip, Config.DepositZone.blip.sprite)
    SetBlipDisplay(deliveryMission.depositBlip, 4)
    SetBlipScale(deliveryMission.depositBlip, Config.DepositZone.blip.scale)
    SetBlipColour(deliveryMission.depositBlip, Config.DepositZone.blip.color)
    SetBlipAsShortRange(deliveryMission.depositBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.DepositZone.blip.name)
    EndTextCommandSetBlipName(deliveryMission.depositBlip)
    
    -- Créer le waypoint automatique pour le dépôt
    SetNewWaypoint(Config.DepositZone.coords.x, Config.DepositZone.coords.y)
    
    -- Ajouter la zone ox_target pour déposer la commande
    deliveryMission.depositZoneId = exports.ox_target:addSphereZone({
        coords = Config.DepositZone.coords,
        radius = Config.DepositZone.radius,
        groups = Config.General.requiredGroups,
        options = {
            {
                name = 'deposer_commande_tonneaux',
                icon = 'fa-solid fa-warehouse',
                label = 'Déposer la commande',
                groups = Config.General.requiredGroups,
                canInteract = function()
                    return deliveryMission.active and deliveryMission.commandeRecuperee
                end,
                onSelect = function()
                    TriggerServerEvent('jks_vigneron:deposerCommande', deliveryMission.quantity)
                end,
            }
        }
    })
    
    ESX.ShowNotification('Commande récupérée! Allez à l\'entreprise pour déposer les tonneaux.', 'info', 8000)
end)

-- Terminer la mission
RegisterNetEvent('jks_vigneron:completeDeliveryMission')
AddEventHandler('jks_vigneron:completeDeliveryMission', function()
    DebugPrint("Mission de livraison terminée")
    
    if deliveryMission.active then
        deliveryMission.active = false
        deliveryMission.commandeRecuperee = false
        
        -- Supprimer tous les blips
        if deliveryMission.blip then
            RemoveBlip(deliveryMission.blip)
            deliveryMission.blip = nil
        end
        
        if deliveryMission.depositBlip then
            RemoveBlip(deliveryMission.depositBlip)
            deliveryMission.depositBlip = nil
        end
        
        -- Supprimer toutes les zones ox_target
        if deliveryMission.zoneId then
            exports.ox_target:removeZone(deliveryMission.zoneId)
            deliveryMission.zoneId = nil
        end
        
        if deliveryMission.depositZoneId then
            exports.ox_target:removeZone(deliveryMission.depositZoneId)
            deliveryMission.depositZoneId = nil
        end
        
        ESX.ShowNotification('Mission terminée! Vos tonneaux ont été ajoutés au stock.', 'success', 5000)
    end
end)

-- Fonction pour vérifier si une mission est active
function IsDeliveryMissionActive()
    DebugPrint("Vérification mission active", {active = deliveryMission.active})
    return deliveryMission.active
end

-- Nettoyer la mission si le joueur se déconnecte
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if deliveryMission.blip then
            RemoveBlip(deliveryMission.blip)
        end
        if deliveryMission.depositBlip then
            RemoveBlip(deliveryMission.depositBlip)
        end
        if deliveryMission.zoneId then
            exports.ox_target:removeZone(deliveryMission.zoneId)
        end
        if deliveryMission.depositZoneId then
            exports.ox_target:removeZone(deliveryMission.depositZoneId)
        end
    end
end)
