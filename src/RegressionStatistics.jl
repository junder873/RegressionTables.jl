abstract type AbstractRegressionStatistic{T} end

struct Nobs{T<:Union{Int, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
Nobs(x::RegressionModel) = try
    Nobs(nobs(x))
catch
    Nobs(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:Nobs}) = "N"

struct R2{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2(x::RegressionModel) = try
    R2(r2(x))
catch
    R2(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:R2}) = "R2"

struct R2McFadden{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2McFadden(x::RegressionModel) = try
    R2McFadden(r2(x, :McFadden))
catch
    R2McFadden(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:R2McFadden}) = "McFadden " * label(rndr, R2)

struct R2CoxSnell{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2CoxSnell(x::RegressionModel) = try
    R2CoxSnell(r2(x, :CoxSnell))
catch
    R2CoxSnell(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:R2CoxSnell}) = "Cox-Snell " * label(rndr, R2)

struct R2Nagelkerke{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2Nagelkerke(x::RegressionModel) = try
    R2Nagelkerke(r2(x, :Nagelkerke))
catch
    R2Nagelkerke(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:R2Nagelkerke}) = "Nagelkerke " * label(rndr, R2)

struct R2Deviance{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2Deviance(x::RegressionModel) = try
    R2Deviance(r2(x, :devianceratio))
catch
    R2Deviance(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:R2Deviance}) = "Deviance " * label(rndr, R2)

struct AdjR2{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AdjR2(x::RegressionModel) = try
    AdjR2(adjr2(x))
catch
    AdjR2(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:AdjR2}) = "Adjusted " * label(rndr, R2)

struct AdjR2McFadden{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AdjR2McFadden(x::RegressionModel) = try
    AdjR2McFadden(adjr2(x, :McFadden))
catch
    AdjR2McFadden(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:AdjR2McFadden}) = "McFadden " * label(rndr, AdjR2)

struct AdjR2Deviance{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AdjR2Deviance(x::RegressionModel) = try
    AdjR2Deviance(adjr2(x, :devianceratio))
catch
    AdjR2Deviance(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:AdjR2Deviance}) = "Deviance " * label(rndr, AdjR2)

struct DOF{T<:Union{Int, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
DOF(x::RegressionModel) = try
    DOF(dof(x))
catch
    DOF(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:DOF}) = "Degrees of Freedom"

struct LogLikelihood{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
LogLikelihood(x::RegressionModel) = try
    LogLikelihood(loglikelihood(x))
catch
    LogLikelihood(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:LogLikelihood}) = "Log Likelihood"

struct AIC{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AIC(x::RegressionModel) = try
    AIC(aic(x))
catch
    AIC(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:AIC}) = "AIC"

struct AICC{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AICC(x::RegressionModel) = try
    AICC(aicc(x))
catch
    AICC(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:AICC}) = "AICC"

struct BIC{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
BIC(x::RegressionModel) = try
    BIC(aicc(x))
catch
    BIC(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:BIC}) = "BIC"

struct FStat{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
FStat(r::RegressionModel) = FStat(nothing)
label(rndr::AbstractRenderType, x::Type{<:FStat}) = "F"

struct FStatPValue{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
FStatPValue(r::RegressionModel) = FStatPValue(nothing)
label(rndr::AbstractRenderType, x::Type{<:FStatPValue}) = label(rndr, FStat) * "-test " * label_p(rndr) *" value"

struct FStatIV{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
FStatIV(r::RegressionModel) = FStatIV(nothing)
label(rndr::AbstractRenderType, x::Type{<:FStatIV}) = "First-stage " * label(rndr, FStat) * " statistic"

struct FStatIVPValue{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
FStatIVPValue(r::RegressionModel) = FStatIVPValue(nothing)
label(rndr::AbstractRenderType, x::Type{<:FStatIVPValue}) = "First-stage " * label_p(rndr) * " value"

struct R2Within{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2Within(r::RegressionModel) = R2Within(nothing)
label(rndr::AbstractRenderType, x::Type{<:R2Within}) = "Within-" * label(rndr, R2)




value(s::AbstractRegressionStatistic) = s.val

Base.show(io::IO, s::AbstractRegressionStatistic{Nothing}) = show(io, "")
Base.show(io::IO, s::AbstractRegressionStatistic) = show(io, value(s))
Base.print(io::IO, s::AbstractRegressionStatistic{Nothing}) = print(io, "")
Base.print(io::IO, s::AbstractRegressionStatistic) = print(io, value(s))


abstract type AbstractUnderStatistic end

struct TStat <: AbstractUnderStatistic
    val::Float64
end
TStat(stderror, coef) = TStat(coef / stderror)

struct STDError <: AbstractUnderStatistic
    val::Float64
end
STDError(stderror, coef) = STDError(stderror)

value(x::AbstractUnderStatistic) = x.val

struct CoefValue
    val::Float64
    pvalue::Float64
end
value(x::CoefValue) = x.val

struct RegressionType
    val::Symbol
end
value(x::RegressionType) = x.val
label(rndr::AbstractRenderType, x::Type{RegressionType}) = "Estimator"

