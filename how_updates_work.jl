using Plots
using Flux

m = Chain(
  Dense(2, 10, relu),
  Dense(10, 2),
  softmax)
m[1].W
m[1].b
relu
m[2].W
m[2].b
softmax

x = [1;3]#[1. 2 3; 3. 4 5]
println(m(x).data)
#we want to lower the last probability (discourage the action in this state)

function loss(x,y)
    p_all = m(x)
    p = p_all[end,:] #end because of the last
    -sum(log.(p) .* y)
end

opt = ADAM(Flux.params(m))

y = -1.#[-1.; -1; 1] #we assign negative reward
data = Iterators.repeated((x, y), 1)
probs = [m(x).data[2]]
for i in 1:19
  Flux.train!(loss, data, opt)
  push!(probs,m(x).data[2])
end
y = 1.#[-1.; -1; 1] #we assign positive reward
data = Iterators.repeated((x, y), 1)
for i in 1:20
  Flux.train!(loss, data, opt)
  push!(probs,m(x).data[2])
end

plot(probs)

#####################################
##### what if there are more outcomes
#####################################
m = Chain(
  Dense(2, 10, relu),
  Dense(10, 3),
  softmax)

x = [1;3]
println(m(x).data)
#we want to lower the last probability (discourage the action in this state)

function loss(x,y)
    p_all = m(x)
    p = p_all[end,:] #end because of the last
    -sum(log.(p) .* y)
end

opt = ADAM(Flux.params(m))

y = -1.
data = Iterators.repeated((x, y), 1)
probs = [m(x).data]
for i in 1:19
  Flux.train!(loss, data, opt)
  push!(probs,m(x).data)
end
y = 1. #we assign positive reward
data = Iterators.repeated((x, y), 1)
for i in 1:20
  Flux.train!(loss, data, opt)
  push!(probs,m(x).data)
end

plot!([p[1] for p in probs])
probs[2][1]-probs[1][1]
probs[2][2]-probs[1][2]
probs[2][3]-probs[1][3]
#it is not equally distributed

#check other optimizers and batches of data
