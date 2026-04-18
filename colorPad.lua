--====================================================
-- ColorPad（Part直下）
-- 目的：踏むと光る（色が変わる）→少しして元に戻る
-- 置き場所：ColorPadにしたいPartの直下に Script を入れる
-- 任意：Part直下に Sound（名前：Sfx）を入れると音も鳴る
--====================================================

--========================
-- ★ パラメータ（ここだけ触ればOK）
--========================
local ACTIVE_TIME  = 1.2                         -- 光る時間（秒）
local COOLDOWN     = 0.4                         -- 連続反応防止（秒）
local ACTIVE_COLOR = Color3.fromRGB(0, 255, 160) -- 光る色（RGB）

local PLAY_SOUND   = true                        -- 音を鳴らす？
local SOUND_NAME   = "Sfx"                       -- Soundの名前

--========================
-- 参照（このScriptが入っているPart）
--========================
local pad = script.Parent

-- 元の見た目（戻す用）
local originalColor = pad.Color
local originalMaterial = pad.Material

-- 状態（連打・重ねがけ防止）
local isBusy = false
local lastTriggeredAt = 0

-- Sound（任意）
local sfx = pad:FindFirstChild(SOUND_NAME)

--========================
-- 触れた時の処理
--========================
local function onTouched(hit)
	-- 連続で反応しすぎないようにクールダウン
	local now = os.clock()
	if (now - lastTriggeredAt) < COOLDOWN then return end
	lastTriggeredAt = now

	-- 光っている最中は重ねがけしない（挙動を安定させる）
	if isBusy then return end
	isBusy = true

	-- （任意）音
	if PLAY_SOUND and sfx and sfx:IsA("Sound") then
		sfx:Play()
	end

	-- 見た目を変える（光る）
	pad.Color = ACTIVE_COLOR
	pad.Material = Enum.Material.Neon

	-- 一定時間後に元へ戻す
	task.delay(ACTIVE_TIME, function()
		if pad and pad.Parent then
			pad.Color = originalColor
			pad.Material = originalMaterial
		end
		isBusy = false
	end)
end

pad.Touched:Connect(onTouched)
