# [ Fns ]

def 'compact column' [
   --empty (-e) # Also compact empty items like "", {}, and []
   ...rest: string # The columns to compact from the table
] {
   let input = $in

   let column_names = if ($rest | length) > 0 {
      $rest
   } else {
      $input | columns
   }

   let column_names_to_drop = $column_names | par-each {|column_name|
      let column = $input | get $column_name
      let column_length = $column | compact --empty=$empty | length

      if ($column_length) != 0 {
         return
      }

      $column_name
   }

   if ($column_names_to_drop | is-empty) {
      return $input
   }

   $input | reject ...$column_names_to_drop
}

# [ Env ]

$env.config.show_banner = false
$env.config.table.mode = 'compact'

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

$env.LS_COLORS = "di=01;34:ln=01;36:ex=01;31:or=01;31"
$env.EDITOR = "nvim"

# [ Alias ]
# note: for some reason, the rename of the original built-in command will have
# its help info replaced by the new one

alias nu-clear = clear

# This is an alias. More help available at the link below.
# https://www.nushell.sh/commands/docs/clear.html
#
# Clear the terminal.
def clear [
   --keep-scrollback (-k)
] {
   nu-clear --keep-scrollback=$keep_scrollback
   tput cup (term size | get rows)
}

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

# This is an alias. More help available at the link below.
# https://www.nushell.sh/commands/docs/ls.html
#
# List the filenames, sizes, and modification times of items in a directory.
def ls [
   --directory (-D) # List the specified directory itself instead of its contents
   --du (-d) # Display the apparent directory size ("disk usage") in place of the directory metadata size
   --full-paths (-f) # Display paths as absolute paths
   --group-dir (-g) # Group directories together
   --hidden (-H) # Show hidden files
   --long (-l) # Get all available columns for each entry (slower; columns are platform-dependent)
   --mime-type (-m) # Show mime-type in type column instead of 'file' (based on filenames only; files' contents are not examined)
   --pipe-mode (-P) # Do not apply things that might be unwanted with pipes
   --plain (-p) # Show plain files
   --short-names (-s) # Only print the file names, and not the path
   --threads (-t) # Use multiple threads to list contents. Output will be non-deterministic.
   ...patterns: oneof<glob, string> # The glob pattern to use.
]: [nothing -> table] {
   let patterns = if ($patterns | is-empty) {
      [.]
   } else {
      $patterns
   }

   mut ls_output = (
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

   if (not $long) {
      $ls_output = $ls_output
      | select -o name type target mode user group size modified
      | compact column
   }

   if $hidden and not $plain {
      $ls_output = $ls_output | par-each {|item|
         if ($item.name | str starts-with '.') { $item }
      }
   } else if $plain and not $hidden {
      $ls_output = $ls_output | par-each {|item|
         if not ($item.name | str starts-with '.') { $item }
      }
   } else if $plain and $hidden {
      error make {msg: 'hidden and plain flags can not coexist'}
   }

   if $group_dir {
      let grouped_ls_output = $ls_output | group-by {|it|
         if $it.type == dir {
            'dir'
         } else {
            'other'
         }
      }

      if $grouped_ls_output.dir? != null and $grouped_ls_output.other? != null {
         $ls_output = $grouped_ls_output.dir | append $grouped_ls_output.other
      }
   }

   $ls_output | metadata set --datasource-ls
}

def 'git plog' [] {
   git log --graph --oneline --decorate --color
}

# [ Autostart ]

let nu_autoload_dir_abs_path = ($nu.data-dir | path join 'vendor' 'autoload')
mkdir $nu_autoload_dir_abs_path

# [[ Prompt (Starship) ]]

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

# [[ Misc ]]

# keeps my shell in sync with systemd and dbus
try {
   dbus-update-activation-environment --all --systemd
} catch {|error|
   $error | print
}

# [[ Visuals ]]

# wait for window animations (usually lasts around 0.15sec)
# + consider the time it takes to reach here
sleep 0.15sec
tput cup (term size | get rows)
fastfetch -c ($env.HOME | path join '.config' 'fastfetch' 'wezterm.jsonc')
