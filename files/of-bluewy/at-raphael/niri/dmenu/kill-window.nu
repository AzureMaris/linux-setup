#!/usr/bin/env nu

const script_dir_abs_path = path self | path dirname
const script_name = path self | path basename

def main [] {
   let window_or_null = try {
      niri msg --json pick-window | from json
   } catch {|error|
      save-to-log $error
      return
   }

   if $window_or_null == null {
      save-to-log "window picked is null"
      return
   }

   try {
      kill -s 9 $window_or_null.pid
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
