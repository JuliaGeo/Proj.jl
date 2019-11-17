"Exception type based on PROJ error handling"
struct PROJError <: Exception
    msg::String
    # reset PROJ's error stack on construction
    function PROJError(msg)
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
