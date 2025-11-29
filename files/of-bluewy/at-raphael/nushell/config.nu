# [ Fns ]

def 'compact column' [
   --empty (-e) # Also compact empty items like "", {}, and []
   ...column_names_to_drop: string # The columns to compact from the table
] {
   let columns = $in

   let column_names_to_drop = if ($column_names_to_drop | length) > 0 {
      $column_names_to_drop
   } else {
      $columns | columns
   }

   let column_names_to_drop = $column_names_to_drop | par-each {|column_name|
      let column = $columns | get $column_name
      let column_length = $column | compact --empty=$empty | length

      if ($column_length) != 0 {
         return
      }

      $column_name
   }

   if ($column_names_to_drop | is-empty) {
      return $columns
   }

   $columns | reject ...$column_names_to_drop
}

# [ Env ]

$env.config.show_banner = false
$env.config.table.mode = 'thin'

# [[ XDG ]]

$env.XDG_CONFIG_HOME = $env.HOME | path join '.config'
$env.XDG_DATA_HOME = $env.HOME | path join '.local' 'share'
$env.XDG_STATE_HOME = $env.HOME | path join '.local' 'state'
$env.XDG_CACHE_HOME = $env.HOME | path join '.cache'

# [[ xdg-ninja ]]

$env.HISTFILE = $env.XDG_STATE_HOME | path join 'bash' 'history'
$env.CARGO_HOME = $env.XDG_DATA_HOME | path join 'cargo'
$env.GOPATH = $env.XDG_DATA_HOME | path join 'go'
$env.GTK2_RC_FILES = $env.XDG_CONFIG_HOME | path join 'gtk-2.0' 'gtkrc'
$env.NODE_REPL_HISTORY = $env.XDG_STATE_HOME | path join 'node_repl_history'

$env.NPM_CONFIG_INIT_MODULE = $env.XDG_CONFIG_HOME
| path join "npm" "config" "npm-init.js"

$env.NPM_CONFIG_CACHE = $env.XDG_CACHE_HOME | path join 'npm'
$env.NPM_CONFIG_TMP = $env.XDG_RUNTIME_DIR | path join 'npm'
$env.RUSTUP_HOME = $env.XDG_DATA_HOME | path join 'rustup'
$env.WINEPREFIX = $env.XDG_DATA_HOME | path join 'wine'

# [[ Path ]]

$env.PATH = $env.PATH | append [
   ($env.HOME | path join $env.XDG_DATA_HOME '.cargo' 'bin')
   ($env.HOME | path join '.local' 'bin')
]

# [[ Other ]]

$env.LS_COLORS = "di=01;34:ln=01;36:ex=01;35:or=01;31"
$env.EDITOR = "nvim"

# [ Alias ]

# for some reason, the alias of the original built-in command will have
# its help info replaced by custom function

alias nu-clear = clear

# This is a custom 'clear' function.
# The original 'clear' built-in command can be found as 'nu-clear'.
#
# Clear the terminal.
def clear [
   --keep-scrollback (-k)
] {
   nu-clear --keep-scrollback=$keep_scrollback
   tput cup (term size | get rows)
}

# Uses 'paru' under the hood. Makes a stronger distinction between 'std' and 'aur'.
#
# Manage system packages.
#
# -S for 'std'
# -A for 'aur'
# -W for 'std' and 'aur'
def --wrapped aura [...arguments] {
   let command = $arguments | reduce --fold ['paru'] {|argument command|
      if not ($argument =~ '^-[a-zA-Z]+$') {
         return ($command | append $argument)
      }

      $argument
      | split chars
      | skip 1
      | reduce --fold $command {|char flag|
         $flag | append (
            match $char {
               'S' => ['-S' '--repo']
               'A' => ['-S' '--aur']
               'W' => ['-S']
               _ => [('-' + $char)]
            }
         )
      }
   }

   run-external ...$command
}

alias nu-ls = ls

# This is a custom 'ls' function.
# The original 'ls' built-in command can be found as 'nu-ls'.
#
# List the filenames, sizes, and modification times of items in a directory.
def ls [
   --directory (-D) # List the specified directory itself instead of its contents
   --du (-d) # Display the apparent directory size ("disk usage") in place of the directory metadata size
   --full-paths (-f) # Display paths as absolute paths
   --group-dir (-g) # Group directories together
   --plain (-p) # Show only plain files.
   --long (-l) # Get all available columns for each entry (slower; columns are platform-dependent)
   --mime-type (-m) # Show mime-type in type column instead of 'file' (based on filenames only; files' contents are not examined)
   --hidden (-H) # Show only hidden files.
   --short-names (-s) # Only print the file names, and not the path.
   --threads (-t) # Use multiple threads to list contents. Output will be non-deterministic.
   ...patterns: oneof<glob, string> # The glob pattern to use.
]: [nothing -> table] {
   mut patterns = $patterns

   if ($patterns | is-empty) {
      $patterns = [.]
   }

   mut files = (
      nu-ls
      --all=true
      --long=true
      --short-names=$short_names
      --full-paths=$full_paths
      --du=$du
      --directory=$directory
      --mime-type=$mime_type
      --threads=$threads
      ...$patterns
   )

   if not $long {
      $files = $files
      | select -o name type target mode user group size modified
      | compact column
   }

   $files = $files | par-each {|file|
      mut file: oneof<record, nothing> = $file

      if $file != null and ($file.name == '' or $file.name == '..') {
         $file = null
      }

      if $file != null and $plain and ($file.name | str starts-with '.') {
         $file = null
      }

      if $file != null and $hidden and not ($file.name | str starts-with '.') {
         $file = null
      }

      $file
   }

   if $group_dir {
      let files_grouped = $files | group-by {|file|
         if $file.type == dir {
            'dir'
         } else {
            'other'
         }
      }

      if $files_grouped.dir? != null and $files_grouped.other? != null {
         $files = $files_grouped.dir | append $files_grouped.other
      }
   }

   $files | metadata set --datasource-ls
}

def 'git plog' [] {
   git log --graph --oneline --decorate --color
}

# [ Autostart ]

let nu_autoload_dir_abs_path = ($nu.data-dir | path join 'vendor' 'autoload')

try {
   mkdir $nu_autoload_dir_abs_path

   # [[ Systemd & Dbus ]]

   try {
      dbus-update-activation-environment --all --systemd
   } catch {|error|
      $error.rendered | print
   }

   # [[ Prompt (Starship) ]]

   try {
      do {||
         if (which starship | is-empty) {
            return
         }

         let starship_init_file_abs_path = (
            $nu_autoload_dir_abs_path | path join 'starship.nu'
         )

         let starship_init_file = starship init nu

         if (
            ($starship_init_file_abs_path | path exists) and
            ($starship_init_file == (open --raw $starship_init_file_abs_path))
         ) {
            return
         }

         $starship_init_file | save -f $starship_init_file_abs_path
      }
   } catch {|error|
      $error.rendered | print
   }
} catch {|error|
   $error.rendered
}

# [[ Visuals ]]

# wait for window animations (usually lasts around 0.15sec)
# + consider the time it takes to reach here
sleep 0.15sec

try {
   tput cup (term size | get rows)
   fastfetch -c ($env.HOME | path join '.config' 'fastfetch' 'wezterm.jsonc')
} catch {|error|
   $error.rendered | print
}
