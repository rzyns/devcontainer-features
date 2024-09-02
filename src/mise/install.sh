#!/bin/sh
set -e

. /etc/os-release

if [ "${ID}" -ne "debian" ] && [ "${ID}" -ne "ubuntu" ]; then
	print_error "Unsupported  distribution '${ID}'. To resolve, choose a compatible OS distribution (debian, ubuntu)"
	exit 1
fi

echo "Activating feature 'mise'"

if [ "$(id -u)" -eq 0 ]; then
	apt-get update -y && apt-get install -y gpg wget curl
	install -dm 755 /etc/apt/keyrings
	wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
	echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | tee /etc/apt/sources.list.d/mise.list
	apt-get update
	apt-get install -y mise
	apt-get clean
else
	gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 0x7413A06D
	curl https://mise.jdx.dev/install.sh.sig | gpg --decrypt > install.sh
	sh ./install.sh
	rm ./install.sh
fi

# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final 
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"
