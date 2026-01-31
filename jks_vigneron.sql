-- =============================================
-- Script SQL pour le script jks_vigneron
-- =============================================

-- Table pour stocker les données de fermentation des cuves individuelles
CREATE TABLE IF NOT EXISTS `jks_fermentation_tank` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `player_id` varchar(50) NOT NULL,
    `grapes_quantity` int(11) NOT NULL DEFAULT 0,
    `deposit_time` int(11) NOT NULL,
    `fermentation_time` int(11) NOT NULL,
    `cuve_id` int(11) NOT NULL,
    `grape_type` varchar(10) NOT NULL DEFAULT 'white', -- 'white' ou 'red'
    PRIMARY KEY (`id`),
    KEY `player_id` (`player_id`),
    KEY `cuve_id` (`cuve_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table pour stocker les données de la cuve principale
CREATE TABLE IF NOT EXISTS `jks_vigneron` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `cuve` varchar(50) NOT NULL,
    `litres` int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `cuve` (`cuve`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- ITEMS POUR OX_INVENTORY
-- =============================================

-- Raisins rouges
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('red_grapes', 'Grappes de raisin rouge', 1, 0, 1);

-- Raisins blancs
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('white_grapes', 'Grappes de raisin blanc', 1, 0, 1);

-- Tonneaux vides
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('tonneaux_vide', 'Tonneau vide', 5, 0, 1);

-- Tonneaux de vin blanc
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('tonneaux_blanc', 'Tonneau de vin blanc', 5, 0, 1);

-- Tonneaux de vin rouge (NOUVEAU)
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('tonneaux_rouge', 'Tonneau de vin rouge', 5, 0, 1);

-- =============================================
-- JOB VIGNERON
-- =============================================

-- Job vigneron
INSERT INTO `jobs` (`name`, `label`) VALUES
('vigneron', 'Vigneron');

-- Grades du job vigneron
INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('vigneron', 0, 'employee', 'Employé', 200, '{}', '{}'),
('vigneron', 1, 'boss', 'Patron', 400, '{}', '{}');

-- =============================================
-- ESX SOCIETY INTEGRATION
-- =============================================

-- Compte société pour le vigneron
INSERT INTO `addon_account` (`name`, `label`, `shared`) VALUES
('society_vigneron', 'Vigneron', 1);

-- Données du compte société
INSERT INTO `addon_account_data` (`account_name`, `money`, `owner`) VALUES
('society_vigneron', 0, NULL);

-- Inventaire société pour le vigneron
INSERT INTO `addon_inventory` (`name`, `label`, `shared`) VALUES
('society_vigneron', 'Vigneron', 1);

-- Items dans l'inventaire société (optionnel)
INSERT INTO `addon_inventory_items` (`inventory_name`, `name`, `count`, `owner`) VALUES
('society_vigneron', 'red_grapes', 0, NULL),
('society_vigneron', 'white_grapes', 0, NULL),
('society_vigneron', 'tonneaux_vide', 0, NULL),
('society_vigneron', 'tonneaux_blanc', 0, NULL),
('society_vigneron', 'tonneaux_rouge', 0, NULL),
('society_vigneron', 'bouteille_vide', 0, NULL),
('society_vigneron', 'bouteille_vin_blanc', 0, NULL),
('society_vigneron', 'bouteille_vin_rouge', 0, NULL);

-- =============================================
-- DONNÉES INITIALES
-- =============================================

-- Initialiser les cuves principales séparées
INSERT INTO `jks_vigneron` (`cuve`, `litres`) VALUES
('principal_blanc', 0),
('principal_rouge', 0)
ON DUPLICATE KEY UPDATE `litres` = 0;
