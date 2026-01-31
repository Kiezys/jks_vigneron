-- =====================================================
-- UTILITAIRES PARTAGÉS - JKS VIGNERON
-- =====================================================

-- Fonction de debug centralisée
function DebugPrint(message, data)
    if Config.General.debug then
        local prefix = "^3[JKS_VIGNERON DEBUG]^7 "
        if data then
            print(prefix .. message .. " | Data: " .. json.encode(data))
        else
            print(prefix .. message)
        end
    end
end

-- Fonction de debug avec niveau de priorité
function DebugLog(level, message, data)
    if Config.General.debug then
        local prefix = "^3[JKS_VIGNERON DEBUG]^7 "
        local levelPrefix = ""
        
        if level == "ERROR" then
            levelPrefix = "^1[ERROR]^7 "
        elseif level == "WARNING" then
            levelPrefix = "^3[WARNING]^7 "
        elseif level == "INFO" then
            levelPrefix = "^2[INFO]^7 "
        elseif level == "VERBOSE" then
            levelPrefix = "^5[VERBOSE]^7 "
        end
        
        if data then
            print(prefix .. levelPrefix .. message .. " | Data: " .. json.encode(data))
        else
            print(prefix .. levelPrefix .. message)
        end
    end
end

-- Fonction pour vérifier si le debug est activé
function IsDebugEnabled()
    return Config.General.debug
end

-- Fonction pour logger les événements
function LogEvent(eventName, data)
    if Config.General.debug then
        DebugLog("INFO", "Event: " .. eventName, data)
    end
end

-- Fonction pour logger les erreurs
function LogError(message, data)
    if Config.General.debug then
        DebugLog("ERROR", message, data)
    end
end

-- Fonction pour logger les avertissements
function LogWarning(message, data)
    if Config.General.debug then
        DebugLog("WARNING", message, data)
    end
end
