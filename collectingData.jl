mutable struct memory_buffer
  N::Int
  states::Matrix{Int}
  actions::Vector{Int}
  rewards::Vector{Float64}
end


function action2idx(move::Move, pass::Int)
  (Int(move) - 1)*6 + pass
end


function memory_buffer(N::Int)
  memory_buffer(N, zeros(Int, 72, N), zeros(N), zeros(N))
end


function game!(net_top, net_bot, mb, k, r_end, discount, length_of_game_tolerance, level)
  state = state_beginning(level)
  active_player = :top
  k_init = k
  won = Symbol()
  game_length = 0

  while true
    game_length += 1
    move, pass = active_player == :top ?
                 sample_action(state, net_top) :
                 sample_action(state, net_bot)
    if (active_player == :top) && (k <= mb.N)
      mb.states[:,k] = transformState(state)
      mb.actions[k] = action2idx(move, pass)
      k += 1
    end
    active_stone = apply_move!(state, move)
    apply_pass!(state, active_stone, pass)
    won = check_state(state)
    active_player = get_active_player(state)

    if k - k_init > length_of_game_tolerance
      won = :bottom_player_won
    end

    if won ∈ (:top_player_won, :bottom_player_won)
      if k_init + game_length <= mb.N
        reward = (discount .^ ((k - k_init - 1):-1:0)) .* r_end
        if won == :top_player_won
            mb.rewards[k_init:(k - 1)] .+= reward
        else
            mb.rewards[k_init:(k - 1)] .-= reward
        end
      end
      return k
    end
  end
end


function collectData(net_top, net_bot, lengthOfBuffer, r_end, discount, length_of_game_tolerance, level)
  mb = memory_buffer(lengthOfBuffer)
  k = 1
  while k <= mb.N
    k = game!(net_top, net_bot, mb, k, r_end, discount, length_of_game_tolerance, level)
  end

  data = mb.states, mb.actions, (mb.rewards .- mean(mb.rewards))./std(mb.rewards)
end


# data = collectData(net_top, net_bot)
