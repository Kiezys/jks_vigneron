-- =====================================================
-- CLIENT RÉCOLTE SIMPLIFIÉ - TON VIGNERON
-- =====================================================

local isHarvesting = {} -- Table pour suivre les récoltes en cours par zone

-- Créer les zones d'interaction pour chaque zone de récolte
for _, zone in ipairs(Config.HarvestZones) do
    local options = {}
    
    -- Option selon le mode de récolte configuré
    if Config.HarvestSettings.autoHarvest then
        -- Mode auto-récolte
        table.insert(options, {
            name = 'harvest_' .. zone.id,
            icon = zone.icon,
            label = 'Récolter des ' .. zone.label .. ' (Auto)',
            groups = Config.General.requiredGroups,
            onSelect = function()
                startAutoHarvest(zone.id)
            end,
        })
    else
        -- Mode récolte manuelle
        table.insert(options, {
            name = 'harvest_' .. zone.id,
            icon = zone.icon,
            label = 'Récolter des ' .. zone.label,
            groups = Config.General.requiredGroups,
            onSelect = function()
                manualHarvest(zone.id)
            end,
        })
    end
    
    if Config.HarvestSettings.enableMaxItemsLimit then
        table.insert(options, {
            name = 'check_limits_' .. zone.id,
            icon = 'fa-solid fa-info-circle',
            label = 'Vérifier Combien de Raisins Vous Pouvez Récolter',
            groups = Config.General.requiredGroups,
            onSelect = function()
                TriggerServerEvent('jks_vigneron:checkHarvestLimits', zone.id)
            end,
        })
    end
    
    exports.ox_target:addSphereZone({
        coords = zone.coords,
        radius = Config.HarvestSettings.radius,
        options = options
    })
end

-- Fonction pour la récolte manuelle (une seule fois)
function manualHarvest(zoneId)
    DebugPrint("Démarrage récolte manuelle pour zone: " .. zoneId)
    
    -- Trouver la zone dans la configuration
    local harvestZone = nil
    for _, zone in ipairs(Config.HarvestZones) do
        if zone.id == zoneId then
            harvestZone = zone
            break
        end
    end
    
    if not harvestZone then
        LogError("Zone de récolte non trouvée pour l'ID: " .. tostring(zoneId))
        return
    end
    
    -- Lancer la progressbar de récolte avec ox_lib
    if lib.progressBar({
        duration = Config.HarvestSettings.harvestTime,
        label = "Récolte des " .. harvestZone.label,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = false,  -- Permet le mouvement pour le cancel
            combat = true,
        },
        anim = {
            dict = Config.HarvestSettings.animation.dict,
            clip = Config.HarvestSettings.animation.lib,
        },
    }) then
        -- Progressbar terminée avec succès
        TriggerServerEvent('jks_vigneron:harvestItem', zoneId)
        ESX.ShowNotification(Config.HarvestSettings.messages.manual_harvest, 'success', 3000)
    else
        -- Progressbar annulée
        ESX.ShowNotification(Config.HarvestSettings.messages.manual_harvest_failed, 'error', 3000)
    end
end

-- Fonction pour démarrer/arrêter la récolte automatique
function startAutoHarvest(zoneId)
    DebugPrint("Tentative de démarrage auto-récolte pour zone: " .. zoneId)
    
    if not isHarvesting[zoneId] then
        isHarvesting[zoneId] = true
        DebugPrint("Auto-récolte démarrée pour zone: " .. zoneId)
        
        ESX.ShowNotification(Config.HarvestSettings.messages.started, 'success', 5000)
        
        -- Thread principal de récolte
        Citizen.CreateThread(function()
            while isHarvesting[zoneId] do
                -- Vérifier si la récolte automatique est toujours active
                if isHarvesting[zoneId] then
                    -- Trouver la zone dans la configuration
                    local harvestZone = nil
                    for _, zone in ipairs(Config.HarvestZones) do
                        if zone.id == zoneId then
                            harvestZone = zone
                            break
                        end
                    end
                    
                    if not harvestZone then
                        LogError("Zone de récolte non trouvée pour l'ID: " .. tostring(zoneId))
                        isHarvesting[zoneId] = false
                        return
                    end
                    
                    -- Lancer la progressbar de récolte avec ox_lib
                    if lib.progressBar({
                        duration = Config.HarvestSettings.harvestTime,
                        label = "Récolte des " .. harvestZone.label,
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                            move = false,  -- Permet le mouvement pour le cancel
                            combat = true,
                        },
                        anim = {
                            dict = Config.HarvestSettings.animation.dict,
                            clip = Config.HarvestSettings.animation.lib,
                        },
                    }) then
                        -- Progressbar terminée avec succès
                        TriggerServerEvent('jks_vigneron:harvestItem', zoneId)
                    else
                        -- Progressbar annulée
                        DebugPrint("Progressbar annulée pour la zone: " .. zoneId)
                        stopHarvest(zoneId)
                    end
                end
                Citizen.Wait(Config.HarvestSettings.intervalTime)
            end
        end)
    else
        isHarvesting[zoneId] = false
        ESX.ShowNotification(Config.HarvestSettings.messages.stopped, 'info', 5000)
    end
end

-- Fonction centralisée pour arrêter la récolte automatique
function stopHarvest(zoneId, reason)
    isHarvesting[zoneId] = false
    
    local message = Config.HarvestSettings.messages.stopped
    if reason == 'inventory_full' then
        message = Config.HarvestSettings.messages.stopped_inventory_full
    elseif reason == 'limit_reached' then
        message = Config.HarvestSettings.messages.stopped_limit_reached
    end
    
    ESX.ShowNotification(message, 'info', 5000)
end

-- Événement pour arrêter la récolte automatique (inventaire plein ou limite atteinte)
RegisterNetEvent('jks_vigneron:stopHarvest')
AddEventHandler('jks_vigneron:stopHarvest', function(zoneId, reason)
    stopHarvest(zoneId, reason)
end)