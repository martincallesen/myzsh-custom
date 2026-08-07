# Linux Mint (Xfce): disable sleep / suspend via power manager + systemd.

sleep-disable() {
  echo "Disabling sleep and suspend..."
  if command -v xfconf-query >/dev/null 2>&1; then
    # 0 = never / do nothing
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-on-ac -n -t int -s 0
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-on-battery -n -t int -s 0
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-ac -n -t int -s 0
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-battery -n -t int -s 0
    echo "  Xfce: idle sleep off, lid close does nothing"
  fi
  sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
  echo "Sleep and suspend are disabled. Run sleep-enable to restore."
}

sleep-enable() {
  echo "Enabling sleep and suspend..."
  sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
  if command -v xfconf-query >/dev/null 2>&1; then
    # Restore common defaults: 30 min inactivity, suspend on lid close
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-on-ac -n -t int -s 30
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-on-battery -n -t int -s 15
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-ac -n -t int -s 1
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-battery -n -t int -s 1
    echo "  Xfce: idle sleep restored (30m AC / 15m battery), lid closes suspend"
  fi
  echo "Sleep and suspend are enabled again."
}
