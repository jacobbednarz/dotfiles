function ipinfo -a ip --description "query ipinfo.io API for IP details"
    set -l token (op read --account my.1password.com "op://Personal/api.ipinfo.io/credential"); or return 1
    curl -H "Authorization: Bearer $token" https://api.ipinfo.io/lite/$ip
end
