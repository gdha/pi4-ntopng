# Build the pi4-ntopng container image
# To build our own image we need to download from  https://db-ip.com/db/lite.php (dates will vary of course) into dat_files directory:
# To comply with the free usage of [IP Geolocation by DB-IP](https://db-ip.com) we mentioned the sponsor.
# 1. dbip-country-lite-2023-09.mmdb.gz
# 2. dbip-city-lite-2023-09.mmdb.gz
# 3. dbip-asn-lite-2023-09.mmdb.gz
# tar czvf  ../dbip.tar.gz *.gz
# and copy these into /root/dat_files of the builder container before building the deb packages.

# To build with a new version: ./build.sh v1.1
if [[ "$1" == "" ]]; then
  # no argument given - we will try to see if we already have old images locally
  CURRENT_SUB_VERSION=$(docker image ls 2>/dev/null| grep pi4-ntopng | grep -v latest | head -1 | awk '{print $2}' | cut -d. -f2)
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

[[ -f builder.log ]] && mv -f builder.log builder.log.old

echo "Building pi4-ntopng:$REL"
docker build --no-cache --progress plain --tag ghcr.io/gdha/pi4-ntopng:$REL --file Dockerfile.builder . | tee -a builder.log

ntopng_version=$(grep 'ntopng version:'  builder.log | tail -1 | cut -d: -f2 | sed -e 's/ //')
docker tag ghcr.io/gdha/pi4-ntopng:$REL ghcr.io/gdha/pi4-ntopng:$ntopng_version

echo "Pushing pi4-ntopng:$ntopng_version to GitHub Docker Container registry"
docker push ghcr.io/gdha/pi4-ntopng:$ntopng_version
