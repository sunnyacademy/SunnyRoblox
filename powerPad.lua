--====================================================
-- PowerPad（Part直下）
-- 目的：踏むとジャンプ力＆移動速度が上がる → 一定時間後に元に戻る
-- 置き場所：PowerPadにしたいPartの直下に Script を入れる
-- 任意：Part直下に Sound（名前：Sfx）を入れると音も鳴る
--====================================================

--========================
-- ★ パラメータ（ここだけ触ればOK）
--========================
local BOOST_TIME   = 5.0      -- 強化時間（秒）
local COOLDOWN     = 1.0      -- 連続発火防止（秒）

local BOOST_JUMP   = 90       -- 強化中のジャンプ力（大きいほど高い）
local BOOST_SPEED  = 24       -- 強化中の移動速度（大きいほど速い）

local PLAY_SOUND   = true     -- 音を鳴らす？
local SOUND_NAME   = "Sfx"    -- Soundの名前

--========================
-- 参照（このScriptが入っているPart）
--========================
local pad = script.Parent

-- 状態（連打・重ねがけ防止）
local isBusy = false
local lastTriggeredAt = 0

-- Sound（任意）
local sfx = pad:FindFirstChild(SOUND_NAME)

--========================
-- 触れた時の処理
--========================
local function onTouched(hit)
	-- クールダウン（チカチカ/連打を防ぐ）
	local now = os.clock()
	if (now - lastTriggeredAt) < COOLDOWN then return end
	lastTriggeredAt = now

	-- 強化中の重ねがけを防ぐ（シンプルにする）
	if isBusy then return end
	isBusy = true

	-- Character / Humanoid を探す（人が踏んだ時だけ反応）
	local character = hit.Parent
	if not character then isBusy = false; return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then isBusy = false; return end

	-- （任意）音
	if PLAY_SOUND and sfx and sfx:IsA("Sound") then
		sfx:Play()
	end

	-- 元の値を保存（戻すため）
	local originalJump = humanoid.JumpPower
	local originalSpeed = humanoid.WalkSpeed

	-- 強化
	humanoid.UseJumpPower = true
	humanoid.JumpPower = BOOST_JUMP
	humanoid.WalkSpeed = BOOST_SPEED

	-- 一定時間後に元へ戻す
	task.delay(BOOST_TIME, function()
		-- 途中でリスポーン等が起きても、落ちないように存在確認
		if humanoid and humanoid.Parent then
			humanoid.JumpPower = originalJump
			humanoid.WalkSpeed = originalSpeed
		end
		isBusy = false
	end)
end

pad.Touched:Connect(onTouched)