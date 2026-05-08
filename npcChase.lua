--====================================================
-- NPC Chase Script（NPCモデル直下）
-- 目的：NPCが一番近いプレイヤーを見つけて追いかける
-- 方式：PathfindingService（壁/段差を避けやすい）
--
-- 前提：
--  - このScriptはNPCのModel直下に置く
--  - NPCのModelに Humanoid と HumanoidRootPart がある
--  - Model.PrimaryPart = HumanoidRootPart に設定済み
--====================================================

--========================
-- ★ パラメータ（ここだけ触ればOK）
--========================
local DETECT_RANGE      = 80     -- 何Stud以内のプレイヤーを追うか
local STOP_RANGE        = 4      -- ここまで近づいたら追跡を弱める（近すぎ防止）
local REPATH_INTERVAL   = 0.8    -- 何秒ごとに経路を作り直すか（軽さ/追従のバランス）
local WALK_SPEED        = 16     -- NPCの移動速度
local JUMP_POWER        = 50     -- 段差を越える用（必要なら）
local GIVE_UP_TIME      = 3.0    -- 追跡中に経路が作れない状態が続いたら諦める秒数

--========================
-- サービスと参照
--========================
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")

local npc = script.Parent
local humanoid = npc:FindFirstChildOfClass("Humanoid")
local hrp = npc:FindFirstChild("HumanoidRootPart")

if not humanoid or not hrp then
	warn("NPCにHumanoid / HumanoidRootPartがありません")
	return
end

-- 移動パラメータをNPCに反映
humanoid.WalkSpeed = WALK_SPEED
humanoid.JumpPower = JUMP_POWER

--========================
-- 便利関数：一番近いプレイヤーを探す
--========================
local function getNearestPlayer()
	local nearestPlayer = nil
	local nearestDist = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local targetHrp = character:FindFirstChild("HumanoidRootPart")
			local targetHum = character:FindFirstChildOfClass("Humanoid")

			-- 生きてるプレイヤーのみ
			if targetHrp and targetHum and targetHum.Health > 0 then
				local dist = (targetHrp.Position - hrp.Position).Magnitude
				if dist < nearestDist and dist <= DETECT_RANGE then
					nearestDist = dist
					nearestPlayer = player
				end
			end
		end
	end

	return nearestPlayer, nearestDist
end

--========================
-- 経路で追いかける（Pathfinding）
--========================
local function chaseTarget(targetHrp)
	local stuckStart = nil

	while targetHrp and targetHrp.Parent do
		local dist = (targetHrp.Position - hrp.Position).Magnitude

		-- 近すぎると挙動がガタつくので、少し手前で止める
		if dist <= STOP_RANGE then
			humanoid:MoveTo(hrp.Position)
			task.wait(0.2)
		else
			-- 経路を計算
			local path = PathfindingService:CreatePath({
				AgentRadius = 2,
				AgentHeight = 5,
				AgentCanJump = true,
				AgentJumpHeight = 8,
			})

			path:ComputeAsync(hrp.Position, targetHrp.Position)

			if path.Status == Enum.PathStatus.Success then
				stuckStart = nil
				local waypoints = path:GetWaypoints()

				-- Waypointを順に MoveTo
				for _, waypoint in ipairs(waypoints) do
					-- ジャンプが必要な点
					if waypoint.Action == Enum.PathWaypointAction.Jump then
						humanoid.Jump = true
					end

					humanoid:MoveTo(waypoint.Position)
					local reached = humanoid.MoveToFinished:Wait()

					-- 途中でターゲットが遠すぎたら追跡終了
					if not targetHrp.Parent then return end
					local newDist = (targetHrp.Position - hrp.Position).Magnitude
					if newDist > DETECT_RANGE then return end

					-- 移動が失敗し続ける（ハマる）場合は諦める
					if not reached then
						stuckStart = stuckStart or os.clock()
						if (os.clock() - stuckStart) >= GIVE_UP_TIME then
							return
						end
						break
					end
				end
			else
				-- 経路が作れない → しばらくしたら諦める
				stuckStart = stuckStart or os.clock()
				if (os.clock() - stuckStart) >= GIVE_UP_TIME then
					return
				end
			end
		end

		task.wait(REPATH_INTERVAL)
	end
end

--========================
-- メインループ：近いプレイヤーを見つけたら追跡
--========================
while true do
	local player, dist = getNearestPlayer()
	if player and player.Character then
		local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
		if targetHrp then
			chaseTarget(targetHrp)
		end
	end
	task.wait(0.3)
end