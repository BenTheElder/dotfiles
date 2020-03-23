
host=$(uname | tr '[:upper:]' '[:lower:]')
installer="installer_${host}"
url="https://storage.googleapis.com/golang/getgo/${installer}"
read -p "Installing go from ${url}, y/n? " yn
if [ "${yn}" != 'y' ]; then
  echo "Cancelled"
  exit
fi
echo "Proceeding to install ..."
echo ""
tmp=$(mktemp -d)
trap 'rm -rf ${tmp:?}' EXIT INT
cd "${tmp}"
wget "${url}"
chmod +x ./installer_linux
./installer_linux