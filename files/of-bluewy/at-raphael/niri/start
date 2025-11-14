#!/usr/bin/env nu

def main [] {
   systemctl --user cat wayland-wm@niri.service
   | complete
   | if ($in.exit_code > 0) {
      uwsm start -U=home -o -- niri --session
   } else {
      systemctl --user start wayland-wm@niri.service
   }

   loop {
      systemctl --user is-active --quiet wayland-wm@niri.service
      | complete
      | if ($in.exit_code == 0) {
         break
      }

      sleep 0.5sec
   }

   with-env {
      DISPLAY: 0
   } {
      (
         systemctl
         --user
         import-environment
         DISPLAY
         SDL_VIDEODRIVER
         CLUTTER_BACKEND
         QT_QPA_PLATFORM
         QT_QPA_PLATFORMTHEME
         _JAVA_AWT_WM_NONREPARENTING
      )
   }

   systemctl --user start xwayland-satellite.service

   run-single-instance-per-user io.elementary.desktop.agent-polkit {
      runapp /usr/lib/policykit-1-pantheon/io.elementary.desktop.agent-polkit
   }

   run-single-instance-per-user qs { runapp -i session-graphical.slice -- qs -c noctalia-shell }
   run-single-instance-per-user hypridle { runapp hypridle }

   run-single-instance-per-user wayland-pipewire-idle-inhibit {
      runapp wayland-pipewire-idle-inhibit
   }

   run-single-instance-per-user keepassxc { runapp keepassxc }
}

def run-single-instance-per-user [
   --user: string # The name of the user that owns the process.
   process_name: string # The name of the process it should check with.
   closure: closure # The closure to run if there is no conflict.
] {
   mut user = $user

   if ($user == null) {
      $user = $env.LOGNAME
   }

   ps -l | where {|process|
      $process.name == $process_name and (id -nu $process.user_id) == $env.LOGNAME
   } | if ($in | is-empty) {
      do $closure
   }
}
