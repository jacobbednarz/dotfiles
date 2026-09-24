function try
    set -l out (command try exec --path ~/src/tries $argv 2>/dev/tty | string collect)
    set -l cmd_status $pipestatus[1]
    if test $cmd_status -eq 0
        eval $out
    end
end
