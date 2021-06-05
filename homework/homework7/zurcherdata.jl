### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 88930db2-99e8-11eb-1e4f-a1182378b090
begin
	using DataFrames
    using CSV
    using StatsPlots
	using Statistics
end

# ╔═╡ 8e3cee88-06c2-45a0-9009-e31d7702d6fa
md"
# Data Work with Zurcher's Data!

* In this exercise you'll use the DataFrames.jl package. 
* You should read at least the [getting started page](https://dataframes.juliadata.org/stable/man/getting_started/) of the docs.

We load the data for Rust's paper and do some analysis with it
"

# ╔═╡ 4d716ed7-1355-4f5d-9e30-adb985a111d5
d = CSV.read("buses.csv", DataFrame, header = false)

# ╔═╡ 33fcb555-3719-42e7-b15f-bd34408b4ddf
md"

## Fixing Column Names

* You can see that this dataframe has no column names. Unacceptable! 😄
1. use the `select!` function to get columns `1,2,5,6,7`. Checkout out the [docs](https://dataframes.juliadata.org/stable/lib/functions/#DataFrames.select!) for an explanation.
2. rename the columns with `rename!` to `[:busid, :bustype, :replaced, :miles_lag, :miles]`.
"

# ╔═╡ 10fd401d-f1e1-4357-9481-75a1bafdd507
md"

## Description

* call function `describe` on the loaded dataframe.
"

# ╔═╡ f90c0bd3-1462-41f0-99be-2395f4941e53
md"

## Different Bus Types

* There are different brands and types of buses in the data. Rust has 8 types, but in final estimation uses only 4 of them - the ones we have here.
* Group your dataframe by column `bustype`. Look at function [`groupby`](https://dataframes.juliadata.org/stable/lib/functions/#DataFrames.groupby).
* call the `keys` function on your grouped data frame to see a list of groups.
"

# ╔═╡ 18eb0748-749c-4e3c-a7a2-f8f1a5b74778
md"

## Summary Stats on a Grouped Dataframe

* Now we want to see how the data looks like for each bus group. 
* We use the function [`combine`](https://dataframes.juliadata.org/stable/lib/functions/#DataFrames.combine) on our grouped data frame.
* You can do `combine(gd, new_col1 => what_to_do, new_col2 => what_to_do, etc)`.
* For each bus group, we want to konw
  1. how many observations (`nrow`)
  1. number of unique buses by group
  1. average of `replaced` column
  1. total of `replaced` column
  1. average of `miles` column
  1. maximum of the `miles` column

* How many engine replacements did Zurcher perform in each group?
"

# ╔═╡ 6e9ab972-b7a3-4870-a455-a4200133f4ca
md"

## Subset to groups 3 and 4

* create a new data frame that contains only groups 3 and 4
* Take a subset from initial dataframe `d` and call it `d2`.
* you can look at [taking a subset](https://dataframes.juliadata.org/stable/man/getting_started/#Taking-a-Subset) in the docs
"

# ╔═╡ 97ba5281-51a0-415e-a291-3689d25d9103
md"
* next, group again by `bustype`
"

# ╔═╡ 9a1b7efe-9b27-49cb-98d1-55bcf938bb5e
md"

* Redo your summary table using `combine` from above on this new grouped dataframe!
"

# ╔═╡ dd46962d-c42c-4ee4-b06a-b92e3f85df80
md"

## Look at replaced buses

* What do buses which have a replacement look like?
* Use dataframe `d2` here (i.e. not grouped)
* We have to look at `miles_lag` here, because replacement is recorded once the engine is replaced (and the buses travels again).
  1. subset your grouped dataframe fron the previous question to the rows where a replacement takes place (i.e. `replaced == 1`)
  1. for those rows, compute `mean(:miles_lag),maximum(:miles_lag)`
* You should again use the `combine` function for this task
"

# ╔═╡ e73ac274-e563-4d49-958d-10465cbcb314
md"

## Visuals 

* We use the StatsPlots.jl package (already loaded) 
* the `@df` macro allows us to directly refer to column names of dataframes inside plotting commands.
* For example

	scatter(data.x, data.y)

is the same as

	@df data scatter(:x, :y)

* make a scatter plot of the `miles_lag` variable vs the `:replaced` column!
"



# ╔═╡ 85419f82-c11b-48af-ba8d-d965f3424da2
md"

## Discretized Data

* In the paper, Rust, discretizes the miles reading into discrete bins.
* use the `busdata` function (included) to create a discretized dataset!
* You can do `dd = busdata(Harold())`!
* This will return the data we will use for estimation. `x` is the mileage bin, `dx1` is the number of slots in the grid the bus moved up from last period, `d` is whether we replace.
"

# ╔═╡ c8e488a9-9cbf-4899-bf1c-63d00969d678
md"

## Plots of discretized data

* Using the discretized data in `dd`, make the followign plots:
  1. group `dd` by milage state and compute the average of `:d` for each state. show `:x` vs `:mean_replaced` in a bar graph
  1. group `dd` by milage state *and* bus type, and again compute the average of `:d` for each cell. make another bar graph of `:x` vs `:mean_replaced`, but now there should be one bar for each bus type. the `bar` funciton takes a `group` argument!
  1. Use the `groupedbar` function to show how many buses are recorded at each mileage grid state, again by bus group. We want to understand which bus group has the longest running engines. 
"

# ╔═╡ 857aa926-af5a-44ed-a832-5e488c819a6c
md"
function library"

# ╔═╡ fb0bdd7a-b081-48af-9432-2731421242ac
function make_trans(θ, n)
	transition = zeros(n, n);
	p = [θ ; 1 - sum(θ)]
	if any(p .< 0)
		println("negative probability")
	end
	np = length(p)

	# standard block
	for i = 0:n - np
		transition[i + 1,(i + 1):(i + np)] = p
	end

	for k in 1:(np-1)
		transition[n - k,(n - k):n] = [p[1:k]...; 1 - sum(p[1:k])]
	end
	transition[n,n] = 1.0
	return transition
end

# ╔═╡ b02f0afc-c582-4dce-a7be-41f6e2f20aa0
mutable struct Harold
	# parameters
	n::Int
	maxmiles::Int
	RC::Float64 
	c::Float64 
	θ::Vector{Float64}
	β::Float64 

	# numerical settings
	tol::Float64

	# state space
	mileage::Vector{Float64}
	transition::Matrix{Float64}

	function Harold(;n = 175,maxmiles = 450, RC = 11.7257,c = 2.45569,
					  θ = [0.0937, 0.4475 ,0.4459, 0.0127],
					  β = 0.999, tol =  1e-12)

		this = new()   # create new empty Harold instance
		this.n = n
		this.maxmiles = maxmiles
		this.RC = RC
		this.c = c
		this.θ = θ
		this.β = β
		this.tol = tol

		# build state space
		this.mileage = collect(0.0:n - 1)
		this.transition = make_trans(θ, n)
		return this
	end
end

# ╔═╡ 4963a35c-5af1-4baa-9f2e-9ca4e755793e
function busdata(z::Harold; bustype = 4) 
	d = CSV.read(joinpath("buses.csv"), DataFrame, header = false)
	select!(d, 1,2,5,7)
	rename!(d, [:id, :bustype, :d1, :odometer])

	d = filter(x -> x.bustype .<= bustype, d)

	# discretize odometer
	transform!(d, :odometer => (x -> Int.(ceil.(x .* z.n ./ (z.maxmiles * 1000)))) => :x)

	# replacement indicator
	dd = [d.d1[2:end] ; 0]

	# mileage increases
	dx1 = d.x .- [0;d.x[1:(end-1)]]
	dx1 = dx1 .* (1 .- d.d1) .+ d.x .* d.d1

	# make new dataframe
	df = [select(d, :id, :x, :bustype) DataFrame(dx1 = dx1, d = BitArray(dd))]

	# get rid of first observation for each bus
	idx = df.id .== [0; df.id[1:end-1]]
	df = df[idx,:]
end

# ╔═╡ Cell order:
# ╠═88930db2-99e8-11eb-1e4f-a1182378b090
# ╟─8e3cee88-06c2-45a0-9009-e31d7702d6fa
# ╠═4d716ed7-1355-4f5d-9e30-adb985a111d5
# ╟─33fcb555-3719-42e7-b15f-bd34408b4ddf
# ╟─10fd401d-f1e1-4357-9481-75a1bafdd507
# ╟─f90c0bd3-1462-41f0-99be-2395f4941e53
# ╟─18eb0748-749c-4e3c-a7a2-f8f1a5b74778
# ╟─6e9ab972-b7a3-4870-a455-a4200133f4ca
# ╟─97ba5281-51a0-415e-a291-3689d25d9103
# ╟─9a1b7efe-9b27-49cb-98d1-55bcf938bb5e
# ╟─dd46962d-c42c-4ee4-b06a-b92e3f85df80
# ╟─e73ac274-e563-4d49-958d-10465cbcb314
# ╟─85419f82-c11b-48af-ba8d-d965f3424da2
# ╟─c8e488a9-9cbf-4899-bf1c-63d00969d678
# ╟─857aa926-af5a-44ed-a832-5e488c819a6c
# ╟─4963a35c-5af1-4baa-9f2e-9ca4e755793e
# ╟─fb0bdd7a-b081-48af-9432-2731421242ac
# ╟─b02f0afc-c582-4dce-a7be-41f6e2f20aa0
