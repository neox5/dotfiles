# snap - Concatenate readable source files into a single snapshot file
# Usage:
#   snap [--output <file>] [--include <pattern>] [--exclude <pattern>] [--exclude-git-log] [<directory>]
# Example:
#   snap --output context.txt --include "*.py" --include "*.md" --exclude "**/*_test.py" project/

snap() {
  local source_dir="."
  local output_file="snap.txt"
  local include_patterns=()
  local exclude_patterns=()
  local include_git_log=true
  local overwrite=false

  # Default excludes - always applied
  local default_excludes=(
    ".git/**" "node_modules/**" ".venv/**" "venv/**" "__pycache__/**"
    ".pytest_cache/**" "dist/**" "build/**" "target/**" "vendor/**"
    "*.log" "*.tmp" "**/snap.txt" "**/*.snap.txt"
  )

  # Binary/media file extensions - mentioned but content omitted
  local binary_extensions=(
    "*.exe" "*.dll" "*.so" "*.dylib" "*.a"
    "*.zip" "*.tar" "*.gz" "*.7z" "*.rar"
    "*.png" "*.jpg" "*.jpeg" "*.gif" "*.bmp" "*.tiff" "*.webp"
    "*.mp4" "*.mp3" "*.avi" "*.mov" "*.mkv" "*.wav" "*.flac"
    "*.pdf" "*.doc" "*.docx" "*.xls" "*.xlsx" "*.ppt" "*.pptx"
  )

  _snap_usage() {
    cat <<EOF
Usage: snap [OPTIONS] [DIRECTORY]

Concatenates readable source/text files into one snapshot file.

Options:
  --output <file>         Set output file path (default: ./snap.txt)
  --include <pattern>     Include files matching this glob pattern (repeatable)
  --exclude <pattern>     Exclude files matching this glob pattern (repeatable)
  --exclude-git-log       Omit the Git log section (included by default)
  --help                  Show this help message

Examples:
  snap                                    # Basic usage with sensible defaults
  snap --include "vendor/**/*.go"         # Rescue Go files from excluded vendor/
  snap --exclude "**/*_test.py"           # Exclude test files beyond defaults
  snap --output project.txt --include "src/**/*.{js,ts}" --exclude "src/**/*.spec.js"

Default exclusions: .git/, node_modules/, build directories, caches, logs, and binary files.
Include patterns override excludes (useful for rescuing specific files from excluded directories).

Binary files are listed but their content is omitted for readability.
EOF
  }

  _snap_error() {
    echo "snap: $1" >&2
    return 1
  }

  _snap_is_text_file() {
    file --mime-type -b "$1" 2>/dev/null | grep -q -E '^(text/|application/json)'
  }

  _snap_is_known_text_extension() {
    local file="$1"
    local text_extensions=(
      "*.md" "*.txt" "*.json" "*.yaml" "*.yml" "*.toml" "*.ini" "*.conf" "*.cfg"
      "*.sh" "*.bash" "*.zsh" "*.fish"
      "*.c" "*.h" "*.cpp" "*.hpp" "*.cc" "*.cxx"
      "*.go" "*.rs" "*.py" "*.rb" "*.pl" "*.php"
      "*.js" "*.ts" "*.jsx" "*.tsx" "*.mjs" "*.cjs"
      "*.lua" "*.vim" "*.el" "*.clj" "*.cljs"
      "*.html" "*.xml" "*.css" "*.scss" "*.sass" "*.less"
      "*.sql" "*.graphql" "*.proto"
      "*.Dockerfile" "Dockerfile" "Makefile" "*.mk"
      ".gitignore" ".dockerignore" ".editorconfig" ".eslintrc" ".prettierrc"
    )
    
    for pattern in "${text_extensions[@]}"; do
      if _snap_matches_pattern "$file" "$pattern"; then
        return 0
      fi
    done
    return 1
  }

  _snap_matches_pattern() {
    local file="$1"
    local pattern="$2"
    local rel_path="${file#$abs_source_dir/}"
    
    # Use zsh's built-in pattern matching with extended_glob
    setopt local_options extended_glob
    [[ "$rel_path" == ${~pattern} ]]
  }

  _snap_is_binary_extension() {
    local file="$1"
    for pattern in "${binary_extensions[@]}"; do
      if _snap_matches_pattern "$file" "$pattern"; then
        return 0
      fi
    done
    return 1
  }

  _snap_should_include() {
    local f="$1"
    local excluded=false
    local rescued=false
    
    # Check default excludes first
    for pattern in "${default_excludes[@]}"; do
      if _snap_matches_pattern "$f" "$pattern"; then
        excluded=true
        break
      fi
    done
    
    # Check user excludes if not already excluded
    if [[ "$excluded" != "true" ]]; then
      for pattern in "${exclude_patterns[@]}"; do
        if _snap_matches_pattern "$f" "$pattern"; then
          excluded=true
          break
        fi
      done
    fi
    
    # If include patterns are specified, they work as RESCUE patterns
    if [[ ${#include_patterns[@]} -gt 0 ]]; then
      # Check if file matches any include pattern (rescues excluded files)
      for pattern in "${include_patterns[@]}"; do
        if _snap_matches_pattern "$f" "$pattern"; then
          rescued=true
          break
        fi
      done
      
      # Include file if either:
      # 1. It was rescued by an include pattern, OR
      # 2. It wasn't excluded in the first place
      if [[ "$rescued" == "true" || "$excluded" != "true" ]]; then
        return 0
      else
        return 1
      fi
    else
      # No include patterns - just check exclusions
      if [[ "$excluded" == "true" ]]; then
        return 1
      fi
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
      --include)
        [[ -z "$2" ]] && _snap_error "Missing value for --include" && return 1
        include_patterns+=("$2")
        shift 2
        ;;
      --exclude)
        [[ -z "$2" ]] && _snap_error "Missing value for --exclude" && return 1
        exclude_patterns+=("$2")
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
  find "$abs_source_dir" -type f | sort | while IFS= read -r file; do
    [[ "$(realpath "$file")" == "$abs_output_file" ]] && continue
    _snap_should_include "$file" || continue

    local rel_path="${file#$abs_source_dir/}"
    echo "# $rel_path" >> "$abs_output_file"
    
    # Check if it's a binary file by extension
    if _snap_is_binary_extension "$file"; then
      echo "[Binary file - content omitted]" >> "$abs_output_file"
    elif _snap_is_known_text_extension "$file"; then
      cat "$file" >> "$abs_output_file"
    elif _snap_is_text_file "$file"; then
      cat "$file" >> "$abs_output_file"
    else
      echo "[Non-text file - content omitted]" >> "$abs_output_file"
    fi
    
    echo -e "\n\n" >> "$abs_output_file"
  done

  echo "Files concatenated to $abs_output_file"
}
