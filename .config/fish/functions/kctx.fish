function kctx --description "Switch kube context for EKS and GKE clusters"
    set -l rows (python3 -c "
import configparser, subprocess, re, os, json

R = '\x1b[0m'
B = '\x1b[1m'
RED = '\x1b[31m'
GREEN = '\x1b[32m'
YELLOW = '\x1b[33m'
BLUE = '\x1b[34m'
CYAN = '\x1b[36m'
GRAY = '\x1b[90m'

cfg = configparser.ConfigParser()
cfg.read(os.path.expanduser('~/.aws/config'))

account_profiles = {}
for section in cfg.sections():
    if section.startswith('profile '):
        prof = section[8:]
        acct = cfg.get(section, 'sso_account_id', fallback=None)
        if acct:
            account_profiles.setdefault(acct, []).append(prof)

matched_profiles = set()
rows = []

# Map (possibly aliased) context names to their real cluster identifier so we
# match on the underlying EKS ARN / GKE cluster rather than a renamed context.
ctx_to_cluster = {}
try:
    kubeconfig = json.loads(subprocess.check_output(['kubectl', 'config', 'view', '-o', 'json']).decode())
    for c in kubeconfig.get('contexts', []):
        ctx_to_cluster[c['name']] = (c.get('context') or {}).get('cluster', '')
except Exception:
    pass

contexts = subprocess.check_output(['kubectx']).decode().strip().split('\n')
for ctx in contexts:
    ident = ctx_to_cluster.get(ctx) or ctx
    m = re.match(r'arn:aws:eks:([^:]+):(\d+):cluster/(.+)', ident)
    if m:
        region, account, cluster = m.groups()
        parts = region.split('-')
        abbrev = parts[0] + ''.join(p[0] for p in parts[1:-1]) + parts[-1]
        matching = [p for p in account_profiles.get(account, []) if abbrev in p]
        profile = matching[0] if matching else ''
        if profile:
            matched_profiles.add(profile)
        rows.append(('AWS', cluster, region, profile or '—', profile, ctx, 'aws'))
        continue

    m = re.match(r'gke_([^_]+)_([^_]+)_(.+)', ident)
    if m:
        project, region, cluster = m.groups()
        rows.append(('GCP', cluster, region, project, project, ctx, 'gcp'))
        continue

    rows.append(('?', ctx, 'unknown', '', '', ctx, ''))

all_profiles = [p for profs in account_profiles.values() for p in profs]
for profile in all_profiles:
    if profile not in matched_profiles:
        rows.append(('AWS', '(no cluster)', '—', profile, profile, '', 'aws'))

widths = [max(len(row[column]) for row in rows) for column in range(4)]
separator = '  '
def paint(value, colour):
    return f'{colour}{value}{R}' if colour else value

for cloud, cluster, region, account, profile, ctx, provider in rows:
    colours = (
        YELLOW if provider == 'aws' else BLUE if provider == 'gcp' else RED,
        B + CYAN if provider and cluster != '(no cluster)' else GRAY,
        GREEN if provider and region != '—' else GRAY,
        YELLOW if provider == 'aws' else BLUE if provider == 'gcp' else '',
    )
    values = (cloud, cluster, region, account)
    columns = [
        paint(value, colour) + ' ' * (width - len(value))
        for value, colour, width in zip(values, colours, widths)
    ]
    print(f'{separator.join(columns)}\t{profile}\t{ctx}\t{provider}')
" 2>/dev/null)

    test -n "$rows" || begin
        echo "kctx: no kube contexts found" >&2
        return 1
    end

    set -l selection (printf '%s\n' $rows | fzf \
        --ansi \
        --prompt "kctx> " \
        --delimiter '\t' \
        --with-nth '1')
    test -n "$selection" || return 0

    set -l fields (string split \t $selection)
    set -l profile $fields[2]
    set -l context $fields[3]
    set -l cloud $fields[4]

    switch $cloud
        case aws
            set -e CLOUDSDK_CORE_PROJECT
        case gcp
            set -e AWS_PROFILE
            if test -n "$profile"
                set -gx CLOUDSDK_CORE_PROJECT $profile
                echo "CLOUDSDK_CORE_PROJECT → $profile"
            end
    end

    if test -n "$context"
        kubectx $context
    end
end
