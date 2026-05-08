--====================================================
-- LavaPad（Part直下）
-- 目的：触れるとダメージを与える（連続ヒットを抑制）
-- 置き場所：LavaPadにしたいPartの直下に Script を入れる
-- 任意：Part直下に Sound（名前：Sfx）を入れると音も鳴る
--====================================================

--========================
-- ★ パラメータ（ここだけ触ればOK）
--========================
local DAMAGE        = 25      -- 1回のダメージ量
local HIT_COOLDOWN  = 0.8     -- 同じ人が連続で食らう間隔（秒）

local PLAY_SOUND    = true    -- 音を鳴らす？
local SOUND_NAME    = "Sfx"   -- Soundの名前

--========================
-- 参照（このScriptが入っているPart）
--========================
local pad = script.Parent

-- Sound（任意）
local sfx = pad:FindFirstChild(SOUND_NAME)

-- 「同じHumanoidに連続で当てない」ための記録
local lastHitAt = {} -- key: humanoid, value: time

--========================
-- 触れた時の処理
--========================
local function onTouched(hit)
	local character = hit.Parent
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- 連続ヒット抑制
	local now = os.clock()
	local prev = lastHitAt[humanoid]
	if prev and (now - prev) < HIT_COOLDOWN then
		return
	end
	lastHitAt[humanoid] = now

	-- （任意）音
	if PLAY_SOUND and sfx and sfx:IsA("Sound") then
		sfx:Play()
	end

	-- ダメージ
	humanoid:TakeDamage(DAMAGE)
end

pad.Touched:Connect(onTouched)