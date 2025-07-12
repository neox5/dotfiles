#!/usr/bin/env bash

# Define allowed MACs and their associated metadata
declare -A device_names=(
  ["38:18:4C:BE:26:B9"]="Sony XM3"
  ["34:81:F4:F8:93:C3"]="SOUNDBOKS"
)

declare -A device_classes=(
  ["38:18:4C:BE:26:B9"]="sonyxm3"
  ["34:81:F4:F8:93:C3"]="soundboks"
)

output=()
active_class=""

# Check connection status
for mac in "${!device_names[@]}"; do
  info=$(bluetoothctl info "$mac")
  connected=$(awk -F': ' '/Connected:/ {print $2}' <<< "$info")

  if [[ "$connected" == "yes" ]]; then
    name="${device_names[$mac]}"
    class="${device_classes[$mac]}"
    output+=("$name")
    active_class="$class"
  fi
done

# Output for Waybar
if [[ ${#output[@]} -gt 0 ]]; then
  text=$(IFS=', '; echo "${output[*]}")
  echo "{\"text\": \"$text\", \"tooltip\": \"Audio: ${output[*]}\", \"class\": \"$active_class\"}"
else
  echo '{"text": "", "tooltip": ""}'
fi
