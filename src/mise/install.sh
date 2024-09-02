#!/bin/sh
set -e

. /etc/os-release

if [ "${ID}" != "debian" ] && [ "${ID}" != "ubuntu" ]; then
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


# The following was adapted from https://github.com/houseabsolute/ubi/blob/af9a0b237b303d91e74519130b28f697a46d5a1f/bootstrap/bootstrap-ubi.sh

if [ -n "$UBI_DEBUG_BOOTSTRAP" ]; then
    set -x
fi

set -e

if [ "$(id -u)" -eq 0 ]; then
    TARGET="/usr/local/bin"
else
    TARGET="$HOME/.local/bin"
	mkdir -p "${TARGET}"
fi

if [ ! -d "$TARGET" ]; then
    >&2 echo "ubi: The install target directory, \`$TARGET\`, does not exist"
    exit 3
fi

cd "$TARGET"

KERNEL=$(uname -s)
LIBC="-musl"
EXT="tar.gz"
OS="Linux"
ARCH=$(uname -m)

case "$ARCH" in
i386 | i486 | i586 | i686)
	CPU="i786"
	;;
x86_64 | amd64)
	CPU="x86_64"
	;;
arm | armv5* | armv6* | armv7*)
	CPU="arm"
	;;
aarch64 | arm64)
	CPU="aarch64"
	;;
*)
	echo "ubi: Cannot determine what binary to download for your CPU architecture: $ARCH"
	exit 4
	;;
esac

FILENAME="ubi-$OS-$CPU$LIBC.$EXT"

if [ -z "$TAG" ]; then
    URL="https://github.com/houseabsolute/ubi/releases/latest/download/$FILENAME"
else
    URL="https://github.com/houseabsolute/ubi/releases/download/$TAG/$FILENAME"
fi

TEMPDIR="$(mktemp -d)"
trap 'rm -rf -- "$TEMPDIR"' EXIT
LOCAL_FILE="$TEMPDIR/$FILENAME"

echo "downloading $URL"
STATUS=$(curl --silent --show-error --location --output "$LOCAL_FILE" --write-out "%{http_code}" "$URL")
if [ -z "$STATUS" ]; then
    >&2 echo "curl failed to download $URL and did not print a status code"
    exit 5
elif [ "$STATUS" != "200" ]; then
    >&2 echo "curl failed to download $URL - status code = $STATUS"
    exit 6
fi

if echo "$FILENAME" | grep "\\.tar\\.gz$"; then
    tar -xzf "$LOCAL_FILE" ubi
else
    unzip "$LOCAL_FILE"
fi

rm -rf -- "$TEMPDIR"

if [ "${ACTIVATE}" = "true" ]; then
	echo "Setting up 'mise activate'..."

	echo -n "    - bash..."
	/usr/bin/echo -e '\neval "$(mise env --shell bash)"' > /etc/profile.d/10-mise.sh
	chmod a+x /etc/profile.d/10-mise.sh
	/usr/bin/echo -e '\neval "$(mise activate bash)"' >> /etc/bash.bashrc
	echo "done"

	if [ -e /etc/zsh ]; then
		echo -n "    - zsh..."
		/usr/bin/echo -e '\neval "$(mise hook-env --shell zsh)"' >> /etc/zsh/zshenv
		/usr/bin/echo -e '\neval "$(mise activate zsh)"' >> /etc/zsh/zshrc
		echo "done"
	fi
fi
