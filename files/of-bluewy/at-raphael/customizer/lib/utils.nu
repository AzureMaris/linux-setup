export def get-customizer-dir-path []: nothing -> path {
   $env.XDG_RUNTIME_DIR | path join customizer
}
