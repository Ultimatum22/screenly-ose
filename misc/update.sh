#!/bin/bash

SCREENLY="/home/pi/screenly"

echo "Updating Screenly OSE..."

echo "Ensuring proper permission is set..."
sudo chown -R pi:pi $SCREENLY
sudo chown -R pi:pi /home/pi/screenly_assets
sudo chown -R pi:pi /home/pi/.screenly

echo "Fetching the latest update..."
cd $SCREENLY
git pull

echo "Ensuring all Python modules are installed..."
sudo pip install -r $SCREENLY/requirements.txt -q

echo "Running migration..."
python $SCREENLY/misc/migrate.py

echo "Restarting app-server..."
sudo supervisorctl restart screenly

echo "Restarting viewer module..."
pkill -f "viewer.py"

# Make sure we have proper framebuffer depth.
if grep -q framebuffer_depth /boot/config.txt; then
  sudo sed 's/^framebuffer_depth.*/framebuffer_depth=32/' -i /boot/config.txt
else
  echo 'framebuffer_depth=32' | sudo tee -a /boot/config.txt > /dev/null
fi

# Fix framebuffer bug
if grep -q framebuffer_ignore_alpha /boot/config.txt; then
  sudo sed 's/^framebuffer_ignore_alpha.*/framebuffer_ignore_alpha=1/' -i /boot/config.txt
else
  echo 'framebuffer_ignore_alpha=1' | sudo tee -a /boot/config.txt > /dev/null
fi

echo "Done! Please reboot."
