# Build the pi4-ntopng container image
# To build with a new version: ./build.sh v1.1
REL=${1:-v1.0}
cat ~/.ghcr-token | docker login ghcr.io -u gdha --password-stdin
echo "Building pi4-ntopng:$REL"
docker build --tag ghcr.io/gdha/pi4-ntopng:$REL .
#docker tag ghcr.io/gdha/pi4-ntopng:$REL ghcr.io/gdha/pi4-ntopng:latest
#echo "Pushing pi4-ntopng:$REL to GitHub Docker Container registry"
#docker push ghcr.io/gdha/pi4-ntopng:$REL

