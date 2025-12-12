# Provides values when feature is detected: -W, -H, -w, -h, -r and --adaptive-sync.
export def get-gamescope-parameters-for-niri []: nothing -> list<list<string>> {
   let focused_output = niri msg -j focused-output | from json
   let active_config = $focused_output | get modes | get $focused_output.current_mode
   let refresh_rate = $active_config.refresh_rate / 1000

   mut gamescope_parameters: list = [
      [-W $active_config.width]
      [-H $active_config.height]
      [-w $active_config.width]
      [-h $active_config.height]
      [-r $active_config.refresh_rate]
   ]

   if $focused_output.vrr_enabled {
      $gamescope_parameters = $gamescope_parameters | append '--adaptive-sync'
   }

   $gamescope_parameters
}
