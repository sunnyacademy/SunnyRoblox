--====================================================
-- WarpGate（入口Part直下）
-- 目的：触れたら指定した出口Partへワープする
-- 置き場所：入口（WarpGate）にしたいPartの直下に Script を入れる
-- 任意：入口Part直下に Sound（名前：Sfx）を入れると音も鳴る
--
-- 使い方：
--  1) 出口Partを用意（名前：WarpDestination など）
--  2) このScriptの DESTINATION_NAME を出口名に合わせる
--  3) Playして入口に触れる→出口へ移動
--====================================================

--========================
-- ★ パラメータ（ここだけ触ればOK）
--========================
local DESTINATION_NAME = "WarpDestination" -- 出口Partの名前
local OFFSET_Y         = 3.0              -- 出口の何Stud上に出すか（埋まり防止）
local COOLDOWN         = 0.6              -- 連続ワープ防止（秒）

local PLAY_SOUND       = true             -- 音を鳴らす？
local SOUND_NAME       = "Sfx"            -- Soundの名前

--========================
-- 参照（このScriptが入っているPart）
--========================
local gate = script.Parent

-- 出口Part（Workspaceのどこかに置けばOK）
local destination = workspace:FindFirstChild(DESTINATION_NAME, true) -- true=子孫も探す

-- Sound（任意）
local sfx = gate:FindFirstChild(SOUND_NAME)

-- 状態（連続ワープ防止）
local lastWarpAt = {} -- key: character, value: time

--========================
-- 触れた時の処理
--========================
local function onTouched(hit)
	-- 出口が見つからない場合は警告（授業中の事故原因を明確にする）
	if not destination or not destination:IsA("BasePart") then
		warn("WarpGate: 出口Partが見つかりません。DESTINATION_NAMEを確認してください：", DESTINATION_NAME)
		return
	end

	local character = hit.Parent
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- 連続ワープ防止（入口と出口が近いと無限ワープしやすい）
	local now = os.clock()
	local prev = lastWarpAt[character]
	if prev and (now - prev) < COOLDOWN then
		return
	end
	lastWarpAt[character] = now

	-- （任意）音
	if PLAY_SOUND and sfx and sfx:IsA("Sound") then
		sfx:Play()
	end

	-- ワープ（出口の少し上に出す）
	hrp.CFrame = destination.CFrame + Vector3.new(0, OFFSET_Y, 0)
end

gate.Touched:Connect(onTouched)