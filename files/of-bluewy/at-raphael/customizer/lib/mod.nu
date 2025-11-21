#!/usr/bin/env nu

const mangohud_config_values = [
   legacy_layout=false

   horizontal
   horizontal_stretch=0

   round_corners=0
   position=top-center
   table_columns=1

   background_alpha=0.0
   background_color=1E2127

   text_color=ABB2BF
   text_outline_thickness=2

   font_size=26
   font_file=/usr/share/fonts/TTF/IosevkaTermNerdFontMono-Regular.ttf

   cpu_color=61AFEF
   cpu_text=CPU
   cpu_stats
   cpu_power
   cpu_temp

   ram_color=E06C75
   ram

   gpu_color=98C379
   gpu_text=GPU
   gpu_stats
   gpu_junction_temp
   gpu_power

   vram_color=C678DD
   vram

   engine_color=d19a66
   engine_short_names

   fps
   fps_metrics=0.001

   frametime_color=98C379
   frame_timing

   fps_limit_method=late
   fps_limit=0

   output_folder=/home/bluewy/downloads
   log_duration=30
   autostart_log=0
   log_interval=100

   toggle_fps_limit=Shift_L+F1
   toggle_logging=Shift_L+F2
   toggle_hud_position=Shift_R+F11
   toggle_hud=Shift_R+F12

   hud_no_margin=1
]

export const steam_env = {
   LD_PRELOAD: ''
}

export const proton_env = {
   PROTON_ENABLE_WAYLAND: 1
   PROTON_NO_WM_DECORATION: 1

   PROTON_USE_NTSYNC: 1

   PROTON_FSR4_RDNA3_UPGRADE: 1
   PROTON_FSR4_UPGRADE: 1
   PROTON_FSR4_INDICATOR: 1

   PROTON_DLSS_UPGRADE: 1
   PROTON_DLSS_INDICATOR: 1

   PROTON_XESS_UPGRADE: 1

   DXVK_ASYNC: 1
   DXVK_STATE_CACHE: 1

   __GL_SHADER_DISK_CACHE: 1
   __GL_SHADER_DISK_CACHE_SKIP_CLEANUP: 1

   RADV_PERFTEST: aco
   STAGING_SHARED_MEMORY: 1
}

export const gamescope_parameters = [
   gamescope
   --backend
   wayland
   -W
   1920
   -H
   1080
   -w
   1920
   -h
   1080
   -r
   240
   -s
   0.25
   --immediate-flips
   --adaptive-sync
   --force-grab-cursor
]

export def get-mangohud-config-env [
   --upsert-values: list<record<old: oneof<string, nothing>, new: string>>
]: nothing -> record {
   let mangohud_config_values = $mangohud_config_values | each {|mangohud_config_value|
      let mangohud_config_values_to_update = $upsert_values | where {|upsert_value|
         $mangohud_config_value == $upsert_value.old
      }

      if ($mangohud_config_values_to_update | is-empty) {
         return $mangohud_config_value
      }

      $mangohud_config_values_to_update.new
   }

   let mangohud_config_values_to_insert = $upsert_values | where {|upsert_value|
      $upsert_value.new not-in $mangohud_config_values
   }

   let mangohud_config_values = $mangohud_config_values | append $mangohud_config_values_to_insert

   {
      MANGOHUD_CONFIG: ($mangohud_config_values | str join ',')
   }
}
