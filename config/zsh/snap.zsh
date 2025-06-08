#!/usr/bin/env zsh
# snap - Concatenate readable source files into a single snapshot file
# Usage:
#   snap [--output <file>] [--exclude-git-log] [--exclude-exts <ext1,ext2>] [--verbose] [<directory>]
# Example:
#   snap --output context.txt --exclude-exts mp3,wav,jpg --verbose project/

snap() {
  local source_dir="."
  local output_file="snap.txt"
  local exclude_exts=()
  local include_git_log=true
  local overwrite=false
  local verbose=false

  _snap_usage() {
    cat <<EOF
Usage: snap [OPTIONS] [DIRECTORY]

Concatenates readable source/text files into one snapshot file.

Options:
  --output <file>         Set output file path (default: ./snap.txt)
  --exclude-exts <exts>   Exclude files with these extensions (e.g., mp3,wav,jpg)
  --exclude-git-log       Omit the Git log section (included by default)
  --verbose               Enable verbose logging for debugging
  --help                  Show this help message

Example:
  snap --output combined.txt --exclude-exts mp3,wav,jpg,png --verbose
EOF
  }

  _snap_error() {
    echo "snap: $1" >&2
    return 1
  }

  _snap_log() {
    $verbose && echo "snap: $1" >&2
  }

  _snap_is_text_file() {
    local mime_type
    mime_type=$(file --mime-type -b "$1" 2>/dev/null)
    
    # Include text files and some specific formats
    case "$mime_type" in
      text/*|application/json|application/xml|application/javascript|application/x-sh) 
        _snap_log "Text file detected: $1 ($mime_type)"
        return 0 ;;
      *) 
        _snap_log "Non-text file: $1 ($mime_type)"
        return 1 ;;
    esac
  }

  _snap_is_excluded_ext() {
    local f="$1"
    for ext in "${exclude_exts[@]}"; do
      if [[ "$f" == *.$ext ]]; then
        _snap_log "Excluded by extension '$ext': $f"
        return 0
      fi
    done
    return 1
  }

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --output)
        [[ -z "$2" ]] && _snap_error "Missing value for --output" && return 1
        output_file="$2"
        overwrite=true
        shift 2
        ;;
      --exclude-exts)
        [[ -z "$2" ]] && _snap_error "Missing value for --exclude-exts" && return 1
        # Use zsh-compatible array splitting
        exclude_exts=("${(@s/,/)2}")
        shift 2
        ;;
      --exclude-git-log)
        include_git_log=false
        shift
        ;;
      --verbose)
        verbose=true
        shift
        ;;
      --help)
        _snap_usage
        return 0
        ;;
      -*)
        _snap_error "Unknown option: $1" && return 1
        ;;
      *)
        source_dir="$1"
        shift
        ;;
    esac
  done

  [[ ! -d "$source_dir" ]] && _snap_error "Directory '$source_dir' does not exist" && return 1
  
  local abs_source_dir abs_output_file
  abs_source_dir="$(cd "$source_dir" && pwd)"
  abs_output_file="$(realpath "$output_file")"

  _snap_log "Source directory: $abs_source_dir"
  _snap_log "Output file: $abs_output_file"
  _snap_log "Include git log: $include_git_log"
  _snap_log "Excluded extensions: ${exclude_exts[*]:-"none"}"

  if [[ "$abs_output_file" != "$PWD/snap.txt" && "$overwrite" != true && -f "$abs_output_file" ]]; then
    _snap_error "Refusing to overwrite existing file '$abs_output_file'. Use --output to override." && return 1
  fi

  : > "$abs_output_file" || return 1

  # Git log section
  if $include_git_log && [[ -d "$abs_source_dir/.git" ]]; then
    _snap_log "Adding git log section"
    echo "# Git Log (git adog3)" >> "$abs_output_file"
    git -C "$abs_source_dir" log --all --decorate --oneline --graph >> "$abs_output_file"
    echo -e "\n# ----------------------------------------\n" >> "$abs_output_file"
  else
    _snap_log "Skipping git log (not enabled or no .git directory)"
  fi

  # File processing counters
  local text_files=0 binary_files=0 excluded_files=0 total_files=0

  # Build find command to exclude common directories and find only files
  local find_cmd=(
    find "$abs_source_dir"
    -name ".git" -prune -o
    -name "node_modules" -prune -o
    -name ".venv" -prune -o
    -name "venv" -prune -o
    -name "__pycache__" -prune -o
    -name "dist" -prune -o
    -name "build" -prune -o
    -name ".next" -prune -o
    -name "target" -prune -o
    -type f -print0
  )

  _snap_log "Find command excludes: .git, node_modules, .venv, venv, __pycache__, dist, build, .next, target"
  _snap_log "Find command: ${find_cmd[*]}"

  # Process files efficiently with find exclusions
  while IFS= read -r -d '' file; do
    ((total_files++))
    
    if [[ "$(realpath "$file")" == "$abs_output_file" ]]; then
      _snap_log "Skipping output file: $file"
      continue
    fi
    
    # Check excluded extensions
    if _snap_is_excluded_ext "$file"; then
      ((excluded_files++))
      continue
    fi
    
    local rel_path="${file#$abs_source_dir/}"
    echo "# $rel_path" >> "$abs_output_file"
    
    if _snap_is_text_file "$file"; then
      # Include full content for text files
      _snap_log "Processing text file: $rel_path"
      cat "$file" >> "$abs_output_file"
      ((text_files++))
    else
      # Reference-only for non-text files
      local mime_type=$(file --mime-type -b "$file" 2>/dev/null || echo "unknown")
      _snap_log "Non-text file referenced: $rel_path ($mime_type)"
      echo "# [Non-text file: $mime_type - content excluded]" >> "$abs_output_file"
      ((binary_files++))
    fi
    
    echo -e "\n\n" >> "$abs_output_file"
  done < <("${find_cmd[@]}")

  # Summary
  echo "Files concatenated to $abs_output_file"
  if $verbose; then
    echo "Summary:"
    echo "  Total files found: $total_files"
    echo "  Text files processed: $text_files"
    echo "  Non-text files referenced: $binary_files"
    echo "  Files excluded by extension: $excluded_files"
  fi
}
