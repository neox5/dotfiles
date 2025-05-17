# snap - Concatenate readable source files into a single snapshot file
# Usage:
#   snap [--output <file>] [--exclude <pattern>] [--extensions <ext1,ext2>] [--exclude-git-log] [<directory>]
# Example:
#   snap --output context.txt --extensions py,md project/

snap() {
  local source_dir="."
  local output_file="snap.txt"
  local exclude_patterns=(".git" "node_modules" "venv" "dist" "build")
  local user_excludes=()
  local extensions=()
  local include_git_log=true
  local overwrite=false

  _snap_usage() {
    cat <<EOF
Usage: snap [OPTIONS] [DIRECTORY]

Concatenates readable source/text files into one snapshot file for LLM workflows.

Options:
  --output <file>         Set output file path (default: ./snap.txt)
  --exclude <pattern>     Exclude paths matching this pattern (repeatable)
  --extensions <exts>     Include only files with these extensions (e.g., py,md,go)
  --exclude-git-log       Omit the Git log section (included by default)
  --help                  Show this help message

Example:
  snap --output combined.txt --extensions py,md --exclude node_modules --exclude testdata/
EOF
  }

  _snap_error() {
    echo "snap: $1" >&2
    return 1
  }

  _snap_is_text_file() {
    file --mime-type -b "$1" 2>/dev/null | grep -q '^text/'
  }

  _snap_should_include() {
    local f="$1"
    for ex in "${user_excludes[@]}" "${exclude_patterns[@]}"; do
      [[ "$f" == *"/$ex/"* || "$f" == *"/$ex" || "$f" == "$ex" ]] && return 1
    done
    if [[ ${#extensions[@]} -gt 0 ]]; then
      for ext in "${extensions[@]}"; do
        [[ "$f" == *.$ext ]] && return 0
      done
      return 1
    fi
    return 0
  }

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --output)
        [[ -z "$2" ]] && _snap_error "Missing value for --output" && return 1
        output_file="$2"
        overwrite=true
        shift 2
        ;;
      --exclude)
        [[ -z "$2" ]] && _snap_error "Missing value for --exclude" && return 1
        user_excludes+=("$2")
        shift 2
        ;;
      --extensions)
        [[ -z "$2" ]] && _snap_error "Missing value for --extensions" && return 1
        IFS=',' read -r -A extensions <<< "$2"
        shift 2
        ;;
      --exclude-git-log)
        include_git_log=false
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

  if [[ "$abs_output_file" != "$PWD/snap.txt" && "$overwrite" != true && -f "$abs_output_file" ]]; then
    _snap_error "Refusing to overwrite existing file '$abs_output_file'. Use --output to override." && return 1
  fi

  : > "$abs_output_file" || return 1

  # Git log section
  if $include_git_log && [[ -d "$abs_source_dir/.git" ]]; then
    echo "# Git Log (git adog3)" >> "$abs_output_file"
    git -C "$abs_source_dir" log --all --decorate --oneline --graph >> "$abs_output_file"
    echo -e "\n# ----------------------------------------\n" >> "$abs_output_file"
  fi

  # Concatenate project files
  find "$abs_source_dir" -type f ! -path '*/.*' | sort | while IFS= read -r file; do
    [[ "$(realpath "$file")" == "$abs_output_file" ]] && continue
    _snap_should_include "$file" || continue
    _snap_is_text_file "$file" || continue

    local rel_path="${file#$abs_source_dir/}"
    echo "# $rel_path" >> "$abs_output_file"
    cat "$file" >> "$abs_output_file"
    echo -e "\n\n" >> "$abs_output_file"
  done

  echo "Files concatenated to $abs_output_file"
}
