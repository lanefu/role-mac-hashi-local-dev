
program=$(basename "$0")
SHOW_INFO=0
SHOW_ERROR=1
WRITE_SYSLOG=1

AGENTPATH="${HOME}/Library/LaunchAgents"

# app functions
usage() {
    cat <<EOF

Usage:

    $program launchs hashistack dev mode

    $program [ option ]
    $program -h | --help
    $program -s | --start start the stack
    $program -k | --stop stop/kill the stack



EOF
    exit 6
}

checkDocker() {
docker ps

if ! [ $? -eq 0 ]
then
echo "Docker isn't running.  What's the point, aborting"
exit 1
fi

}

start() {
set -x
launchctl load ${AGENTPATH}/consul.plist
launchctl load ${AGENTPATH}/nomad.plist
launchctl load ${AGENTPATH}/fabio.plist
set +x
}

stop() {
launchctl unload ${AGENTPATH}/nomad.plist
launchctl unload ${AGENTPATH}/fabio.plist
launchctl unload ${AGENTPATH}/consul.plist
}

## "main" ##

case $1 in
    --help|-h )
        usage
        ;;
    --start|-s )
        checkDocker
        start
        ;;
    --stop|-k )
	stop
        ;;
    * )
        echo "no valid option selected"
        usage
        ;;
     
esac

# Fail if no input
if [[ ! $1 ]]; then
    usage
fi
