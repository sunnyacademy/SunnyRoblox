--====================================================
-- GoalGate（Part直下）
-- 目的：ゴールに触れたら「音」＋「クリア表示」を出す（最速版）
-- 置き場所：GoalGateにしたいPartの直下に Script を入れる
-- 任意：Part直下に Sound（名前：Sfx）を入れると音が鳴る
--
-- 表示：player:Kick()ではなく、Hint（画面上部）で軽く表示
--====================================================

--========================
-- ★ パラメータ（ここだけ触ればOK）
--========================
local MESSAGE      = "クリア！おめでとう！"  -- 表示メッセージ
local MESSAGE_TIME = 2.0                     -- 表示時間（秒）
local COOLDOWN     = 1.5                     -- 連続クリア防止（秒）

local PLAY_SOUND   = true                    -- 音を鳴らす？
local SOUND_NAME   = "Sfx"                   -- Soundの名前

--========================
-- 参照
--========================
local gate = script.Parent
local sfx = gate:FindFirstChild(SOUND_NAME)

-- プレイヤー取得用
local Players = game:GetService("Players")

-- 連続発火防止（プレイヤー単位）
local lastClearAt = {} -- key: player, value: time

-- “Hint”はWorkspaceに置くと全員に見える
local function showHint(text, seconds)
	local hint = Instance.new("Hint")
	hint.Text = text
	hint.Parent = workspace
	task.delay(seconds, function()
		if hint and hint.Parent then
			hint:Destroy()
		end
	end)
end

local function onTouched(hit)
	local character = hit.Parent
	if not character then return end

	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end

	-- 連続クリア防止
	local now = os.clock()
	local prev = lastClearAt[player]
	if prev and (now - prev) < COOLDOWN then
		return
	end
	lastClearAt[player] = now

	-- （任意）音
	if PLAY_SOUND and sfx and sfx:IsA("Sound") then
		sfx:Play()
	end

	-- クリア表示（全員に出る）
	showHint(MESSAGE .. "（" .. player.Name .. "）", MESSAGE_TIME)
end

gate.Touched:Connect(onTouched)