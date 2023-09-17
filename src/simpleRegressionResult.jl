
"""
    struct SimpleRegressionResult
        responsename::Union{String, <:AbstractCoefName}
        coefnames::Vector# either string or AbstractCoefName
        coefvalues::Vector{Float64}
        coefstderrors::Vector{Float64}
        coefpvalues::Vector{Float64}
        statistics::Vector
        regressiontype::RegressionType
        dof_residual::Int
        other_data::Dict{Symbol, Vector{<:Pair}}
    end

This is a summary type that takes other regression results
and stores them in a single unified type. If the regression
follows [StatsAPI.jl](https://github.com/JuliaStats/StatsAPI.jl),
then the default settings should work. In particular, the
following functions should be defined for the regression:
- `coef` to return the coefficient values
- `stderror` to return the standard errors
- `dof_residual` to return the residual degrees of freedom
- `formula` to return the formula schema
- `islinear` to return whether the regression is linear
   (this can be avoided if the regression defines
   `RegressionTables.RegressionType` in an extension)

The regression should also define functions related to regression
statistics (see [`AbstractRegressionStatistic`](@ref)). If the
regression has fixed effects, then it should also define an
[`fe_terms`](@ref) function that parses the necessary formula and
returns [`FixedEffectCoefName`](@ref) objects.

The `other_data` field is used to store other data that is not
stored in the other fields. For example, the `other_data` field
often includes fixed effects, clustering information, or random
effects.
"""
mutable struct SimpleRegressionResult
    responsename::Union{String, <:AbstractCoefName}
    coefnames::Vector# either string or AbstractCoefName
    coefvalues::Vector{Float64}
    coefstderrors::Vector{Float64}
    coefpvalues::Vector{Float64}
    statistics::Vector
    regressiontype::RegressionType
    dof_residual::Int
    other_data::Dict{Symbol, Vector{<:Pair}}
end

function Base.getproperty(x::SimpleRegressionResult, s::Symbol)
    if hasfield(SimpleRegressionResult, s)
        getfield(x, s)
    else
        get(getfield(x, :other_data), s, nothing)
    end
end

StatsAPI.responsename(x::SimpleRegressionResult) = x.responsename
StatsAPI.coefnames(x::SimpleRegressionResult) = x.coefnames
StatsAPI.coef(x::SimpleRegressionResult) = x.coefvalues
StatsAPI.stderror(x::SimpleRegressionResult) = x.coefstderrors
StatsAPI.dof_residual(x::SimpleRegressionResult) = x.dof_residual

SimpleRegressionResult(rr::RegressionModel, f::FormulaTerm, args...; vargs...) =
    SimpleRegressionResult(rr::RegressionModel, f.lhs, f.rhs, args...; vargs...)

SimpleRegressionResult(rr::RegressionModel, lhs::FormulaTerm, rhs::AbstractTerm, args...; vargs...) =
    SimpleRegressionResult(rr::RegressionModel, get_coefname(lhs), get_coefname(rhs), args...; vargs...)

SimpleRegressionResult(rr::RegressionModel, lhs::AbstractTerm, rhs::AbstractTerm, args...; vargs...) =
    SimpleRegressionResult(rr::RegressionModel, get_coefname(lhs), get_coefname(rhs), args...; vargs...)


SimpleRegressionResult(rr::RegressionModel, lhs::Union{AbstractString, AbstractCoefName}, rhs::Union{AbstractString, AbstractCoefName}, args...; vargs...) =
    SimpleRegressionResult(rr, lhs, [rhs], args...; vargs...)

SimpleRegressionResult(rr::RegressionModel, lhs::Vector, rhs::Union{AbstractString, AbstractCoefName}, args...; vargs...) =
    SimpleRegressionResult(rr, first(lhs), rhs, args...; vargs...)
SimpleRegressionResult(rr::RegressionModel, lhs::Vector, rhs::Vector, args...; vargs...) =
    SimpleRegressionResult(rr, first(lhs), rhs, args...; vargs...)
function SimpleRegressionResult(
    rr::RegressionModel,
    lhs::Union{AbstractString, AbstractCoefName},
    rhs::Vector,
    coefvalues::Vector{Float64},
    coefstderrors::Vector{Float64},
    coefpvalues::Vector{Float64},
    regression_statistics::Vector,
    reg_type=RegressionType(rr),
    fixedeffects::Union{Nothing, Vector}=nothing,
    df=dof_residual(rr),
    other=other_stats(rr);
    labels=Dict{String, String}(),
    transform_labels=Dict{String, String}(),
)
    SimpleRegressionResult(
        lhs,
        rhs,
        # replace_name(lhs, labels, transform_labels),
        # replace_name.(rhs, Ref(labels), Ref(transform_labels)),
        coefvalues,
        coefstderrors,
        coefpvalues,
        make_reg_stats.(Ref(rr), regression_statistics),
        reg_type,
        #replace_name.(fixedeffects, Ref(labels), Ref(transform_labels)),
        df,
        other
    )
end

function standardize_coef_values(rr::T, coefvalues, coefstderrors) where {T <: RegressionModel}
    @warn "standardize_coef is not possible for $T"
    coefvalues, coefstderrors
end

function standardize_coef_values(std_X::Vector, std_Y, coefvalues::Vector, coefstderrors::Vector)
    std_X = replace(std_X, 0 => 1) # constant has 0 std, so the interpretation is how many Y std away from 0 is the intercept
    coefvalues = coefvalues .* std_X ./ std_Y
    coefstderrors = coefstderrors .* std_X  ./ std_Y
    coefvalues, coefstderrors
end

transformer(s::Nothing, repl_dict::AbstractDict) = s
function transformer(s, repl_dict::AbstractDict)
    for (old, new) in repl_dict
        s = replace(s, old => new)
    end
    return s
end

replace_name(s::Union{AbstractString, AbstractCoefName}, exact_dict, repl_dict) = get(exact_dict, s, transformer(s, repl_dict))
replace_name(s::Tuple{<:AbstractCoefName, <:AbstractString}, exact_dict, repl_dict) = (replace_name(s[1], exact_dict, repl_dict), s[2])
replace_name(s::Nothing, args...) = s

RegressionType(x::RegressionModel) = islinear(x) ? RegressionType(Normal()) : RegressionType("NL")

make_reg_stats(rr, stat::Type{<:AbstractRegressionStatistic}) = stat(rr)
make_reg_stats(rr, stat) = stat
make_reg_stats(rr, stat::Pair{<:Any, <:AbstractString}) = make_reg_stats(rr, first(stat)) => last(stat)

default_regression_statistics(x::AbstractRenderType, rr::RegressionModel) = default_regression_statistics(rr)
default_regression_statistics(rr::RegressionModel) = [Nobs, R2]

other_stats(x::RegressionModel) = Dict{Symbol, Vector{Pair}}()

"""
    fe_terms(rr::RegressionModel; args...)

Returns the fixed effects terms for the regression. This is used (if the appropriate extension is loaded)
to display the fixed effects in the regression table. For regressions that do not have fixed effects, this
returns `nothing`.
"""
fe_terms(rr::RegressionModel; args...) = nothing

function SimpleRegressionResult(
    rr::RegressionModel,
    standardize_coef=false;
    labels::Dict{String, String} = Dict{String, String}(),
    regression_statistics::Vector = default_regression_statistics(rr),
    transform_labels = Dict(),
    args...
)
    coefvalues = coef(rr)
    coefstderrors = stderror(rr)
    if standardize_coef
        coefvalues, coefstderrors = standardize_coef_values(rr, coefvalues, coefstderrors)
    end
    tt = coefvalues ./ coefstderrors
    coefpvalues = ccdf.(Ref(FDist(1, dof_residual(rr))), abs2.(tt))
    SimpleRegressionResult(
        rr,
        formula(rr),
        coefvalues,
        coefstderrors,
        coefpvalues,
        regression_statistics,
        RegressionType(rr),
        fe_terms(rr),
        dof_residual(rr);
        labels=labels,
        transform_labels=transform_labels,
    )
end