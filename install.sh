#!/bin/bash

set -e

[[ $EUID -eq 0 ]] || exec sudo "$0" "$@"

chmod +x ./*.sh

"./base.sh"
"./system.sh"
"./vim.sh"
"./yazi.sh"
"./golang.sh"
"./3proxy.sh"
"./xraycore.sh"

source "./newuser.sh"

newuserhome="/home/$NEW_USERNAME"

mkdir -p "$newuserhome"/tmpscripts
cp ./*.sh "$newuserhome"/tmpscripts/
chown -R "$NEW_USERNAME:$NEW_USERNAME" "$newuserhome"/tmpscripts
chmod +x "$newuserhome"/tmpscripts/*.sh

cat > "$newuserhome"/runscripts.sh <<EOF
#!/bin/bash
cd /home/$NEW_USERNAME/tmpscripts
./ssh.sh
./vim.sh
./yazi.sh
./golang.sh
rm -f /home/$NEW_USERNAME/runscripts.sh
cd ~
rm -rf tmpscripts
chown -R "$NEW_USERNAME":"$NEW_USERNAME" /home/"$NEW_USERNAME"
EOF

chmod +x "$newuserhome"/runscripts.sh
chown "$NEW_USERNAME:$NEW_USERNAME" "$newuserhome"/runscripts.sh

echo "Переключитесь на пользователя $NEW_USERNAME..."
echo "Запустите: ./runscripts.sh"
