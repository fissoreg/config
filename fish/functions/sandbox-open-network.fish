function sandbox-open-network --description "Open network for a sandbox or set as global default"
    set -l name $argv[1]

    if test "$name" = "--default"
        mkdir -p ~/.sandboxd
        if test -f ~/.sandboxd/proxy-config.json
            jq '.network.allowedDomains = []' ~/.sandboxd/proxy-config.json >~/.sandboxd/proxy-config.json.tmp
            and mv ~/.sandboxd/proxy-config.json.tmp ~/.sandboxd/proxy-config.json
        else
            set -l source (find ~/.docker/sandboxes/vm -name proxy-config.json -print -quit 2>/dev/null)
            if test -n "$source"
                jq '.network.allowedDomains = []' $source >~/.sandboxd/proxy-config.json
            else
                echo "No existing sandbox config found. Create a sandbox first, then re-run."
                return 1
            end
        end
        echo "Global default set: all new sandboxes will allow all public internet"
        return 0
    end

    if test -z "$name"
        echo "Usage: sandbox-open-network <sandbox-name>"
        echo "       sandbox-open-network --default  (set for all future sandboxes)"
        return 1
    end

    set -l config ~/.docker/sandboxes/vm/$name/proxy-config.json
    if not test -f $config
        echo "Config not found: $config"
        echo "Make sure the sandbox exists (docker sandbox ls)"
        return 1
    end

    jq '.network.allowedDomains = []' $config >$config.tmp
    and mv $config.tmp $config
    echo "Network opened for $name (allow all public traffic)"
end
