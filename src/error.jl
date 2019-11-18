"Exception type based on PROJ error handling"
struct PROJError <: Exception
    msg::String
    function PROJError(msg)
        # reset PROJ's error stack on construction
        proj_errno_reset(C_NULL)
        new(msg)
    end
end

function Base.showerror(io::IO, err::PROJError)
    err = string("PROJError: ", err.msg)
    println(io, err)
end

"Custom error handler, automatically set with `proj_log_func`"
function log_func(user_data::Ptr{Cvoid}, level::Cint, msg::Cstring)
    if level == PJ_LOG_ERROR
        throw(PROJError(unsafe_string(msg)))
    end
    return C_NULL
end

"Prevent an error converting a null pointer to a string, returns `nothing` instead"
aftercare(x::Cstring) = x == C_NULL ? nothing : unsafe_string(x)
aftercare(x::Ptr{Cstring}) = unsafe_loadstringlist(x)
