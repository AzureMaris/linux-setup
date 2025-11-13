#!/usr/bin/env nu

const script_dir_abs_path = path self | path dirname
const script_name = path self | path basename

let screenshot_script_file_abs_path = $script_dir_abs_path | path join 'screenshot.nu'
let kill_window_script_file_abs_path = $script_dir_abs_path | path join 'kill-window.nu'
let pick_color_script_file_abs_path = $script_dir_abs_path | path join 'pick-color.nu'

def main [] {
   let options = [
      "󰹑 Screenshot Screen"
      " Screenshot Window"
      "󰆞 Screenshot Region"
      " Color Pick"
      " Kill Window"
   ]

   let fuzzel_output = try {
      $options | str join (char nl) | fuzzel --dmenu --index | str trim
   } catch {|error|
      save-to-log $error
      return
   }

   if ($fuzzel_output | is-empty) {
      return
   }

   let selected_option = try {
      ($fuzzel_output | into int) + 1
   } catch {|error|
      save-to-log $error
      return
   }

   try {
      match $selected_option {
         1 => { nu $screenshot_script_file_abs_path screen }
         2 => { nu $screenshot_script_file_abs_path window }
         3 => { nu $screenshot_script_file_abs_path region }
         4 => { nu $pick_color_script_file_abs_path }

         5 => {
            nu $kill_window_script_file_abs_path
         }

         _ => {
            save-to-log 'invalid option'
         }
      }
   } catch {|error|
      save-to-log $error
   }
}

def save-to-log [data: any] {
   let script_log_dir_abs_path = $script_dir_abs_path | path join 'logs'

   let script_log_file_abs_path = $script_log_dir_abs_path
   | path join ($script_name | path parse | get stem | $in + .log)

   mkdir $script_log_dir_abs_path
   $data | to text | $in + "\n------------SEPARATOR------------\n" | save -a $script_log_file_abs_path
}
