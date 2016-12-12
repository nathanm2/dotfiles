#
# Defines a function wrapper for the cscope_db.py script.
#
#  This will export the CSCOPE_DB environment variable.
#
function cs
{
    local cs_env
    if cscope_db.py $*; then
        cs_env=$(cscope_db.py find  2>/dev/null)
        if [[ $? -eq 0 ]]; then
            export CSCOPE_DB=$(echo ${cs_env} | awk '{print $2}')
        fi
    fi
}
