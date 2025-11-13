use std repeat

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

def path-relative-to [to: path]: path -> path {
   let from = $in | path split
   let to = $to | path split

   let prefix_match_count = $to
   | zip $from
   | enumerate
   | where $it.item.0 == $it.item.1
   | length

   if ($prefix_match_count <= 0) {
      error make {msg: "Paths have nothing in common."}
   }

   let is_same_path = ($prefix_match_count == ($from | length)) and ($prefix_match_count == ($to | length))

   let from_tail = if $is_same_path { $from | last 1 } else { $from | skip $prefix_match_count }
   let to_tail = if $is_same_path { $to | last 1 } else { $to | skip $prefix_match_count }

   ".."
   | repeat ($from_tail | length)
   | append $to_tail
   | path join
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

   # nushell currently uses two different implementation for glob
   # this forces to use the built-in 'glob' implementation
   let file_names: list<string> = $patterns | each --flatten {|pattern|
      glob $pattern
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
      ...$file_names
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

      # glob shows paths as absolute so we need to make relative again
      if $file != null and not $short_names {
         $file = $file | upsert name ($env.PWD | path-relative-to $file.name)
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

alias nu-mkdir = mkdir

# This is a custom 'mkdir' function.
# The original 'mkdir' built-in command can be found as 'nu-mkdir'.
#
# Create directories, with intermediary directories if required using uutils/coreutils mkdir.
def mkdir [
   --verbose (-v) # print a message for each created directory.
   ...directories: oneof<glob, directory>
] {
   mut directories = $directories | par-each {|directory|
      glob $directory
   }

   (
      nu-mkdir
      --verbose=$verbose
   )
}

alias nu-touch = touch

# This is a custom 'touch' function.
# The original 'touch' built-in command can be found as 'nu-touch'.
#
# Creates one or more files.
def touch [
   --reference (-r): path # Use the access and modification times of the reference file/directory instead of the current time
   --timestamp (-t): datetime # Use the given timestamp instead of the current time
   --date (-d): string # Use the given time instead of the current time. This can be a full timestamp or it can be relative to either the current time or reference file time (if given). For more information, see https://www.gnu.org/software/coreutils/manual/html_node/touch-invocation.html
   --modified (-m) # Change only the modification time (if used with -a, access time is changed too)
   --access (-a) # Change only the access time (if used with -m, modification time is changed too)
   --no-create (-c) # Don't create the file if it doesn't exist
   --no-deref (-s) # Affect each symbolic link instead of any referenced file (only for systems that can change the timestamps of a symlink). Ignored if touching stdout
   ...files: oneof<glob, path> # The file(s) to create. '-' is used to represent stdout.
] {
   mut files = $files | par-each {|file|
      glob $file
   }

   (
      nu-touch
      --reference=$reference
      --timestamp=$timestamp
      --date=$date
      --modified=$modified
      --access=$access
      --no-create=$no_create
      --no-deref=$no_deref
      ...$files
   )
}

alias nu-cp = cp

# This is a custom 'cp' function.
# The original 'cp' built-in command can be found as 'nu-cp'.
#
# Copy files using uutils/coreutils cp.
def cp [
   --recursive (-r) # copy directories recursively
   --verbose (-v) # explicitly state what is being done
   --force (-f) # if an existing destination file cannot be opened, remove it and try
   ############## again (this option is ignored when the -n option is also used).
   ############## currently not implemented for windows
   --interactive (-i) # ask before overwriting files
   --update (-u) # copy only when the SOURCE file is newer than the destination file or when the destination file is missing
   --progress (-p) # display a progress bar
   --no-clobber (-n) # do not overwrite an existing file
   --preserve: list<string> # preserve only the specified attributes (empty list means no attributes preserved)
   ########################## if not specified only mode is preserved
   ########################## possible values: mode, ownership (unix only), timestamps, context, link, links, xattr
   --debug # explain how a file is copied. Implies -v
   ...paths: oneof<glob, string> # Copy SRC file/s to DEST
] {
   mut paths = $paths | par-each {|path|
      glob $path
   }

   (
      nu-cp
      --recursive=$recursive
      --verbose=$verbose
      --force=$force
      --interactive=$interactive
      --update=$update
      --progress=$progress
      --no-clobber=$no_clobber
      --preserve=$preserve
      --debug=$debug
      ...$paths
   )
}

alias nu-mv = mv

# This is a custom 'mv' function.
# The original 'mv' built-in command can be found as 'nu-mv'.
#
# Move files or directories using uutils/coreutils mv.
def mv [
   --force (-f) # Do not prompt before overwriting.
   --verbose (-v) # Explain what is being done.
   --progress (-p) # Display a progress bar.
   --interactive (-i) # Prompt before overwriting.
   --update (-u) # Move and overwrite only if source is newer or missing.
   --no-clobber (-n) # Do not overwrite an existing file.
   ...paths: oneof<glob, string> # Rename SRC to DST, or move SRC to DIR.
] {
   mut paths = $paths | par-each {|path|
      glob $path
   }

   (
      nu-mv
      --force=$force
      --verbose=$verbose
      --progress=$progress
      --interactive=$interactive
      --update=$update
      --no-clobber=$no_clobber
      ...$paths
   )
}

alias nu-rm = rm

# This is a custom 'rm' function.
# The original 'rm' built-in command can be found as 'nu-rm'.
#
# Remove files and directories.
def rm [
   --trash (-t) # move to the platform's trash instead of permanently deleting. not used on android and ios
   --permament (-p) # delete permanently, ignoring the 'always_trash' config option. always enabled on android and ios
   --recursive (-r) # delete subdirectories recursively
   --force (-f) # suppress error when no file
   --verbose (-v) # print names of deleted files
   --interactive (-i) # ask user to confirm action
   --interactive-once (-I) # ask user to confirm action only once
   ...paths: oneof<glob, string> # The file paths to remove.
] {
   mut paths = $paths | par-each {|path|
      glob $path
   }

   (
      nu-rm
      --trash=$trash
      --permanent=$permament
      --recursive=$recursive
      --force=$force
      --interactive=$interactive
      --interactive-once=$interactive_once
      ...$paths
   )
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
