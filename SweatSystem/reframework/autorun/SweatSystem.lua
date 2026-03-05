-- ==========================================
-- Monster Hunter Wilds - Sweat System Mod (Passive Weather Edition)
-- Integrated by Antigravity
-- ==========================================

local re = re
local sdk = sdk
local imgui = imgui
local json = json
local Core = require("_CatLib")
local Utils = require("_CatLib.utils")

-- Performance: Localize common functions
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local math_abs = math.abs
local table_insert = table.insert
local table_remove = table.remove
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber
local string_format = string.format

-- ==========================================
-- Helper: Rounding / 辅助函数
-- ==========================================
local function round3(num) return math_floor(num * 1000 + 0.5) / 1000 end
local function round2(num) return math_floor(num * 100 + 0.5) / 100 end

-- ==========================================
-- Localization / 语言设置
-- ==========================================
local cur_lang_index = 1 -- English(1) Chinese(2)
local Lang = {
    en = {
        settings = "Sweat System", debug_mode = "Debug Mode (Show Values)", enable_mod = "Enable Mod", 
        global_params = "Global Growth Parameters", env_params = "Environment & Weather Settings", loc_time = "Location & Time", opt_pause_weather_safe = "Pause Weather in Safety Area", opt_pause_weather_camp = "Pause Weather in Camp", opt_force_wet_in_water = "In Water: Force Wetness to Max", opt_freeze_blackout = "Freeze Updates During Blackout", opt_freeze_loading = "Freeze Updates During Loading/Stage Change", lbl_time_zone = "Time Zone: ", btn_create_time_conf = "Create Time-of-Day Config for Current Stage", btn_fill_missing_time_conf = "Fill Missing Time-of-Day Slots", btn_create_all_time_conf = "Create Time-of-Day Configs for All Stages", time_conf_for_stage = "Time-of-Day Multipliers (Current Stage)",
        env_cur_stage = "Current Stage Info", env_weather = "Weather Multipliers", env_rename = "Rename Stage",
        env_create = "Create Config for Current Stage", env_wet_mult = "Env Wet Multiplier", env_dry_mult = "Env Dry Multiplier",
        env_weather_active = "[ACTIVE]", env_weather_inactive = "Inactive",
        body_parts = "Body Part Limits (Set 0 to Disable Part)", roughness_settings = "Skin Roughness Settings (Glossiness)", 
        custom_actions = "Custom Action Management (Added)", save_load = "Configuration File Management", 
        debug_values = "Current Sweat Values:", debug_motion = "Current Real-time Motion Info:", debug_lock = "[Debug] Force Lock Sweat Value", 
        debug_lock_val = "Locked Value (Restricted by Part Limit)", custom_guide_list = "Custom Attack Moves List", custom_motion_list = "Custom Animation Data List", 
        btn_delete = "Delete", type_stamina = "[Stamina Class]", type_motion = "[Motion Class]", type_guide = "[Guide Class]", 
        no_custom_actions = "No custom actions added yet. Please add them from History in Debug Mode.", 
        rate_stamina = "Increase Rate (Stamina Consumption)", rate_motion = "Increase Rate (Specific Animations)", rate_action = "Increase Rate (Attack Moves)", 
        rate_decrease = "Recovery Rate (Natural Drying)", rate_battle = "Increase Rate (Passive in Battle)", 
        refresh_interval = "Visual Refresh Interval (Seconds)", refresh_desc = "Lower = Smoother updates.\nOptimization Applied: Hash Map Lookup & Delta Checks.", 
        enable_stamina = "Enable Stamina Calculation", enable_action = "Enable Attack Move Calculation", enable_motion = "Enable Animation Calculation", 
        face_chk = "Enable Face Sweating", body_chk = "Enable Body Sweating", enable_roughness = "Enable Roughness Control (Override Default Material)", 
        val_roughness_face = "Face Roughness (Lower = Shinier)", val_roughness_body = "Body Roughness (Lower = Shinier)", 
        limit_desc_face = "Face Maximum Wetness", limit_desc_body = "Body Maximum Wetness",
        add_to_stamina = "Add as [Stamina Class]", add_to_motion = "Add as [Motion Class]", add_to_guide = "Add as [Attack Class]", 
        added_msg = "Successfully added to Custom List!", exists_msg = "Action already exists in list", 
        hist_title = "Action History (Expand to Start Recording)", hist_clear = "Clear History", 
        btn_save = "Save Configuration", btn_load = "Load Configuration", btn_recan = "Force Rescan Character Meshes",
        val_min_face = "Face Minimum Wetness", val_min_body = "Body Minimum Wetness",
        debug_val_fmt = "Face: %.2f | Body: %.2f",
        debug_env_wet = "Total Env Wet Mult: %.2fx",
        debug_env_dry = "Total Env Dry Mult: %.2fx",
        lbl_cur_stage_id = "Current Stage ID: ",
        status_unconfigured = "Unconfigured",
        msg_wait_stage = "Waiting for Stage Load...",
        w_heatwave = "Heat Wave",
        w_heavyrain = "Heavy Rain",
        w_sandstorm = "Sand Storm",
        w_blizzard = "Blizzard",
        w_unknown = "Unknown Weather",
        opt_water_force_wetness = "In Water: Forced Wetness Value",
        opt_water_wet_cap = "In Water: Wetness Cap (Can exceed normal max)",
        env_wet_mult_desc = "Wet Mult affects wetness gain in this area. Higher = sweat builds faster.",
        env_dry_mult_desc = "Dry Mult affects drying speed in this area. Higher = dries faster.",
        env_wet_mult_weather_desc = "Wet Mult affects wetness gain when this weather is active.",
        env_dry_mult_weather_desc = "Dry Mult affects drying speed when this weather is active.",
        time_wet_mult_desc = "Wet Mult: controls wetness gain (sweat/soak). 1.00 = default.",
        time_dry_mult_desc = "Dry Mult: controls drying speed (evaporation). 1.00 = default.",
        rate_env_passive = "Base Rate (Passive Env Growth)",
        desc_env_passive = "Takes effect when Env Wet Multiplier > 1.0 (e.g. Rain/Heat)",
        auto_scan_info = "Auto-Scan Status: ",
        auto_scan_chk = "Auto-Detect Equipment Changes"
    },
    cn = {
        settings = "汗湿系统", debug_mode = "调试模式 (显示数值)", enable_mod = "启用模组", 
        global_params = "全局增长参数", env_params = "环境与天气设置", loc_time = "位置与时段", opt_pause_weather_safe = "安全区域：屏蔽天气影响", opt_pause_weather_camp = "营地：屏蔽天气影响", opt_force_wet_in_water = "水中：汗湿直接拉满", opt_freeze_blackout = "黑屏/过场：冻结更新", opt_freeze_loading = "加载/切图：冻结更新", lbl_time_zone = "时段：", btn_create_time_conf = "为当前场景创建时段配置", btn_fill_missing_time_conf = "补全缺失的时段项", btn_create_all_time_conf = "一键为所有场景生成时段预设", time_conf_for_stage = "时段倍率（仅当前场景）",
        env_cur_stage = "当前场景信息", env_weather = "天气倍率设置", env_rename = "重命名场景",
        env_create = "为当前场景创建配置", env_wet_mult = "环境湿润倍率", env_dry_mult = "环境风干倍率",
        env_weather_active = "【当前生效中】", env_weather_inactive = "未激活",
        body_parts = "部位上下限设置 (设为0即关闭该部位)", roughness_settings = "皮肤粗糙度设置 (光泽度)", 
        custom_actions = "自定义动作管理（已添加）", save_load = "配置文件管理", 
        debug_values = "当前各部位汗湿数值:", debug_motion = "当前实时动作参数:", debug_lock = "【调试】强制锁定汗湿值", 
        debug_lock_val = "锁定数值 (受部位上限限制)", custom_guide_list = "自定义攻击招式列表", custom_motion_list = "自定义动画数据列表", 
        btn_delete = "删除", type_stamina = "【体力消耗类】", type_motion = "【动作动画类】", type_guide = "【攻击招式类】", 
        no_custom_actions = "暂无自定义动作。请在调试模式的历史记录中点击添加。", 
        rate_stamina = "增长率 (耐力消耗时)", rate_motion = "增长率 (匹配特定动画时)", rate_action = "增长率 (使用武器招式时)", 
        rate_decrease = "消退率 (随时间自然风干)", rate_battle = "增长率 (处于战斗状态时额外增加)", 
        refresh_interval = "画面刷新间隔（秒）", refresh_desc = "数值越低更新越流畅。已应用优化：哈希表查找与差值检测。", 
        enable_stamina = "启用耐力关联计算", enable_action = "启用攻击招式关联计算", enable_motion = "启用基础动画关联计算", 
        face_chk = "启用脸部汗湿", body_chk = "启用身体/腿部汗湿", enable_roughness = "启用粗糙度控制 (覆盖默认材质)", 
        val_roughness_face = "脸部粗糙度 (越低越油亮)", val_roughness_body = "身体粗糙度 (越低越油亮)", 
        limit_desc_face = "脸部汗湿上限", limit_desc_body = "身体汗湿上限", 
        add_to_stamina = "添加为【体力消耗类】", add_to_motion = "添加为【动作动画类】", add_to_guide = "添加为【攻击招式类】", 
        added_msg = "已成功添加到自定义列表!", exists_msg = "该动作已在列表中", 
        hist_title = "动作历史（展开以开始记录）", hist_clear = "清空历史", 
        btn_save = "保存配置", btn_load = "加载配置", btn_recan = "强制重新扫描角色模型",
        val_min_face = "脸部汗湿下限", val_min_body = "身体汗湿下限",
        debug_val_fmt = "脸部: %.2f | 身体: %.2f",
        debug_env_wet = "环境综合湿润倍率: %.2fx",
        debug_env_dry = "环境综合风干倍率: %.2fx",
        lbl_cur_stage_id = "当前场景 ID: ",
        status_unconfigured = "未配置",
        msg_wait_stage = "等待场景加载...",
        w_heatwave = "热浪",
        w_heavyrain = "暴雨",
        w_sandstorm = "沙尘暴",
        w_blizzard = "暴风雪",
        w_unknown = "未知天气",
        opt_water_force_wetness = "水下：拉满湿度数值",
        opt_water_wet_cap = "水下：湿度上限（可超过普通上限）",
        env_wet_mult_desc = "湿润倍率影响该区域的汗湿增长速度，数值越高汗湿积累越快。",
        env_dry_mult_desc = "风干倍率影响该区域的干燥速度，数值越高干燥越快。",
        env_wet_mult_weather_desc = "该天气生效时，湿润倍率会影响汗湿增长速度。",
        env_dry_mult_weather_desc = "该天气生效时，风干倍率会影响干燥速度。",
        time_wet_mult_desc = "湿润倍率：控制汗湿/浸湿的增长速度，1.00为默认值。",
        time_dry_mult_desc = "风干倍率：控制干燥/蒸发速度，1.00为默认值。",
        rate_env_passive = "基础增长率（环境被动增长）",
        desc_env_passive = "当环境湿润倍率>1.0时生效（如雨天/热浪天气）",
        auto_scan_info = "自动检测状态: ",
        auto_scan_chk = "自动检测装备变更"
    }
}

local function T(key)
    local lang_code = (cur_lang_index == 1) and "en" or "cn"
    return Lang[lang_code][key] or key
end

-- ==========================================
-- Global Variables
-- ==========================================
local stamina_value = 0
local face_sweating_value = 0
local body_sweating_value = 0
local last_stamina_value = 0

-- Track last applied values
local applied_face_sweat = -1
local applied_body_sweat = -1
local applied_face_rough = -1
local applied_body_rough = -1

-- [USER DATA: DEFAULT VALUES UPDATED]
local SWEATING_INCREASE_RATE = 0.035
local SWEATING_DECREASE_RATE = 0.025
local SWEATING_INCREASE_RATE_BATTLE = 0.03
local SWEATING_MOTIONDATA_INCREASE_RATE = 0.04
local SWEATING_ACTIONGUIDE_INCREASE_RATE = 0.03
local SWEATING_ENV_PASSIVE_RATE = 0.01

local SWEATING_LIMIT_MIN = 0.00
local SWEATING_LIMIT_MAX = 0.50

local update_interval_seconds = 0.50 

-- Limits [USER DATA: UPDATED DEFAULTS]
local MAX_FACE_SWEATING = 2.00
local MIN_FACE_SWEATING = 0.00 
local MAX_BODY_SWEATING = 2.00
local MIN_BODY_SWEATING = 0.00 

local enable_roughness_control = true
local face_roughness_value = 0.40
local body_roughness_value = 0.40

local debug_lock_sweat = false
local debug_sweat_val = 1.00

local enable_stamina_sweating = true
local enable_motiondata_sweating = true
local enable_actionguide_sweating = true
local mod_enabled = true
local debug_enabled = false 
local is_history_expanded = false 

local enable_face_sweating = true
local enable_body_sweating = true

local action_history = {}
local last_captured_motion_id = -1
local last_captured_guide_id = -1
local notification_timer = 0
local notification_msg = ""

-- [UI STATE VARIABLES]
local expanded_custom_motions = {}
local alias_edit_buffers = {}

-- [AUTO EQUIP CHECK VARIABLES]
local auto_equip_scan_enabled = true -- NEW TOGGLE
local last_mesh_hash = ""
local equip_check_timer = 0
local EQUIP_CHECK_INTERVAL = 2000 -- Check every 2000ms (2 seconds)

-- ==========================================
-- ENVIRONMENT & WEATHER CONFIG
-- ==========================================
local EnvConfig = {
    current_stage_id = -1,
    current_stage_name_display = "", 
    total_wet_mult = 1.0,
    total_dry_mult = 1.0,
env_wet_mult = 1.0,     -- stage * time-of-day
env_dry_mult = 1.0,     -- stage * time-of-day
weather_wet_mult = 1.0, -- active weather product
weather_dry_mult = 1.0, -- active weather product

current_time_zone_index = -1,
current_time_zone_name_display = "",

    -- [USER DATA: STAGE DEFAULTS]
    stage_settings = {
        [0] = { name = "Windward Plains / 天堑沙原", wet = 1.30, dry = 1.35 },
        [1] = { name = "Scarlet Forest / 绯红森林", wet = 1.60, dry = 0.90 },
        [2] = { name = "Oilwell Basin / 涌油谷", wet = 1.70, dry = 1.40 },
        [3] = { name = "Iceshard Cliffs / 冰雾断崖", wet = 0.60, dry = 1.40 },
        [4] = { name = "Ruins of Wyveria / 龙都遗迹", wet = 1.10, dry = 1.10 },
        [9] = { name = "Dragon Valley Ruins / 龙谷遗址", wet = 1.00, dry = 1.05 },
        [10] = { name = "Stage 10", wet = 0.50, dry = 1.25 },
        [11] = { name = "Stage 11", wet = 0.80, dry = 1.20 },
        [12] = { name = "Suja, Peaks of Accord / 交汇之峰·酥加", wet = 0.85, dry = 1.10 },
        [13] = { name = "Stage 13", wet = 2.00, dry = 1.00 },
        [14] = { name = "Grand Hub / 大集会所", wet = 0.95, dry = 1.05 },
        [15] = { name = "Stage 15", wet = 1.25, dry = 1.25 },
-- [USER DATA: TIME-OF-DAY DEFAULTS]
-- Index mapping observed in ace.GlobalTimeZoneManager:
-- 0 = Camp Rest / Between Night & Day, 1 = Morning, 2 = Day, 3 = Evening, 4 = Night
time_settings = {
    -- Example: Windward Plains has larger day/night temperature swing.
    -- You can tune these in the UI.
    [0] = {
        [0] = { name = "Rest",    wet = 0.90, dry = 0.95 },
        [1] = { name = "Morning", wet = 1.00, dry = 1.05 },
        [2] = { name = "Day",     wet = 1.15, dry = 1.10 },
        [3] = { name = "Evening", wet = 1.00, dry = 1.05 },
        [4] = { name = "Night",   wet = 0.85, dry = 1.00 },
    },
},

    },

    -- [USER DATA: WEATHER DEFAULTS]
    weather = {
        { field = "_HeatWave",   key = "w_heatwave",   wet = 2.0, dry = 1.5, is_active = false },
        { field = "_HeavyRain",  key = "w_heavyrain",  wet = 5.0, dry = 0.1, is_active = false },
        { field = "_SandStorm",  key = "w_sandstorm",  wet = 0.5, dry = 3.0, is_active = false },
        { field = "_Blizzard",   key = "w_blizzard",   wet = 0.5, dry = 2.0, is_active = false },
    }
}
local env_manager_class = "app.EnvironmentManager"

-- ==========================================
-- Location & Time State (auto-detection)
-- ==========================================
local app_effect_manager_class = "app.AppEffectManager"
local time_zone_manager_class = "ace.GlobalTimeZoneManager"

local LocationState = {
    in_safety_area = false,
    in_camp = false,
    in_water = false,
    is_blackout = false,
    is_change_stage_or_env = false,
}

local TimeZoneNameMap = {
    [0] = "Rest",
    [1] = "Morning",
    [2] = "Day",
    [3] = "Evening",
    [4] = "Night",
}

-- ==========================================
-- Default time-of-day climate presets per stage
-- These values are baseline *suggestions* to reduce manual work.
-- You can fine-tune them in the UI and save to JSON.
-- wet: affects wetness gain (sweat/soak)
-- dry: affects wetness loss (evaporation/drying)
-- ==========================================
local StageTimeDefaults = {
    -- Windward Plains / 天堑沙原: hot day, cool night, strong evaporation.
    [0]  = { [0]={w=0.95,d=1.00}, [1]={w=1.05,d=1.10}, [2]={w=1.25,d=1.30}, [3]={w=1.05,d=1.15}, [4]={w=0.85,d=0.95} },
    -- Scarlet Forest / 绯红森林: humid, slower drying.
    [1]  = { [0]={w=1.05,d=0.90}, [1]={w=1.10,d=0.90}, [2]={w=1.15,d=0.85}, [3]={w=1.10,d=0.90}, [4]={w=1.00,d=0.92} },
    -- Oilwell Basin / 涌油谷: high heat and evaporation.
    [2]  = { [0]={w=1.10,d=1.15}, [1]={w=1.20,d=1.25}, [2]={w=1.35,d=1.45}, [3]={w=1.20,d=1.30}, [4]={w=1.00,d=1.10} },
    -- Iceshard Cliffs / 冰雾断崖: cold, less sweat; wind can dry.
    [3]  = { [0]={w=0.75,d=1.10}, [1]={w=0.70,d=1.15}, [2]={w=0.65,d=1.20}, [3]={w=0.70,d=1.15}, [4]={w=0.80,d=1.05} },
    -- Ruins of Wyveria / 龙都遗迹: mild swing.
    [4]  = { [0]={w=0.95,d=1.00}, [1]={w=1.00,d=1.05}, [2]={w=1.05,d=1.05}, [3]={w=1.00,d=1.05}, [4]={w=0.95,d=1.00} },
    -- Dragon Valley Ruins / 龙谷遗址: slightly dry.
    [9]  = { [0]={w=0.95,d=1.05}, [1]={w=1.00,d=1.10}, [2]={w=1.05,d=1.15}, [3]={w=1.00,d=1.10}, [4]={w=0.95,d=1.05} },
    -- Suja / 交汇之峰·酥加: hub-like, stable.
    [12] = { [0]={w=0.95,d=1.00}, [1]={w=1.00,d=1.00}, [2]={w=1.00,d=1.00}, [3]={w=1.00,d=1.00}, [4]={w=0.95,d=1.00} },
    -- Grand Hub / 大集会所: stable.
    [14] = { [0]={w=0.95,d=1.00}, [1]={w=1.00,d=1.00}, [2]={w=1.00,d=1.00}, [3]={w=1.00,d=1.00}, [4]={w=0.95,d=1.00} },
}

local function GetStageTimeDefault(stage_id, tz_index)
    local st = StageTimeDefaults[stage_id]
    if not st then
        return 1.0, 1.0
    end
    local slot = st[tz_index]
    if not slot then
        return 1.0, 1.0
    end
    return (slot.w or 1.0), (slot.d or 1.0)
end


-- ==========================================
-- Time-of-day presets helpers
-- ==========================================
local function BuildDefaultTimeStageTemplate()
    -- Create a neutral template; specific defaults are applied by EnsureTimeSettingsForStage(stage_id)
    local out = {}
    for i = 0, 4 do
        out[i] = {
            name = TimeZoneNameMap[i] or ("T" .. tostring(i)),
            wet  = 1.0,
            dry  = 1.0,
        }
    end
    return out
end

local function EnsureTimeSettingsForStage(stage_id)
    if not EnvConfig.time_settings then EnvConfig.time_settings = {} end
    local stage_tbl = EnvConfig.time_settings[stage_id]
    local created = false
    if not stage_tbl then
        stage_tbl = BuildDefaultTimeStageTemplate()
        EnvConfig.time_settings[stage_id] = stage_tbl
        created = true
    end
    -- Fill missing slots
    for i = 0, 4 do
        if created and stage_tbl[i] then
            local dw, dd = GetStageTimeDefault(stage_id, i)
            stage_tbl[i].wet = dw
            stage_tbl[i].dry = dd
        elseif not stage_tbl[i] then
            local dw, dd = GetStageTimeDefault(stage_id, i)
            stage_tbl[i] = { name = TimeZoneNameMap[i] or ("T" .. tostring(i)), wet = dw, dry = dd }
        else
            if stage_tbl[i].name == nil then stage_tbl[i].name = TimeZoneNameMap[i] or ("T" .. tostring(i)) end
            if stage_tbl[i].wet  == nil then
                local dw, _ = GetStageTimeDefault(stage_id, i)
                stage_tbl[i].wet = dw
            end
            if stage_tbl[i].dry  == nil then
                local _, dd = GetStageTimeDefault(stage_id, i)
                stage_tbl[i].dry = dd
            end
        end
    end
end

local function EnsureAllTimeSettings()
    if not EnvConfig.stage_settings then return end
    for stage_id, _ in pairs(EnvConfig.stage_settings) do
        EnsureTimeSettingsForStage(stage_id)
    end
end


-- [USER SETTINGS]
local pause_weather_in_safety_area = true
local pause_weather_in_camp = true
local force_wet_in_water = true
local freeze_updates_during_blackout = true
local freeze_updates_during_change_stage = true
local WATER_FORCE_WETNESS = 3.00
local WATER_WETNESS_CAP   = 3.00
local post_water_drying = false
local was_in_water = false

-- ==========================================
-- Hunter Data
-- ==========================================
local _M = {}
_M.HunterData = {
    StaminaData = -1,
    MotionData = {},
    SubActionData = {},
    CurrentActionName = "",
    CurrentActionGuideID = nil,
    Hunter = nil 
}

-- ==========================================
-- PERFORMANCE CACHE
-- ==========================================
local MaterialCache = {
    IsValid = false,
    FaceMaterials = {}, 
    BodyMaterials = {} 
}

-- Lookup Tables
local ActionGuideMap = {} 
local MotionDataMap = {} 

-- ==========================================
-- Data Tables
-- ==========================================
local CustomMotionTbl = {}

local DefaultMotionTbl = {
    -- Default system motion data (not saved to JSON)
    {0, 1, 73, 1, "motion", ""}, {0, 1, 521, 1, "motion", ""}, {0, 1, 523, 1, "motion", ""},
    {0, 1, 135, 1, "motion", ""}, {0, 1, 69, 1, "motion", ""}, {0, 1, 331, 1, "motion", ""},
    {0, 1, 172, 1, "motion", ""}, {0, 1, 97, 1, "stamina", ""}, {0, 1, 174, 1, "stamina", ""},
    -- Additional default motions
    {0, 1, 2, 1}, {0, 1, 4, 1}, {0, 1, 11, 1}, {0, 1, 36, 1}, {0, 1, 40, 1}, 
    {0, 1, 46, 1}, {0, 1, 49, 1}, {0, 1, 50, 1}, {0, 1, 53, 1}, 
    {0, 1, 62, 1}, {0, 1, 63, 1}, {0, 1, 64, 1}, {0, 1, 65, 1}, 
    {0, 1, 66, 1}, {0, 1, 67, 1}, {0, 1, 68, 1}, {0, 1, 90, 1}, {0, 1, 94, 1}, 
    {0, 1, 129, 1}, {0, 1, 133, 1}, {0, 1, 251, 1}, {0, 3, 93, 1}, {0, 3, 112, 1},
    {0, 1, 32, 2}, {0, 1, 37, 2}, {0, 1, 47, 2}, {0, 1, 100, 2}, {0, 1, 101, 2}, 
    {0, 1, 103, 2}, {0, 1, 107, 2}, {0, 1, 112, 2}, {0, 1, 113, 2}, {0, 1, 114, 2}, 
    {0, 1, 115, 2}, {0, 1, 116, 2}, {0, 1, 117, 2}, {0, 1, 240, 2}, {0, 1, 253, 2}, 
    {0, 1, 330, 2}, {0, 1, 350, 2}, {0, 1, 351, 2}, {0, 1, 352, 2}, {0, 1, 353, 2}, 
    {0, 1, 354, 2}
}

local CustomActionGuideTbl = {}
local DefaultActionGuideTbl = {
    -- Greatsword
{1329235968, "Jumping Charged Slash"}, {-1811259392, "Charge"}, {-1769468672, "Strong Charged Slash"},
{-421454208, "Charge"}, {-1673173760, "Overhead Slash"}, {-1156222080, "Charge"}, {2095506176, "True Charged Slash"},
{-2072799872, "Offset Rising Slash"}, {225253952, "Wide Slash"}, {1652940800, "Tackle"},
{-101683424, "Leaping Wide Slash"}, {190453744, "Side Blow"}, {146633456, "Rising Slash"},
{506494304, "Focus Slash: Perforate"}, {-1298833664, "Focus Slash: Perforate"}, {1405301888, "Strong Wide Slash"},
-- Chargeblade
{-584458432, "Sword: Weak Slash"}, {-406475264, "Sword: Shield Thrust"}, {937742400, "Sword: Jumping Slash Landing"},
{-324722336, "Sword: Forward Slash"}, {530797824, "Sword: Return Stroke"}, {1314887424, "Sword: Roundslash"},
{-268644672, "Charge"}, {1630431488, "Sword: Charged Double Slash"}, {1775176320, "Sword: Charged Rising Slash"},
{1244106368, "Focus Slash: Double Rend"}, {441448704, "Axe: Dash Slam"}, {-296247648, "Sword: Condensed Element Slash"},
{-1699645312, "Shield: Element Boost"}, {869165568, "Sword: Fade Slash"}, {-1598306688, "Sword: Morph Slash"},
{794588032, "Axe: Element Discharge I"}, {-2127622656, "Axe: Rising Slash"}, {1581908864, "Axe: Overhead Slash"},
{-1440144640, "Axe: Element Discharge II"}, {-1889821952, "Axe: Amped Element Discharge"},
{1635818112, "Axe: Amped Element Discharge"}, {1126951936, "Axe: Amped Element Discharge Follow-up"},
{-1288729984, "Elemental Roundslash"}, {181561280, "Axe: Rushing Element Discharge I"},
{2051596032, "Axe: Morph Slash"}, {266499504, "Axe: Super Amped Element Discharge"},
{2109388160, "Axe: Lateral Fade Slash"}, {1907177728, "Axe: Backstep Slash"}, {486902624, "Sword: Jumping Slash"},
-- Longsword
{-1997082496, "Overhead Slash"}, {-1065507968, "Crescent Slash"}, {1455994752, "Thrust"}, {-1036368000, "Rising Slash"},
{1153596544, "Jumping Rising Slash"}, {-37508024, "Fade Slash"}, {762765376, "Spirit Step Slash"},
{621496000, "Spirit Blade I"}, {1186424448, "Spirit Blade II"}, {-1476255872, "Spirit Blade III"},
{852602816, "Spirit Roundslash"}, {-1116470656, "Spinning Crimson Slash"}, {-1997082496, "Crimson Slash I"},
{1472591744, "Crimson Slash II"}, {-1065507968, "Crimson Slash III"}, {1930738944, "Spirit Charge"},
{-1559988736, "Special Sheathe"}, {491596736, "Iai Spirit Slash"}, {1506281344, "Iai Slash"},
{456426976, "Foresight Slash"}, {456426976, "Foresight Whirl Slash"}, {1569905664, "Focus Strike: Unbound Thrust"},
{-1840683648, "Focus Strike: Unbound Thrust"}, {22163, "Spirit Thrust"}, {1048171072, "Spirit Thrust"},
{1909693824, "Spirit Helm Breaker"}, {-1093563648, "Spirit Release Slash"}, {643151488, "Aerial Spirit Blade Draw"},
{13933, "Dismount Attack"},
-- Gunlance
{329682016, "Lunging Upthrust"}, {-789417920, "Lateral Thrust II"}, {-551745024, "Wide Sweep"},
{646080000, "Wyrmstake Full Blast"}, {1069952960, "Reload"}, {703375872, "Shelling"}, {-349299296, "Charge"},
{-43537492, "Charged Shelling"}, {1671040640, "Moving Wide Sweep"}, {-2132440704, "Reload"},
{1205828736, "Perfect Guard"}, {372457152, "Multi Wyrmstake Full Blast"}, {-1588566656, "Guard"},
{-26915160, "Wyvern's Fire"}, {-1926268544, "Quick Reload"}, {-1562396032, "Rising Slash"},
{-1347992960, "Overhead Smash"}, {-1677525760, "Burst Fire"}, {26863, "Dismount Attack"},
{1940934784, "Lateral Thrust I"}, {1714223872, "Guard Thrust I"}, {1115267328, "Guard Thrust III"},
{-847729408, "Sidestep"}, {452042176, "Jumping Smash"}, {-915528384, "Focus Strike: Drake Auger"},
{-869946240, "Focus Strike: Drake Auger"}, {-2111931264, "Focus Strike: Drake Auger"}, {-1361289856, "Jumping Thrust"},
{-699316544, "Power Clash"}, {1364206336, "Power Clash"}, {20715, "Quick Reload"}, {1777578112, "Stalwart Guard"},
{-289223072, "Counter Rush"}, {-1594437120, "Guard Thrust II"}, {1497865856, "Wyrmstake Cannon"}, {629, "Quick Reload"},
-- Bow
{1514344832, "Aim/Focus"}, {840735488, "Shoot"}, {1920365056, "Charging Sidestep"}, {-125532448, "Dragon Piercer"},
{15507, "Dragon Piercer"}, {-1657138304, "Thousand Dragons"},
-- Dual Blades
{1562259072, "Demon Fangs"}, {-268803040, "Twofold Demon Slash"}, {-1092490368, "Sixfold Demon Slash"},
{1061310464, "Double Slash"}, {1802004864, "Double Slash Return Stroke"}, {144065008, "Circle Slash"},
{927994752, "Lunging Strike"}, {-1541920000, "Roundslash"}, {-1497146240, "Rising Slash"}, {829880384, "Sliding Slash"},
{154975120, "Sliding Slash"}, {995066176, "Jumping Doubleslash"}, {-1928036352, "Focus Strike: Turning Tide"},
{-372107104, "Focus Strike: Turning Tide"}, {-719512000, "Midair Spinning Blade Dance"},
{-1642044928, "Midair Spinning Blade Dance Landing"}, {211121424, "Spinning Blade Dance Finisher"},
{-1366590208, "Spinning Blade Dance Finisher Landing"}, {-1398199424, "Heavenly Blade Dance"},
{-45955064, "Heavenly Blade Dance Landing"}, {165650304, "Demon Mode"}, {1516296832, "Demon Mode"},
{1262752256, "Demon Dodge"}, {1562259072, "Demon Fangs"}, {-268803040, "Twofold Demon Slash"},
{-1092490368, "Sixfold Demon Slash"}, {215332432, "Demon Flurry Rush"}, {-1318603136, "Roundslash"},
{1443799168, "Double Roundslash"}, {-1364415872, "Rising Slash"}, {300353024, "Blade Dance I"},
{1565251968, "Blade Dance II"}, {72416008, "Blade Dance III"}, {-1698437888, "Demon Flurry I"},
{1304483584, "Demon Flurry II"}, {1912740608, "Left Fade Slash"}, {-291922400, "Right Fade Slash"},
-- Misc
{1413, "Dismount Attack"},
-- Sword and Shield
{-669292416, "Advancing Slash"}, {771635840, "Diagonal Rising Slash"}, {-468041344, "Spinning Reaper"},
{-1520769024, "Lateral Slash"}, {-365669696, "Spinning Rising Slash"}, {937851328, "Chop"}, {1140208384, "Chop"},
{-278451072, "Charged Slash"}, {833415424, "Scaling Slash"}, {-1979692928, "Jumping Slash"}, {105498080, "Backstep"},
{-76675704, "Falling Bash"}, {-1201359616, "Plunging Thrust"}, {-1114434688, "Shield Bash"}, {-439662016, "Hard Bash"},
{-567233408, "Perfect Guard"}, {-1943029120, "Sliding Swipe"}, {-1544624512, "Jumping Rising Slash Landing"},
{-432023520, "Standby"}, {255974432, "Guard Slash"}, {1299070464, "Guard"}, {-1591131136, "Counter Slash"},
{-1093479680, "Rising Slash"}, {1521711744, "Evade"},
-- Switch Axe
{143967248, "Axe: Overhead Slash"}, {372106112, "Axe: Spiral Burst Slash"}, {-1140363264, "Axe: Wild Swing"},
{-255976208, "Axe: Heavy Slam"}, {1855746432, "Sword: Left Rising Slash"}, {150431184, "Sword: Double Slash"},
{-1737891328, "Sword: Heavenward Flurry"}, {-553980096, "Sword: Right Rising Slash"},
{-1084801536, "Sword: Overhead Slash"}, {-1209716864, "Axe: Morph Slash"}, {-977580416, "Sword: Overhead Morph Slash"},
{888503808, "Sword: Downward Fade Slash"}, {1711220352, "Axe: Forward Overhead Slash"}, {1338690432, "Axe: Side Slash"},
{-1972073600, "Axe: Morph Sweep"}, {-84158064, "Unbridled Slash"}, {26943142, "Full Release Slash"},
{-1887083904, "Axe: Morph Rising Double Slash"}, {-1897889664, "Offset Attack"},
{166716544, "Axe: Follow-up Heavy Slam"}, {-128645088, "Axe: Offset Rising Slash"},
{1659893248, "Axe: Follow-up Morph Slash"}, {-28020688, "Element Discharge"},
{-1280417792, "Element Discharge Finisher"}, {1649891712, "Unbridled Slash"}, {2050047744, "Axe: Morph Slash"},
{486853024, "Focus Assault: Morph Combination"}, {1893422208, "Zero Sum Discharge"},
{-1011370176, "Quick Zero Sum Finishing Discharge"}, {67143400, "Zero Sum Discharge Finisher"},
{-1381817088, "Sword: Counter Rising Slash"}, {1185187840, "Axe: Fade Slash"},
{751151936, "Sword: Counter Rising Slash"}, {1658039040, "Sword: Morph Double Slash"},
{-694198912, "Power Axe Finisher"},
-- Hunting Horn
{-201995088, "Left Swing"}, {1180191104, "Forward Smash"}, {-20758400, "Hilt Stab"}, {800331776, "Flourish"},
{-671947712, "Backwards Strike"}, {-208341008, "Perform"}, {113146256, "Perform"}, {-1751799040, "Performance Beat"},
{-6258827, "Encore"}, {-1842698112, "Resounding Melody"}, {166644960, "Right Swing"}, {386094144, "Hilt Stab"},
{-787884800, "Overhead Smash"}, {2056927744, "Overhead Smash Follow-up Attack"}, {-1250021248, "Encore"},
{-1457110272, "Focus Strike: Reverb"}, {-466143936, "Echo Bubble"}, {-1354698240, "Melody of Life"},
{1368552832, "Hilt Stab"}, {-286523680, "Perform"}, {1994995200, "Performance Landing"},
{1317018112, "Focus Strike: Reverb"}, {14805, "Charge"}, {-1113914624, "Offset Melody"}, {1763677568, "Jumping Smash"},
-- Hammer
{-222720992, "Overhead Smash II"}, {1449700864, "Upswing"}, {-2018062080, "Charge"}, {-536417184, "Charged Big Bang"},
{976256064, "Big Bang I"}, {1811815168, "Big Bang II"}, {-2102200192, "Big Bang III"}, {-1712032768, "Big Bang IV"},
{-232315824, "Big Bang Finisher"}, {-2070507264, "Spinning Bludgeon"}, {-914516160, "Spinning Follow-up"}, {86757720, "Overhead Smash I"},
{-32021162, "Spinning Side Smash"}, {885262336, "Spinning Strong Upswing"}, {1152969344, "Charged Follow-up"}, {1902907008, "Charged Upswing"},
{1534779136, "Charge"}, {-36407420, "Mighty Charge Upswing"}, {807319680, "Mighty Charge Slam"}, {-1057375552, "Charged Side Blow"},
{-1790485120, "Focus Blow: Earthquake"}, {12800, "Follow-up Spinslam"}, {-1804069376, "Focus Blow: Earthquake"}, {-1737516032, "Charged Step"},
{-2065308672, "Swing"}, {283916416, "Jumping Smash"},
-- Insect Glaive
{-116916480, "Rising Slash Combo"}, {-1983561600, "Reaping Slash"}, {2066406784, "Overhead Smash"}, {1401028864, "Leaping Slash"},
{-1195963904, "Dodge Slash"}, {-448700960, "Sidestep Slash"}, {-2131028480, "Wide Sweep"}, {-1303595904, "Vault"},
{-2129387136, "Jumping Advancing Slash"}, {239722048, "Jumping Slash"}, {816598592, "Kinsect Harvest Extract"},
{-587319424, "Tornado Slash"}, {378074688, "Strong Rising Slash Combo"}, {-1722159104, "Strong Reaping Slash"},
{45022504, "Strong Double Slash"}, {642398208, "Strong Wide Sweep"}, {-1429459328, "Strong Jumping Advancing Slash"},
{-922212864, "Strong Descending Slash"}, {1656416768, "Strong Descending Thrust"}, {4192, "Vaulting Dance"},
{1212529024, "Rising Spiral Slash"}, {569344320, "Kinsect: Mark Target"}, {632633472, "Midair Evade"},
{341413600, "Jumping Advancing Slash"}, {810620608, "Focus Thrust: Leaping Strike"}, {2014867968, "Double Slash"},
-- Lance
{-572647232, "Mid Thrust I"}, {-61029700, "Mid Thrust II"}, {31930464, "Mid Thrust III"}, {-752102912, "Triple Thrust"},
{-400225664, "High Thrust I"}, {-1128612864, "High Thrust II"}, {-1488459392, "High Thrust III"}, {24016, "Charge"},
{-227934736, "Wide Sweep"}, {-1607854080, "Shield Attack"}, {-1479629056, "Leaping Thrust"}, {1667857, "Guard Dash"},
{-1390119168, "Dash Attack"}, {1253815936, "Finishing Twin Thrust"}, {1210626816, "Dash Turn"},
{728592256, "Reverse Attack"}, {696236864, "Finishing Thrust"}, {22141902, "Advancing Jump"},
{-880486016, "Jumping Thrust Landing"}, {894130624, "Payback Thrust"}, {-1209497216, "Power Guard"},
{16092, "Grand Retribution Thrust"}, {-222102848, "Guard"}, {1728314368, "Focus Strike: Victory Thrust"},
{-1912639616, "Focus Strike: Victory Thrust"}, {-2112164096, "Guard Thrust"}
}

local function RebuildLookupTables()
    ActionGuideMap = {}
    MotionDataMap = {}
    local function addToGuideMap(tbl) for _, v in ipairs(tbl) do ActionGuideMap[v[1]] = v[3] or 1 end end
    local function addToMotionMap(tbl) for _, v in ipairs(tbl) do MotionDataMap[tostring(v[1]).."_"..tostring(v[2]).."_"..tostring(v[3])] = v[4] or 1 end end
    addToGuideMap(DefaultActionGuideTbl)
    addToGuideMap(CustomActionGuideTbl)
    addToMotionMap(DefaultMotionTbl)
    addToMotionMap(CustomMotionTbl)
end

-- ==========================================
-- Save / Load
-- ==========================================
local function saveSettings()
    local Sweat = {}
    Sweat.cur_lang_index = cur_lang_index
    Sweat.SWEATING_INCREASE_RATE = round3(SWEATING_INCREASE_RATE)
    Sweat.SWEATING_DECREASE_RATE = round3(SWEATING_DECREASE_RATE)
    Sweat.SWEATING_INCREASE_RATE_BATTLE = round3(SWEATING_INCREASE_RATE_BATTLE)
    Sweat.SWEATING_MOTIONDATA_INCREASE_RATE = round3(SWEATING_MOTIONDATA_INCREASE_RATE)
    Sweat.SWEATING_ACTIONGUIDE_INCREASE_RATE = round3(SWEATING_ACTIONGUIDE_INCREASE_RATE)
    Sweat.SWEATING_ENV_PASSIVE_RATE = round3(SWEATING_ENV_PASSIVE_RATE)
    
    Sweat.update_interval_seconds = round2(update_interval_seconds)
    Sweat.enable_stamina_sweating = enable_stamina_sweating
    Sweat.enable_motiondata_sweating = enable_motiondata_sweating
    Sweat.enable_actionguide_sweating = enable_actionguide_sweating
    Sweat.mod_enabled = mod_enabled
    Sweat.debug_enabled = debug_enabled
    Sweat.auto_equip_scan_enabled = auto_equip_scan_enabled -- Save Auto Scan Status
    Sweat.enable_face_sweating = enable_face_sweating
    Sweat.enable_body_sweating = enable_body_sweating
    Sweat.MAX_FACE_SWEATING = round3(MAX_FACE_SWEATING)
    Sweat.MIN_FACE_SWEATING = round3(MIN_FACE_SWEATING) 
    Sweat.MAX_BODY_SWEATING = round3(MAX_BODY_SWEATING)
    Sweat.MIN_BODY_SWEATING = round3(MIN_BODY_SWEATING) 
    Sweat.enable_roughness_control = enable_roughness_control
    Sweat.face_roughness_value = round3(face_roughness_value)
    Sweat.body_roughness_value = round3(body_roughness_value)
    
    -- Convert CustomMotionTbl to named-field format for saving
    local saved_motions = {}
    for _, entry in ipairs(CustomMotionTbl) do
        table_insert(saved_motions, {
            Bank = entry[1],
            Series = entry[2],
            Motion = entry[3],
            Multiplier = entry[4],
            Category = entry[5],
            Name = entry[6]
        })
    end
    Sweat.CustomMotionTbl = saved_motions
    Sweat.CustomActionGuideTbl = CustomActionGuideTbl
    
    local saved_stages = {}
    for k, v in pairs(EnvConfig.stage_settings) do
        saved_stages[tostring(k)] = {
            name = v.name,
            wet = round2(v.wet),
            dry = round2(v.dry)
        }
    end
    Sweat.EnvStageSettings = saved_stages
    
    local saved_weather = {}
    for i, w in ipairs(EnvConfig.weather) do 
        saved_weather[i] = { wet = round2(w.wet), dry = round2(w.dry) } 
    end
    Sweat.EnvWeatherSettings = saved_weather
    
local saved_time = {}
for stage_id, stage_tbl in pairs(EnvConfig.time_settings) do
    local s_key = tostring(stage_id)
    saved_time[s_key] = {}
    for t_idx, t_conf in pairs(stage_tbl) do
        saved_time[s_key][tostring(t_idx)] = {
            name = t_conf.name,
            wet = round2(t_conf.wet or 1.0),
            dry = round2(t_conf.dry or 1.0),
        }
    end
end
Sweat.EnvTimeSettings = saved_time

Sweat.pause_weather_in_safety_area = pause_weather_in_safety_area
Sweat.pause_weather_in_camp = pause_weather_in_camp
Sweat.force_wet_in_water = force_wet_in_water
Sweat.freeze_updates_during_blackout = freeze_updates_during_blackout
Sweat.freeze_updates_during_change_stage = freeze_updates_during_change_stage
Sweat.WATER_FORCE_WETNESS = round3(WATER_FORCE_WETNESS)
Sweat.WATER_WETNESS_CAP   = round3(WATER_WETNESS_CAP)

    json.dump_file("SweatSystem.json", Sweat)
    RebuildLookupTables() 
end

local function loadSettings()
    local Sweat = json.load_file("SweatSystem.json")
    if not Sweat then return end

    if Sweat.cur_lang_index then cur_lang_index = Sweat.cur_lang_index end
    if Sweat.SWEATING_INCREASE_RATE then SWEATING_INCREASE_RATE = round3(Sweat.SWEATING_INCREASE_RATE) end
    if Sweat.SWEATING_DECREASE_RATE then SWEATING_DECREASE_RATE = round3(Sweat.SWEATING_DECREASE_RATE) end
    if Sweat.SWEATING_INCREASE_RATE_BATTLE then SWEATING_INCREASE_RATE_BATTLE = round3(Sweat.SWEATING_INCREASE_RATE_BATTLE) end
    if Sweat.SWEATING_MOTIONDATA_INCREASE_RATE then SWEATING_MOTIONDATA_INCREASE_RATE = round3(Sweat.SWEATING_MOTIONDATA_INCREASE_RATE) end
    if Sweat.SWEATING_ACTIONGUIDE_INCREASE_RATE then SWEATING_ACTIONGUIDE_INCREASE_RATE = round3(Sweat.SWEATING_ACTIONGUIDE_INCREASE_RATE) end
    if Sweat.SWEATING_ENV_PASSIVE_RATE then SWEATING_ENV_PASSIVE_RATE = round3(Sweat.SWEATING_ENV_PASSIVE_RATE) end
    
    if Sweat.update_interval_seconds then update_interval_seconds = round2(Sweat.update_interval_seconds) end
    if Sweat.enable_stamina_sweating ~= nil then enable_stamina_sweating = Sweat.enable_stamina_sweating end
    if Sweat.enable_motiondata_sweating ~= nil then enable_motiondata_sweating = Sweat.enable_motiondata_sweating end
    if Sweat.enable_actionguide_sweating ~= nil then enable_actionguide_sweating = Sweat.enable_actionguide_sweating end
    if Sweat.mod_enabled ~= nil then mod_enabled = Sweat.mod_enabled end
    if Sweat.debug_enabled ~= nil then debug_enabled = Sweat.debug_enabled end
    if Sweat.auto_equip_scan_enabled ~= nil then auto_equip_scan_enabled = Sweat.auto_equip_scan_enabled end -- Load Auto Scan Status
    if Sweat.enable_face_sweating ~= nil then enable_face_sweating = Sweat.enable_face_sweating end
    if Sweat.enable_body_sweating ~= nil then enable_body_sweating = Sweat.enable_body_sweating end
    if Sweat.MAX_FACE_SWEATING then MAX_FACE_SWEATING = round3(Sweat.MAX_FACE_SWEATING) end
    if Sweat.MIN_FACE_SWEATING then MIN_FACE_SWEATING = round3(Sweat.MIN_FACE_SWEATING) end
    if Sweat.MAX_BODY_SWEATING then MAX_BODY_SWEATING = round3(Sweat.MAX_BODY_SWEATING) end
    if Sweat.MIN_BODY_SWEATING then MIN_BODY_SWEATING = round3(Sweat.MIN_BODY_SWEATING) end
    if Sweat.enable_roughness_control ~= nil then enable_roughness_control = Sweat.enable_roughness_control end
    if Sweat.face_roughness_value then face_roughness_value = round3(Sweat.face_roughness_value) end
    if Sweat.body_roughness_value then body_roughness_value = round3(Sweat.body_roughness_value) end
    
    -- Load CustomMotionTbl with validation and reconstruction (handles both old array and new object formats)
    if Sweat.CustomMotionTbl then 
        CustomMotionTbl = {}
        for _, entry in ipairs(Sweat.CustomMotionTbl) do
            local bank, series, motion, mult, cat, name
            
            -- Check if entry uses old array format or new object format
            if entry[1] ~= nil then
                -- Old array format: {bank, series, motion, multiplier, category, name}
                bank = entry[1]
                series = entry[2]
                motion = entry[3]
                mult = entry[4]
                cat = entry[5]
                name = entry[6]
            else
                -- New object format: {Bank=, Series=, Motion=, Multiplier=, Category=, Name=}
                bank = entry.Bank
                series = entry.Series
                motion = entry.Motion
                mult = entry.Multiplier
                cat = entry.Category
                name = entry.Name
            end
            
            if bank and series and motion then
                table_insert(CustomMotionTbl, {
                    bank,
                    series,
                    motion,
                    mult or 1,                      -- multiplier (default 1 if missing)
                    cat or "motion",                -- category (default "motion" if missing)
                    name or ""                      -- name (default "" if missing)
                })
            end
        end
        -- Clear edit buffers to reinitialize on next frame
        alias_edit_buffers = {}
    end
    
    -- Load CustomActionGuideTbl with validation
    if Sweat.CustomActionGuideTbl then 
        CustomActionGuideTbl = {}
        for _, entry in ipairs(Sweat.CustomActionGuideTbl) do
            if entry and entry[1] and entry[2] then
                table_insert(CustomActionGuideTbl, entry)
            end
        end
    end
    
    if Sweat.EnvStageSettings then 
        EnvConfig.stage_settings = {}
        for k, v in pairs(Sweat.EnvStageSettings) do
            local id = tonumber(k)
            if id then
                EnvConfig.stage_settings[id] = {
                    name = v.name,
                    wet = v.wet,
                    dry = v.dry
                }
            end
        end
    end
    
    if Sweat.EnvWeatherSettings then 
        for i, saved_w in ipairs(Sweat.EnvWeatherSettings) do
            if EnvConfig.weather[i] then
                EnvConfig.weather[i].wet = saved_w.wet
                EnvConfig.weather[i].dry = saved_w.dry
            end
        end
    end
    if Sweat.EnvTimeSettings then
        EnvConfig.time_settings = {}
        for sk, stage_tbl in pairs(Sweat.EnvTimeSettings) do
            local sid = tonumber(sk)
            if sid then
                EnvConfig.time_settings[sid] = {}
                for tk, tconf in pairs(stage_tbl) do
                    local tid = tonumber(tk)
                    if tid ~= nil then
                        EnvConfig.time_settings[sid][tid] = {
                            name = tconf.name,
                            wet = tconf.wet,
                            dry = tconf.dry
                        }
                    end
                end
            end
        end
    end

        -- Auto-generate missing time-of-day presets for all known stages
    EnsureAllTimeSettings()

if Sweat.pause_weather_in_safety_area ~= nil then pause_weather_in_safety_area = Sweat.pause_weather_in_safety_area end
    if Sweat.pause_weather_in_camp ~= nil then pause_weather_in_camp = Sweat.pause_weather_in_camp end
    if Sweat.force_wet_in_water ~= nil then force_wet_in_water = Sweat.force_wet_in_water end
    if Sweat.freeze_updates_during_blackout ~= nil then freeze_updates_during_blackout = Sweat.freeze_updates_during_blackout end
    if Sweat.freeze_updates_during_change_stage ~= nil then freeze_updates_during_change_stage = Sweat.freeze_updates_during_change_stage end
    if Sweat.WATER_FORCE_WETNESS then WATER_FORCE_WETNESS = round3(Sweat.WATER_FORCE_WETNESS) end
    if Sweat.WATER_WETNESS_CAP   then WATER_WETNESS_CAP   = round3(Sweat.WATER_WETNESS_CAP) end


    RebuildLookupTables()
end

-- ==========================================
-- Game Data Reading
-- ==========================================
local function GetHunterData()
    if not _M.HunterData.Hunter then
        _M.HunterData.Hunter = Core.GetPlayerCharacter()
    end
    local hunter = _M.HunterData.Hunter
    if Core.IsLoading() or not hunter then return false end
    if not _M.HunterData.Stamina then _M.HunterData.Stamina = hunter:get_HunterStamina() end
    if _M.HunterData.Stamina then _M.HunterData.StaminaData = _M.HunterData.Stamina:get_Stamina() end
    _M.HunterData.IsInBattle = Core.IsInBattle()
    _M.HunterData.CurrentActionName = Core.GetCurrentActionName()
    local actionController = hunter:get_BaseActionController()
    if actionController then
        local currentAction = actionController:get_CurrentAction()
        local guideID = nil
        if currentAction then guideID = currentAction._ActionGuideID or nil end
        _M.HunterData.CurrentActionGuideID = (guideID and guideID ~= -1) and guideID or nil
    end
    return true
end

local function GetPlayerMotionAndActionData()
    local motion_data = Core.GetPlayerMotionData()
    if motion_data then _M.HunterData.MotionData = motion_data end
    local sub_action_data = Core.GetPlayerSubActionData()
    if sub_action_data then _M.HunterData.SubActionData = sub_action_data end
end

-- ==========================================
-- ENVIRONMENT LOGIC
-- ==========================================
-- ==========================================
-- Helpers: Read Location & Time state
-- ==========================================
local function UpdateLocationState()
    local eff = sdk.get_managed_singleton(app_effect_manager_class)
    if not eff then
        LocationState.in_safety_area = false
        LocationState.in_camp = false
        LocationState.in_water = false
        LocationState.is_blackout = false
        LocationState.is_change_stage_or_env = false
        return
    end

    -- All fields are optional (may change between builds). Read safely.
    local v = eff:get_field("_IsInSafetyArea"); if v ~= nil then LocationState.in_safety_area = v end
    v = eff:get_field("_InCamp"); if v ~= nil then LocationState.in_camp = v end
    v = eff:get_field("_InWater"); if v ~= nil then LocationState.in_water = v end
    v = eff:get_field("_IsBlackout"); if v ~= nil then LocationState.is_blackout = v end
    v = eff:get_field("_IsChangeStageOrEnv"); if v ~= nil then LocationState.is_change_stage_or_env = v end
end

local function UpdateTimeZoneState()
    local tz = sdk.get_managed_singleton(time_zone_manager_class)
    if not tz then
        EnvConfig.current_time_zone_index = -1
        EnvConfig.current_time_zone_name_display = ""
        return
    end

    local idx = tz:get_field("_CurrentTimeZoneIndex")
    if idx == nil then
        -- Fallback: some builds only expose _CurrentTimeZone (enum) and not the index.
        local enum_obj = tz:get_field("_CurrentTimeZone")
        if enum_obj ~= nil then
            idx = tonumber(enum_obj)
        end
    end

    if idx == nil then idx = -1 end
    EnvConfig.current_time_zone_index = idx
    EnvConfig.current_time_zone_name_display = TimeZoneNameMap[idx] or ("Unknown(" .. tostring(idx) .. ")")
end

function UpdateEnvironmentState()
    local env_man = sdk.get_managed_singleton(env_manager_class)
    if not env_man then return end

    UpdateLocationState()
    UpdateTimeZoneState()

    local stage_id = env_man:get_field("_CurrentStage")
    if stage_id then
        EnvConfig.current_stage_id = stage_id
    end

    -- --------------------------
    -- Stage (environment) multiplier
    -- --------------------------
    local env_wet = 1.0
    local env_dry = 1.0

    local s_conf = EnvConfig.stage_settings[EnvConfig.current_stage_id]
    if s_conf then
        env_wet = env_wet * s_conf.wet
        env_dry = env_dry * s_conf.dry
        EnvConfig.current_stage_name_display = s_conf.name
    else
        EnvConfig.current_stage_name_display = nil
    end

    -- --------------------------
    -- Time-of-day multiplier (optional, per stage)
    -- --------------------------
    local time_conf_stage = EnvConfig.time_settings[EnvConfig.current_stage_id]
    if time_conf_stage then
        local t_conf = time_conf_stage[EnvConfig.current_time_zone_index]
        if t_conf then
            env_wet = env_wet * (t_conf.wet or 1.0)
            env_dry = env_dry * (t_conf.dry or 1.0)
        end
    end

    EnvConfig.env_wet_mult = env_wet
    EnvConfig.env_dry_mult = env_dry

    -- --------------------------
    -- Weather multiplier
    -- --------------------------
    local weather_wet = 1.0
    local weather_dry = 1.0

    for _, w_conf in ipairs(EnvConfig.weather) do
        w_conf.is_active = false
        local field_obj = env_man:get_field(w_conf.field)
        if field_obj then
            local is_active = field_obj:call("get_IsActive")
            if is_active then
                w_conf.is_active = is_active
                weather_wet = weather_wet * w_conf.wet
                weather_dry = weather_dry * w_conf.dry
            end
        end
    end

    EnvConfig.weather_wet_mult = weather_wet
    EnvConfig.weather_dry_mult = weather_dry

    -- --------------------------
    -- Final totals (weather can be paused in safety area / camp)
    -- --------------------------
    local final_weather_wet = weather_wet
    local final_weather_dry = weather_dry

    if (pause_weather_in_safety_area and LocationState.in_safety_area) or (pause_weather_in_camp and LocationState.in_camp) then
        final_weather_wet = 1.0
        final_weather_dry = 1.0
    end

    EnvConfig.total_wet_mult = env_wet * final_weather_wet
    EnvConfig.total_dry_mult = env_dry * final_weather_dry
end

-- ==========================================
-- Logic: Update Sweating
-- ==========================================
local function updateSweating()
    local current_stamina = _M.HunterData.StaminaData or -1
    local time_multiplier = math_max(0.01, update_interval_seconds)

    -- Freeze during blackout / loading transitions to avoid sudden jumps
    if (freeze_updates_during_blackout and LocationState.is_blackout)
        or (freeze_updates_during_change_stage and LocationState.is_change_stage_or_env) then
        last_stamina_value = current_stamina
        return
    end

    -- =========================================================
    -- In Water: force wetness instantly (handled also by on_frame)
    -- =========================================================
    if force_wet_in_water and LocationState.in_water then
        post_water_drying = false

        local cap = math_max(0.0, WATER_WETNESS_CAP)
        local target = math_min(math_max(0.0, WATER_FORCE_WETNESS), cap)

        face_sweating_value = target
        body_sweating_value = target

        last_stamina_value = current_stamina
        return
    end

    -- =========================================================
    -- After leaving water: ONLY dry until back to normal max
    -- No increases at all during this period.
    -- =========================================================
    if post_water_drying then
        -- 如果因为改设置等原因已经 <= 普通上限，就结束该模式（下一次tick再恢复正常计算）
        if (face_sweating_value <= MAX_FACE_SWEATING) and (body_sweating_value <= MAX_BODY_SWEATING) then
            post_water_drying = false
            last_stamina_value = current_stamina
            return
        end

        local final_dry_mult = EnvConfig.total_dry_mult
        local dec_val = SWEATING_DECREASE_RATE * final_dry_mult * time_multiplier

        local new_face = face_sweating_value - dec_val
        local new_body = body_sweating_value - dec_val

        -- Respect minimum limits
        new_face = math_max(MIN_FACE_SWEATING, new_face)
        new_body = math_max(MIN_BODY_SWEATING, new_body)

        -- When crossing normal max, snap to normal max and end drying-only mode
        local done_face = (face_sweating_value <= MAX_FACE_SWEATING)
        local done_body = (body_sweating_value <= MAX_BODY_SWEATING)

        if not done_face and new_face <= MAX_FACE_SWEATING then
            new_face = MAX_FACE_SWEATING
            done_face = true
        end
        if not done_body and new_body <= MAX_BODY_SWEATING then
            new_body = MAX_BODY_SWEATING
            done_body = true
        end

        face_sweating_value = new_face
        body_sweating_value = new_body

        if done_face and done_body then
            post_water_drying = false
        end

        last_stamina_value = current_stamina
        return
    end

    -- =========================================================
    -- Normal sweating logic
    -- =========================================================
    local final_wet_mult = EnvConfig.total_wet_mult
    local final_dry_mult = EnvConfig.total_dry_mult

    -- Get current motion and determine global sweat multiplier
    local motion_id = _M.HunterData.MotionData.MotionID or 0
    local sub_action_motion_id = _M.HunterData.SubActionData.MotionID or 0
    local sub_action_motion_bank_id = _M.HunterData.SubActionData.MotionBankID or 0
    local motion_key = tostring(sub_action_motion_bank_id) .. "_" .. tostring(sub_action_motion_id) .. "_" .. tostring(motion_id)
    
    -- Get multiplier from tracked motions (only if motion data sweating is enabled)
    local motion_sweat_mult = 1.0
    if enable_motiondata_sweating then
        motion_sweat_mult = MotionDataMap[motion_key] or 1.0
    end
    
    -- If motion has multiplier 0, skip all sweat increases (only decreases apply)
    if motion_sweat_mult == 0 then
        goto skip_increases
    end

    if enable_stamina_sweating and current_stamina < last_stamina_value then
        local val = SWEATING_INCREASE_RATE * final_wet_mult * time_multiplier * motion_sweat_mult
        face_sweating_value = face_sweating_value + val
        body_sweating_value = body_sweating_value + val
    end

    if enable_motiondata_sweating then
        local motion_id = _M.HunterData.MotionData.MotionID or 0
        local sub_action_motion_id = _M.HunterData.SubActionData.MotionID or 0
        local sub_action_motion_bank_id = _M.HunterData.SubActionData.MotionBankID or 0
        local key = tostring(sub_action_motion_bank_id) .. "_" .. tostring(sub_action_motion_id) .. "_" .. tostring(motion_id)
        local mult = MotionDataMap[key]
        if mult then
            local val = (SWEATING_MOTIONDATA_INCREASE_RATE * mult) * final_wet_mult * time_multiplier * motion_sweat_mult
            face_sweating_value = face_sweating_value + val
            body_sweating_value = body_sweating_value + val
        end
    end

    if enable_actionguide_sweating then
        local action_guide_id = _M.HunterData.CurrentActionGuideID
        if action_guide_id then
            local mult = ActionGuideMap[action_guide_id]
            if mult then
                local val = (SWEATING_ACTIONGUIDE_INCREASE_RATE * mult) * final_wet_mult * time_multiplier * motion_sweat_mult
                face_sweating_value = face_sweating_value + val
                body_sweating_value = body_sweating_value + val
            end
        end
    end

    if _M.HunterData.IsInBattle then
        local val = SWEATING_INCREASE_RATE_BATTLE * final_wet_mult * time_multiplier * motion_sweat_mult
        face_sweating_value = face_sweating_value + val
        body_sweating_value = body_sweating_value + val
    end

    if final_wet_mult > 1.0 then
        local passive_env_increase = SWEATING_ENV_PASSIVE_RATE * (final_wet_mult - 1.0) * time_multiplier * motion_sweat_mult
        face_sweating_value = face_sweating_value + passive_env_increase
        body_sweating_value = body_sweating_value + passive_env_increase
    end

    ::skip_increases::
    -- Decreases always apply (regardless of motion multiplier)
    local dec_val = SWEATING_DECREASE_RATE * final_dry_mult * time_multiplier
    face_sweating_value = face_sweating_value - dec_val
    body_sweating_value = body_sweating_value - dec_val

    if debug_lock_sweat then
        face_sweating_value = debug_sweat_val
        body_sweating_value = debug_sweat_val
    end

    face_sweating_value = math_max(MIN_FACE_SWEATING, math_min(MAX_FACE_SWEATING, face_sweating_value))
    body_sweating_value = math_max(MIN_BODY_SWEATING, math_min(MAX_BODY_SWEATING, body_sweating_value))
    last_stamina_value = current_stamina
end

-- ==========================================
-- Visuals & Mesh Detection
-- ==========================================
local getComponent = sdk.find_type_definition('via.GameObject'):get_method('getComponent(System.Type)')
local function get_gameobject_component(gameObject, componentType)
    if not gameObject then return nil end
    return getComponent:call(gameObject, sdk.typeof(componentType))
end

-- Helper for Auto Scan: Calculate a unique string based on current Mesh Pointers
local function GetCurrentMeshHash()
    local hash_str = ""
    local PlayerMgr = sdk.get_managed_singleton("app.PlayerManager")
    if not PlayerMgr then return "" end
    local PlayerMaster = PlayerMgr:getMasterPlayer()
    if not PlayerMaster then return "" end
    local PlayerObj = PlayerMaster:get_Object()
    if not PlayerObj then return "" end

    local transform = get_gameobject_component(PlayerObj, 'via.Transform')
    if not transform then return "" end

    local child = transform:get_Child()
    while child do
        local go = child:get_GameObject()
        if go then
            local mesh = get_gameobject_component(go, 'via.render.Mesh')
            if mesh then
                hash_str = hash_str .. tostring(mesh)
            end
        end
        child = child:get_Next()
    end
    
    local faceObj = transform:find('Player_Face')
    if faceObj then
        local faceMesh = get_gameobject_component(faceObj, 'via.render.Mesh')
        if faceMesh then
             hash_str = hash_str .. tostring(faceMesh)
        end
    end

    return hash_str
end

local function ScanAndCacheMaterials()
    MaterialCache.FaceMaterials = {}
    MaterialCache.BodyMaterials = {}
    MaterialCache.IsValid = false

    local PlayerMgr = sdk.get_managed_singleton("app.PlayerManager")
    if not PlayerMgr then return end
    
    local PlayerMaster = PlayerMgr:getMasterPlayer()
    if not PlayerMaster then return end
    
    local PlayerInfo = PlayerMgr:getMasterPlayer():get_field('<Character>k__BackingField')
    if not PlayerInfo or PlayerInfo:get_IsSetUp() ~= true then return end

    local PlayerObj = PlayerMaster:get_Object()
    if not PlayerObj then return end

    local transform = get_gameobject_component(PlayerObj, 'via.Transform')
    if not transform then return end
    
    local faceObj = transform:find('Player_Face')
    local bodyObj = transform 

    if faceObj then
        local faceMesh = get_gameobject_component(faceObj, 'via.render.Mesh')
        if faceMesh then
            local count = faceMesh:get_MaterialNum()
            if count then
                for i = 0, count - 1 do
                    local mat_name = faceMesh:getMaterialName(i)
                    if mat_name == "face" or mat_name == "Face" then
                        table_insert(MaterialCache.FaceMaterials, { mesh = faceMesh, index = i })
                    end
                end
            end
        end
    end

    local child = bodyObj:get_Child()
    while child do
        local go = child:get_GameObject()
        if go then
            local mesh = get_gameobject_component(go, 'via.render.Mesh')
            if mesh then
                local count = mesh:get_MaterialNum()
                if count then
                    for i = 0, count - 1 do
                        local mat_name = mesh:getMaterialName(i)
                        if (mat_name == "skin" or mat_name == "skin_UseSC" or mat_name == "Skin" or mat_name == "Body" or mat_name == "FNMNipples") then
                            table_insert(MaterialCache.BodyMaterials, { mesh = mesh, index = i })
                        end
                    end
                end
            end
        end
        child = child:get_Next()
    end

    MaterialCache.IsValid = true
    applied_face_sweat = -1; applied_body_sweat = -1; applied_face_rough = -1; applied_body_rough = -1
    
    -- Sync Hash after scan to prevent loop
    last_mesh_hash = GetCurrentMeshHash()
end

local function ApplyWetnessToPlayerCached()
    if not MaterialCache.IsValid then ScanAndCacheMaterials() if not MaterialCache.IsValid then return end end
    local threshold = 0.001 

    if enable_face_sweating then
        local update_sweat = math_abs(face_sweating_value - applied_face_sweat) > threshold
        local update_rough = enable_roughness_control and (math_abs(face_roughness_value - applied_face_rough) > threshold)
        if update_sweat or update_rough then
            for _, entry in ipairs(MaterialCache.FaceMaterials) do
                if sdk.is_managed_object(entry.mesh) then
                    if update_sweat then entry.mesh:setMaterialFloat(entry.index, 69, face_sweating_value) end
                    if update_rough then entry.mesh:setMaterialFloat(entry.index, 38, face_roughness_value) end
                else MaterialCache.IsValid = false; return end
            end
            if update_sweat then applied_face_sweat = face_sweating_value end
            if update_rough then applied_face_rough = face_roughness_value end
        end
    end

    if enable_body_sweating then
        local update_sweat = math_abs(body_sweating_value - applied_body_sweat) > threshold
        local update_rough = enable_roughness_control and (math_abs(body_roughness_value - applied_body_rough) > threshold)
        if update_sweat or update_rough then
            for _, entry in ipairs(MaterialCache.BodyMaterials) do
                if sdk.is_managed_object(entry.mesh) then
                    if update_sweat then entry.mesh:setMaterialFloat(entry.index, 53, body_sweating_value) end
                    if update_rough then entry.mesh:setMaterialFloat(entry.index, 25, body_roughness_value) end
                else MaterialCache.IsValid = false; return end
            end
            if update_sweat then applied_body_sweat = body_sweating_value end
            if update_rough then applied_body_rough = body_roughness_value end
        end
    end
end

-- ==========================================
-- Debug History
-- ==========================================
local function UpdateActionHistory()
    if not _M.HunterData.MotionData then return end
    local motion_id = _M.HunterData.MotionData.MotionID or 0
    local sub_action_motion_id = _M.HunterData.SubActionData and _M.HunterData.SubActionData.MotionID or 0
    local sub_action_motion_bank_id = _M.HunterData.SubActionData and _M.HunterData.SubActionData.MotionBankID or 0
    local guide_id = _M.HunterData.CurrentActionGuideID
    local action_name = _M.HunterData.CurrentActionName or "Unknown"

    local entry = nil
    if guide_id and guide_id ~= -1 and guide_id ~= last_captured_guide_id then
        last_captured_guide_id = guide_id
        entry = { type = "ActionGuide", id = guide_id, name = action_name }
    elseif motion_id ~= last_captured_motion_id then
        last_captured_motion_id = motion_id
        entry = { type = "MotionData", bank = sub_action_motion_bank_id, sub = sub_action_motion_id, motion = motion_id }
    end
    if entry then
        table_insert(action_history, 1, entry)
        if #action_history > 10 then table_remove(action_history) end 
    end
end

local function IsInCustomMotion(bank, sub, mot)
    local key = tostring(bank) .. "_" .. tostring(sub) .. "_" .. tostring(mot)
    return MotionDataMap[key] ~= nil
end
local function IsInCustomGuide(id) return ActionGuideMap[id] ~= nil end

-- ==========================================
-- UI Rendering
-- ==========================================
re.on_draw_ui(function()
    if imgui.tree_node(T("settings")) then
        local changed, new_index = imgui.combo("Language / 语言", cur_lang_index, {"English", "中文"})
        if changed then cur_lang_index = new_index end

        imgui.spacing()
        _, debug_enabled = imgui.checkbox(T("debug_mode"), debug_enabled)

        if debug_enabled then
            imgui.text_colored(T("debug_values"), 0xFF00FFFF)
            imgui.text(string_format(T("debug_val_fmt"), face_sweating_value, body_sweating_value))
            imgui.text(string_format(T("debug_env_wet"), EnvConfig.total_wet_mult))
            imgui.text(string_format(T("debug_env_dry"), EnvConfig.total_dry_mult))
            
            local status = auto_equip_scan_enabled and T("env_weather_active") or T("env_weather_inactive")
            imgui.text_colored(T("auto_scan_info") .. status, 0xFFFFFF00)
            
            imgui.spacing()
            _, debug_lock_sweat = imgui.checkbox(T("debug_lock"), debug_lock_sweat)
            if debug_lock_sweat then
                local c, v = imgui.slider_float(T("debug_lock_val"), debug_sweat_val, 0.0, 2.0, "%.3f")
                if c then debug_sweat_val = round3(v) end
            end

            imgui.spacing()
            -- [NEW SWITCH]
            _, auto_equip_scan_enabled = imgui.checkbox(T("auto_scan_chk"), auto_equip_scan_enabled)
            -- [RESCAN BUTTON]
            if imgui.button(T("btn_recan")) then ScanAndCacheMaterials() end

            imgui.separator()
            is_history_expanded = imgui.tree_node(T("hist_title"))
            if is_history_expanded then
                if notification_timer > 0 then
                    imgui.text_colored(notification_msg, 0xFF00FF00)
                    notification_timer = notification_timer - 1
                end
                if imgui.button(T("hist_clear")) then action_history = {} end
                imgui.separator()
                for i, action in ipairs(action_history) do
                    imgui.push_id(i)
                    if action.type == "ActionGuide" then
                        imgui.text(string_format("Guide: %d (%s)", action.id, action.name))
                        if imgui.button(T("add_to_guide")) then
                            if not IsInCustomGuide(action.id) then
                                table_insert(CustomActionGuideTbl, {action.id, action.name, 1, "guide"})
                                notification_msg = T("added_msg"); notification_timer = 120; saveSettings()
                            else notification_msg = T("exists_msg"); notification_timer = 120 end
                        end
                    elseif action.type == "MotionData" then
                        imgui.text(string_format("Motion: B:%d S:%d M:%d", action.bank, action.sub, action.motion))
                        if imgui.button(T("add_to_motion")) then
                            if not IsInCustomMotion(action.bank, action.sub, action.motion) then
                                table_insert(CustomMotionTbl, {action.bank, action.sub, action.motion, 1, "motion"})
                                notification_msg = T("added_msg"); notification_timer = 120; saveSettings()
                            else notification_msg = T("exists_msg"); notification_timer = 120 end
                        end
                    end
                    imgui.separator()
                    imgui.pop_id()
                end
                imgui.tree_pop()
            end
        else
            is_history_expanded = false
        end
        
        imgui.separator()
        if imgui.tree_node(T("custom_actions")) then
            local has_any = false
            if #CustomActionGuideTbl > 0 then
                has_any = true
                imgui.text_colored(T("custom_guide_list"), 0xFFFFFF00)
                for i, v in ipairs(CustomActionGuideTbl) do
                    imgui.push_id("cg"..i)
                    imgui.text(string_format("%s %s (ID:%d)", T("type_guide"), v[2], v[1]))
                    imgui.same_line()
                    if imgui.button(T("btn_delete")) then table_remove(CustomActionGuideTbl, i); saveSettings() end
                    imgui.pop_id()
                end
                imgui.separator()
            end
            if #CustomMotionTbl > 0 then
                has_any = true
                imgui.text_colored(T("custom_motion_list"), 0xFFFFFF00)
                for i, v in ipairs(CustomMotionTbl) do
                    imgui.push_id("cm"..i)
                    local type_str = (v[5] == "stamina") and T("type_stamina") or T("type_motion")
                    local display_name = (v[6] and v[6] ~= "") and v[6] or string_format("Motion_%d", v[3])
                    
                    -- Initialize edit buffer if not present
                    if alias_edit_buffers[i] == nil then
                        alias_edit_buffers[i] = v[6] or ""
                    end
                    
                    if imgui.tree_node(display_name.."##cm"..i) then
                        imgui.same_line()
                        if imgui.button(T("btn_delete").."##cm_del"..i) then 
                            table_remove(CustomMotionTbl, i)
                            alias_edit_buffers[i] = nil
                            saveSettings()
                            imgui.tree_pop()
                            imgui.pop_id()
                            goto continue_custom_motion
                        end
                        
                        imgui.text(string_format("%s B:%d S:%d M:%d", type_str, v[1], v[2], v[3]))
                        
                        local c_mult, v_mult = imgui.slider_float("Multiplier##cm_mult"..i, v[4], 0.0, 3.0, "%.2f")
                        if c_mult then v[4] = round2(v_mult); saveSettings() end
                        
                        local c_alias, v_alias = imgui.input_text("Alias##cm_alias"..i, alias_edit_buffers[i])
                        if c_alias then alias_edit_buffers[i] = v_alias end
                        
                        imgui.same_line()
                        if imgui.button("Rename##cm_rename"..i) then 
                            v[6] = alias_edit_buffers[i]
                            saveSettings()
                        end
                        
                        imgui.tree_pop()
                    end
                    imgui.pop_id()
                    ::continue_custom_motion::
                end
            end
            if not has_any then imgui.text_colored(T("no_custom_actions"), 0xFF888888) end
            imgui.tree_pop()
        end

        imgui.separator()
        _, mod_enabled = imgui.checkbox(T("enable_mod"), mod_enabled)
        
        -- GLOBAL PARAMS
        if imgui.tree_node(T("global_params")) then
            imgui.text(T("refresh_interval"))
            local c_int, v_int = imgui.slider_float("##UpdateInterval", update_interval_seconds, 0.05, 5.0, "%.2f")
            if c_int then update_interval_seconds = round2(v_int) end
            imgui.text_colored(T("refresh_desc"), 0xFFAAAAAA)
            imgui.separator()
            imgui.text(T("rate_stamina")); local c1, v1 = imgui.slider_float("##IncStamina", SWEATING_INCREASE_RATE, SWEATING_LIMIT_MIN, SWEATING_LIMIT_MAX, "%.3f"); if c1 then SWEATING_INCREASE_RATE = round3(v1) end
            imgui.text(T("rate_action")); local c2, v2 = imgui.slider_float("##IncGuide", SWEATING_ACTIONGUIDE_INCREASE_RATE, SWEATING_LIMIT_MIN, SWEATING_LIMIT_MAX, "%.3f"); if c2 then SWEATING_ACTIONGUIDE_INCREASE_RATE = round3(v2) end
            imgui.text(T("rate_motion")); local c3, v3 = imgui.slider_float("##IncMotion", SWEATING_MOTIONDATA_INCREASE_RATE, SWEATING_LIMIT_MIN, SWEATING_LIMIT_MAX, "%.3f"); if c3 then SWEATING_MOTIONDATA_INCREASE_RATE = round3(v3) end
            imgui.text(T("rate_decrease")); local c4, v4 = imgui.slider_float("##DecRate", SWEATING_DECREASE_RATE, SWEATING_LIMIT_MIN, SWEATING_LIMIT_MAX, "%.3f"); if c4 then SWEATING_DECREASE_RATE = round3(v4) end
            imgui.text(T("rate_battle")); local c5, v5 = imgui.slider_float("##IncBattle", SWEATING_INCREASE_RATE_BATTLE, SWEATING_LIMIT_MIN, SWEATING_LIMIT_MAX, "%.3f"); if c5 then SWEATING_INCREASE_RATE_BATTLE = round3(v5) end
            imgui.tree_pop()
        end

        -- ===========================
        -- ENVIRONMENT SETTINGS
        -- ===========================
        if imgui.tree_node(T("env_params")) then
            imgui.text(T("rate_env_passive"))
            local cp, vp = imgui.slider_float("##EnvPassive", SWEATING_ENV_PASSIVE_RATE, 0.0, 0.1, "%.3f")
            if cp then SWEATING_ENV_PASSIVE_RATE = round3(vp) end
            imgui.text_colored(T("desc_env_passive"), 0xFFAAAAAA)
-- ===========================
-- LOCATION & TIME OVERRIDES
-- ===========================
if imgui.tree_node(T("loc_time")) then
    _, pause_weather_in_safety_area = imgui.checkbox(T("opt_pause_weather_safe"), pause_weather_in_safety_area)
    _, pause_weather_in_camp = imgui.checkbox(T("opt_pause_weather_camp"), pause_weather_in_camp)
    _, force_wet_in_water = imgui.checkbox(T("opt_force_wet_in_water"), force_wet_in_water)
    _, freeze_updates_during_blackout = imgui.checkbox(T("opt_freeze_blackout"), freeze_updates_during_blackout)
    _, freeze_updates_during_change_stage = imgui.checkbox(T("opt_freeze_loading"), freeze_updates_during_change_stage)
    
    if force_wet_in_water then
    -- 水下上限（可以超过普通 MAX_FACE/MAX_BODY）
    local cc, vc = imgui.slider_float(T("opt_water_wet_cap"), WATER_WETNESS_CAP, 0.0, 5.0, "%.3f")
    if cc then
        WATER_WETNESS_CAP = round3(vc)
        if WATER_WETNESS_CAP < 0.0 then WATER_WETNESS_CAP = 0.0 end
        if WATER_FORCE_WETNESS > WATER_WETNESS_CAP then
            WATER_FORCE_WETNESS = WATER_WETNESS_CAP
        end
    end

    -- 水下拉满值（进入水下会立刻设成这个值）
    local ct, vt = imgui.slider_float(T("opt_water_force_wetness"), WATER_FORCE_WETNESS, 0.0, WATER_WETNESS_CAP, "%.3f")
    if ct then
        WATER_FORCE_WETNESS = round3(vt)
    end

    if debug_enabled then
        imgui.text(string_format("PostWaterDrying: %s", tostring(post_water_drying)))
    end
end

    imgui.separator()
    imgui.text(T("lbl_time_zone") .. EnvConfig.current_time_zone_name_display .. " (" .. tostring(EnvConfig.current_time_zone_index) .. ")")

    if debug_enabled then
        imgui.text(string_format("SafetyArea: %s | Camp: %s | Water: %s | Blackout: %s | Loading: %s",
            tostring(LocationState.in_safety_area), tostring(LocationState.in_camp), tostring(LocationState.in_water),
            tostring(LocationState.is_blackout), tostring(LocationState.is_change_stage_or_env)))
        imgui.text(string_format("EnvMult: wet=%.2f dry=%.2f | WeatherMult: wet=%.2f dry=%.2f",
            EnvConfig.env_wet_mult, EnvConfig.env_dry_mult, EnvConfig.weather_wet_mult, EnvConfig.weather_dry_mult))
    end

    -- Time-of-day tuning for current stage (optional)
    local stage_tbl = EnvConfig.time_settings[EnvConfig.current_stage_id]
    if not stage_tbl then
        if imgui.button(T("btn_create_time_conf")) then
            -- Create presets for the current stage (5 slots)
            EnsureTimeSettingsForStage(EnvConfig.current_stage_id)
        end
        imgui.same_line()
        if imgui.button(T("btn_create_all_time_conf")) then
            -- Create presets for every stage we know
            EnsureAllTimeSettings()
        end
    else
        -- Quick actions
        if imgui.button(T("btn_fill_missing_time_conf")) then
            EnsureTimeSettingsForStage(EnvConfig.current_stage_id)
        end
        imgui.same_line()
        if imgui.button(T("btn_create_all_time_conf")) then
            EnsureAllTimeSettings()
        end
        imgui.text(T("time_conf_for_stage"))
        for i = 0, 4 do
            local t = stage_tbl[i]
            if t then
                imgui.text(t.name .. " (" .. tostring(i) .. ")")
                imgui.text_colored(T("time_wet_mult_desc"), 0xFFAAAAAA)
                local ctw, vtw = imgui.slider_float("##TimeWet"..tostring(i), t.wet, 0.1, 3.0, "%.2f")
                if ctw then t.wet = round2(vtw) end
                imgui.text_colored(T("time_dry_mult_desc"), 0xFFAAAAAA)
                local ctd, vtd = imgui.slider_float("##TimeDry"..tostring(i), t.dry, 0.1, 3.0, "%.2f")
                if ctd then t.dry = round2(vtd) end
            end
        end
    end

    imgui.tree_pop()
end

imgui.separator()

            imgui.separator()

            local display_name = EnvConfig.current_stage_name_display
            if not display_name then
                display_name = string_format("%s (ID: %d)", T("status_unconfigured"), EnvConfig.current_stage_id)
            end
            
            imgui.text_colored(display_name, 0xFF00FFFF)
            imgui.text(T("lbl_cur_stage_id") .. tostring(EnvConfig.current_stage_id))
            
            imgui.separator()
            if imgui.tree_node(T("env_cur_stage")) then
                if EnvConfig.current_stage_id ~= -1 then
                    local s_conf = EnvConfig.stage_settings[EnvConfig.current_stage_id]
                    if not s_conf then
                        if imgui.button(T("env_create")) then
                            EnvConfig.stage_settings[EnvConfig.current_stage_id] = { name = "Stage " .. EnvConfig.current_stage_id, wet = 1.0, dry = 1.0 }
                        end
                    else
                        local changed_n, new_name = imgui.input_text(T("env_rename"), s_conf.name)
                        if changed_n then s_conf.name = new_name end
                        _, s_conf.wet = imgui.slider_float(T("env_wet_mult"), s_conf.wet, 0.0, 5.0, "%.2f")
                        imgui.text_colored(T("env_wet_mult_desc"), 0xFFAAAAAA)
                        _, s_conf.dry = imgui.slider_float(T("env_dry_mult"), s_conf.dry, 0.0, 5.0, "%.2f")
                        imgui.text_colored(T("env_dry_mult_desc"), 0xFFAAAAAA)
                        if imgui.button(T("btn_delete")) then EnvConfig.stage_settings[EnvConfig.current_stage_id] = nil end
                    end
                else
                    imgui.text(T("msg_wait_stage"))
                end
                imgui.tree_pop()
            end

            if imgui.tree_node(T("env_weather")) then
                for _, w in ipairs(EnvConfig.weather) do
                    if w.is_active then imgui.push_style_color(0, 0xFF00FF00) end
                    local w_name = T(w.key or "w_unknown")
                    if imgui.tree_node(w_name) then
                        if w.is_active then imgui.pop_style_color() end
                        imgui.text(w.is_active and T("env_weather_active") or T("env_weather_inactive"))
                        _, w.wet = imgui.slider_float(T("env_wet_mult"), w.wet, 0.0, 10.0, "%.2f")
                        imgui.text_colored(T("env_wet_mult_weather_desc"), 0xFFAAAAAA)
                        _, w.dry = imgui.slider_float(T("env_dry_mult"), w.dry, 0.0, 10.0, "%.2f")
                        imgui.text_colored(T("env_dry_mult_weather_desc"), 0xFFAAAAAA)
                        imgui.tree_pop()
                    else
                        if w.is_active then imgui.pop_style_color() end
                    end
                end
                imgui.tree_pop()
            end
            imgui.tree_pop()
        end

        imgui.separator()
        _, enable_stamina_sweating = imgui.checkbox(T("enable_stamina"), enable_stamina_sweating)
        _, enable_actionguide_sweating = imgui.checkbox(T("enable_action"), enable_actionguide_sweating)
        _, enable_motiondata_sweating = imgui.checkbox(T("enable_motion"), enable_motiondata_sweating)

        imgui.separator()
        imgui.text(T("body_parts"))
        _, enable_face_sweating = imgui.checkbox(T("face_chk"), enable_face_sweating)
        _, MAX_FACE_SWEATING = imgui.slider_float("##MaxFace", MAX_FACE_SWEATING, 0, 2, "%.3f")
        imgui.same_line()
        imgui.text(T("limit_desc_face"))
        local cmf, vmf = imgui.slider_float(T("val_min_face"), MIN_FACE_SWEATING, 0, 2, "%.3f"); if cmf then MIN_FACE_SWEATING = round3(vmf) end
        
        imgui.spacing()
        _, enable_body_sweating = imgui.checkbox(T("body_chk"), enable_body_sweating)
        _, MAX_BODY_SWEATING = imgui.slider_float("##MaxBody", MAX_BODY_SWEATING, 0, 2, "%.3f")
        imgui.same_line()
        imgui.text(T("limit_desc_body"))
        local cmb, vmb = imgui.slider_float(T("val_min_body"), MIN_BODY_SWEATING, 0, 2, "%.3f"); if cmb then MIN_BODY_SWEATING = round3(vmb) end

        imgui.separator()
        imgui.text(T("roughness_settings"))
        _, enable_roughness_control = imgui.checkbox(T("enable_roughness"), enable_roughness_control)
        if enable_roughness_control then
            local c8, v8 = imgui.slider_float(T("val_roughness_face"), face_roughness_value, 0.0, 1.0, "%.3f"); if c8 then face_roughness_value = round3(v8) end
            local c9, v9 = imgui.slider_float(T("val_roughness_body"), body_roughness_value, 0.0, 1.0, "%.3f"); if c9 then body_roughness_value = round3(v9) end
        end

        imgui.separator()
        imgui.text(T("save_load"))
        if imgui.button(T("btn_save")) then saveSettings() end
        imgui.same_line() 
        if imgui.button(T("btn_load")) then loadSettings() end

        imgui.tree_pop()
    end
end)

loadSettings()
ElapsedTime = 0

re.on_frame(function()
    ElapsedTime = ElapsedTime + Utils.GetElapsedTimeMs()
    if mod_enabled then
        if GetHunterData() then
            -- [AUTO EQUIP CHECK]
            if auto_equip_scan_enabled then
                equip_check_timer = equip_check_timer + Utils.GetElapsedTimeMs()
                if equip_check_timer >= EQUIP_CHECK_INTERVAL then
                    local current_hash = GetCurrentMeshHash()
                    if current_hash ~= last_mesh_hash then
                        ScanAndCacheMaterials()
                    end
                    equip_check_timer = 0
                end
            end

            UpdateEnvironmentState()

-- ==========================================
-- Water enter/exit transition:
-- Enter water -> instantly force wetness + apply once
-- Exit water  -> start "dry only" mode if above normal max
-- ==========================================
if force_wet_in_water then
    local now_in_water = LocationState.in_water

    -- Enter water
    if now_in_water and not was_in_water then
        local cap = math_max(0.0, WATER_WETNESS_CAP)
        local target = math_min(math_max(0.0, WATER_FORCE_WETNESS), cap)

        face_sweating_value = target
        body_sweating_value = target
        post_water_drying = false

        last_stamina_value = _M.HunterData.StaminaData or last_stamina_value

        -- Instant visual update (do it once on enter)
        ApplyWetnessToPlayerCached()
    end

    -- Exit water
    if (not now_in_water) and was_in_water then
        if (face_sweating_value > MAX_FACE_SWEATING) or (body_sweating_value > MAX_BODY_SWEATING) then
            post_water_drying = true
        else
            post_water_drying = false
        end
        last_stamina_value = _M.HunterData.StaminaData or last_stamina_value
    end

    was_in_water = now_in_water
else
    post_water_drying = false
    was_in_water = LocationState.in_water
end


            if enable_motiondata_sweating or enable_actionguide_sweating or (debug_enabled and is_history_expanded) then
                GetPlayerMotionAndActionData()
            end
            
            if debug_enabled and is_history_expanded then 
                UpdateActionHistory() 
            end
            
            if ElapsedTime >= (update_interval_seconds * 1000) then
                updateSweating()
                ApplyWetnessToPlayerCached()
                ElapsedTime = 0
            end
        else
            MaterialCache.IsValid = false
        end
    end
end)
