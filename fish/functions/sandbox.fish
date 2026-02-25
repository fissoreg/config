function sandbox --description "Run an AI agent in a Docker Sandbox"
    set -l agent "claude"
    set -l repo_path (pwd)
    set -l agent_args

    set -l remaining
    set -l past_separator false

    for arg in $argv
        if test "$past_separator" = true
            set -a agent_args $arg
        else if test "$arg" = "--"
            set past_separator true
        else if test "$arg" = "--opencode"
            set agent opencode
        else
            set -a remaining $arg
        end
    end

    if test (count $remaining) -gt 0
        set repo_path (realpath $remaining[1])
    end

    set -l cmd docker sandbox run $agent $repo_path

    if test (count $agent_args) -gt 0
        set -a cmd -- $agent_args
    end

    echo "Running $agent sandbox on $repo_path"
    $cmd
end
