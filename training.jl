using Flux
include("hupo.jl")

function collectData(numOfGames, net_top, net_bot, exploration)
  states_top = Array{Int}(0,18)
  rewards_top = Vector{Float64}()
  states_bot = Array{Int}(0,18)
  rewards_bot = Vector{Float64}()

  for i in 1:numOfGames
    st, rt, sb, rb = game(net_top, net_bot, exploration)
    states_top = vcat(states_top,st)
    states_bot = vcat(states_bot,sb)
    rewards_top = vcat(rewards_top,rt)
    rewards_bot = vcat(rewards_bot,rb)
  end

  states_top, rewards_top, states_bot, rewards_bot
end


collectData(50, [], [], 0.1)
