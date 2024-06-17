# Build the pi4-ntopng container image
# To build with a new version: ./build.sh v1.1
if [[ "$1" == "" ]]; then
  # no argument given - we will try to see if we already have old images locally
  CURRENT_SUB_VERSION=$(docker image ls 2>/dev/null| grep pi4-ntopng | grep -v latest | grep ' v' | head -1 | awk '{print $2}'| cut -d. -f2)
  if [[ "$CURRENT_SUB_VERSION" == "" ]]; then
    REL=${1:-v1.0}
  else
    NEW_SUB_VERSION=$((CURRENT_SUB_VERSION + 1))
    REL="v1.${NEW_SUB_VERSION}"
  fi
else
  # We have an argument on the command line, e.g. v1.6
  REL=${1:-v1.0}
fi
cat ~/.ghcr-token | docker login ghcr.io -u gdha --password-stdin
echo "Building pi4-ntopng:$REL"
docker build --tag ghcr.io/gdha/pi4-ntopng:$REL .
#docker tag ghcr.io/gdha/pi4-ntopng:$REL ghcr.io/gdha/pi4-ntopng:latest
echo "Pushing pi4-ntopng:$REL to GitHub Docker Container registry"
docker push ghcr.io/gdha/pi4-ntopng:$REL

