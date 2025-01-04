#!/bin/bash

# VERSIONING & PROJECT INFORMATION
SCRIPT_VERSION="1.0.2"
PROJECT_NAME="nata"
PROJECT_REPO="https://github.com/mdSlash/$PROJECT_NAME"

if [[ -z $DRY_RUN ]]; then
  # OPTIONS
  OPTIONS=()    # Stores entered options and their values if specified.
  QUIET_MODE="" # Run in quiet mode.
  WIN_CLASS=""  # The class of the matched window rule or "class" option.
  WIN_TITLE=""  # The title of the matched window rule or "title" option.

  # WINDOW MATCHING RULE
  export ACTIVE_WIN_CLASS="" # The class of the active window or "class" option..
  export ACTIVE_WIN_TITLE="" # The title of the active window or "title" option..
  export LAYER_NAME=""       # Layer name for the matched window rule or "layer" option.

  # CONFIG
  export CONFIG_FILE="$HOME/.config/kanata/config.json"
  export RECIPES_SCRIPT="$HOME/.config/kanata/recipes.sh"
  export CONFIG_DATA="" # Stores the config data from the config file as JSON format.
  export BASE_LAYER=""
  export INTERVAL=0.2 # 200 milliseconds
  export IP=127.0.0.1
  export PORT=10000

  # CONFIG WINDOW RULE
  declare -xi WIN_RULES_COUNT=0
  declare -x WIN_CLASSES=() # An array of window class patterns for matching.
  declare -x WIN_TITLES=()  # An array of window title patterns for matching.
  declare -x LAYER_NAMES=() # An array of layer names corresponding to the window rules.

  # COLOR
  readonly GREEN="\e[0;32m"
  readonly YELLOW="\e[0;33m"
  readonly RED="\e[0;31m"
  readonly BLUE="\e[0;34m"
  readonly NC="\e[0m" # No color
fi

################################################################################
###                            CORE FUNCTIONALITY                            ###
################################################################################

# Changes the current layer to the specified layer name by sending a JSON payload
# to a designated IP and port using netcat. If a valid recipes script is defined,
# it will be executed in the background.
change_layer() {
  [[ -z "${LAYER_NAME}" ]] && log -error "Layer name is empty." && exit 1

  # Construct the JSON payload and send it using netcat (nc)
  printf '{"ChangeLayer":{"new":"%s"}}\n' "$LAYER_NAME" |
    timeout 1 nc "$IP" "$PORT" >/dev/null 2>&1 &

  # Execute the user-defined recipes script if the RECIPES_SCRIPT is valid.
  if check_recipes_script; then
    $RECIPES_SCRIPT &
    opt_exists layer && log -warn "Recipes detected."
  fi

  return 0
}

################################################################################
###                             HELPER FUNCTIONS                             ###
################################################################################

log() {
  local level=$1
  local msg="$2"

  case "$level" in
  -error) echo -e "${RED}[ERROR]$NC $msg" >&2 ;;
  -info) [[ -n $QUIET_MODE ]] && return 0 || echo -e "${GREEN}[INFO]$NC $msg" ;;
  -warn) [[ -n $QUIET_MODE ]] && return 0 || echo -e "${YELLOW}[WARN]$NC $msg" >&2 ;;
  *) echo "$2" ;;
  esac
}

check_opt_value() {
  local opt="$1"
  local value="$2"

  if [[ -z "${value///}" ]]; then
    log -error "The value for the ${BLUE}-${opt}${NC} option cannot be empty."
    exit 1
  fi

  if [[ "$value" == -* ]]; then
    log -error "Invalid value ${RED}${value}${NC} for the ${BLUE}-${opt}${NC} option."
    exit 1
  fi
}

get_prop() {
  local json_data=$1
  local prop_path=$2
  local enable_trans=$3 # Flag to enable transformation

  if [[ -n $enable_trans ]]; then
    # If the value is null, false, true, or empty string it will be set to "*"
    local jq_condition='if . == null or . == false or . == "" or . == true then "*" else . end'

    jq -r ".${prop_path} | $jq_condition" <<<"$json_data"
  else
    jq -r ".${prop_path}" <<<"$json_data"
  fi
}

is_integer() { [[ $1 =~ ^[0-9]+$ ]] || return 1; }

opt_exists() {
  for opt in "${OPTIONS[@]}"; do [[ $opt == "$1"* ]] && return 0; done
  return 1
}

check_cmd() {
  local cmd=$1

  command -v "$cmd" >/dev/null 2>&1 && return 0
  log -error "${RED}'$cmd' is not installed.${NC}"
  log -info "Please install ${GREEN}${cmd}${NC} to proceed."
  return 1
}

check_tcp_port() {
  [[ -z "$PORT" ]] && {
    if opt_exists layer; then
      log -error "A port number must be specified."
      log -info "Use ${BLUE}-p ${YELLOW}<PORT${NC} or ${YELLOW}IP:PORT>${NC} to specify the port number."
    else
      log -error "Port value is empty."
      log -info "Please ensure to specify a value for ${BLUE}port${NC} in ${GREEN}${CONFIG_FILE}${NC}."
      log -info "Example configuration: ${BLUE}{ \"port\": 10000 }${NC}"
    fi
    return 1
  }

  is_integer "$PORT" || {
    log -error "The port number must be an integer." && return 1
  }

  ((PORT >= 0 && PORT <= 65535)) && return 0
  log -error "The port number must be an integer between ${YELLOW}0${NC} and ${YELLOW}65535${NC}."
  return 1
}

check_recipes_script() {
  opt_exists recipes && {
    if [[ -x $RECIPES_SCRIPT ]]; then
      return 0
    else
      log -error "The recipes script is not executable or does not exist: ${RED}${RECIPES_SCRIPT}${NC}"
      return 1
    fi
  }

  [[ -f $RECIPES_SCRIPT ]] || return 1

  if [[ -x $RECIPES_SCRIPT ]]; then
    return 0
  else
    log -error "The recipes script is not executable: ${RED}${RECIPES_SCRIPT}${NC}"
    return 1
  fi
}

################################################################################
###                               WINDOW RULES                               ###
################################################################################

# Outputs a JSON representation of the active window's class and title,
# including the matching window rule, or null if no match is found.
win::print_rule() {
  local -i rule_found=0

  win::set_win_rule && ((rule_found++))

  if [[ $rule_found -eq 1 ]]; then
    jq -n \
      --arg active_class "$ACTIVE_WIN_CLASS" \
      --arg active_title "$ACTIVE_WIN_TITLE" \
      --arg rule_class "$WIN_CLASS" \
      --arg rule_title "$WIN_TITLE" \
      --arg layer "$LAYER_NAME" \
      '{ active_window: { class: $active_class, title: $active_title },
    window_rule: {class: $rule_class, title: $rule_title, layer: $layer } }'
    return 0
  else
    jq -n \
      --arg class "$ACTIVE_WIN_CLASS" \
      --arg title "$ACTIVE_WIN_TITLE" \
      '{ active_window: { class: $class, title: $title }, window_rule: null }'
    return 1
  fi
}

# Updates the global variables related to the current active window's class, title,
# and associated layer name based on predefined window rules.
win::set_win_rule() {
  if ! opt_exists class && ! opt_exists title; then
    local prev_win_class=$ACTIVE_WIN_CLASS
    local prev_win_title=$ACTIVE_WIN_TITLE

    win::set_active_win_info

    # Check if the active window class and title have changed
    [[ $ACTIVE_WIN_CLASS == "$prev_win_class" ]] &&
      [[ $ACTIVE_WIN_TITLE == "$prev_win_title" ]] &&
      return 1
  fi

  for ((i = 0; i < WIN_RULES_COUNT; i++)); do
    if [[ ${WIN_CLASSES[i]} == "*" ]] ||
      [[ $ACTIVE_WIN_CLASS =~ ${WIN_CLASSES[i]} ]]; then

      if [[ ${WIN_TITLES[i]} == "*" ]] ||
        [[ $ACTIVE_WIN_TITLE =~ ${WIN_TITLES[i]} ]]; then

        WIN_CLASS="${WIN_CLASSES[i]}"
        WIN_TITLE="${WIN_TITLES[i]}"
        LAYER_NAME="${LAYER_NAMES[i]}"
        break
      fi
    fi
  done

  if [[ "$LAYER_NAME" == "false" ]] || [[ "$LAYER_NAME" == "null" ]]; then
    return 1
  elif [[ -z "${LAYER_NAME///}" ]]; then
    if ! opt_exists rule; then
      log -warn "Layer change failed: layer name value is empty."
      log -info "To disable layer changes in the active window, set the value to \
    \n${BLUE}false${NC} or ${BLUE}null${NC} in your window rule within the config file."
    fi
    return 1
  else
    return 0
  fi
}

# Set the class and title of the active window
win::set_active_win_info() {
  local win_info
  local no_active_win_msg="Failed to detect the active window information."

  case $XDG_SESSION_TYPE in
  x11)
    check_cmd xdotool || exit 1
    ACTIVE_WIN_CLASS=$(xdotool getactivewindow getwindowclassname)

    [[ -z $ACTIVE_WIN_CLASS ]] && log -warn "$no_active_win_msg" && return 1

    ACTIVE_WIN_TITLE=$(xdotool getactivewindow getwindowname)
    ;;
  wayland)
    if [[ $XDG_CURRENT_DESKTOP == "Hyprland" ]]; then
      check_cmd hyprctl || exit 1

      win_info=$(hyprctl -j activewindow)

      [[ -z $win_info ]] && log -warn "$no_active_win_msg" && return 1

      ACTIVE_WIN_CLASS="$(get_prop "$win_info" class)"
      ACTIVE_WIN_TITLE="$(get_prop "$win_info" title)"
    elif swaymsg >/dev/null 2>&1; then
      ACTIVE_WIN_TITLE=$(swaymsg -rt get_tree | jq -r '.. | objects | select(.focused == true) | .name')

      [[ -z $ACTIVE_WIN_TITLE ]] && log -warn "$no_active_win_msg" && return 1
    else
      log -error "$no_active_win_msg"
      log -info "Please consider reporting the issue on GitHub: ${BLUE}${PROJECT_REPO}/issues/new${NC}"
      exit 1
    fi
    ;;
  *) log -error "Unknown session type: ${RED}${XDG_SESSION_TYPE}${NC}" && exit 1 ;;
  esac
}

################################################################################
###                              CONFIGURATION                               ###
################################################################################
# Handles the user JSON configuration file.
# Ensure the configuration file is properly formatted.
# Example: config.json
################################################################################

config::set_tcp_ip() {
  opt_exists class || opt_exists title || opt_exists port && return 0

  local ip
  ip=$(echo "$CONFIG_DATA" | jq -r '.ip')

  if [[ -n "$ip" ]]; then
    readonly IP="$ip"
  else
    readonly IP # 127.0.0.1 (Default)
  fi
}

config::set_tcp_port() {
  opt_exists class || opt_exists title || opt_exists port && return 0

  local port
  ip=$(get_prop "$CONFIG_DATA" port)

  if [[ -n "$port" ]]; then
    readonly PORT="$port"
  else
    readonly PORT # 10000 (Default)
  fi

  check_tcp_port || exit 1
}

config::set_update_interval() {
  opt_exists class || opt_exists title && return 0

  local interval

  if opt_exists interval; then
    interval=$INTERVAL
  else
    interval=$(get_prop "$CONFIG_DATA" interval)

    if [[ -z "$interval" ]]; then
      readonly INTERVAL # INTERVAL=0.2 (Default)
      return 0
    fi
  fi

  if ! [[ $interval == "once" ]]; then
    if ! is_integer "$interval"; then
      log -error "${BLUE}Interval${NC} value must be an ${YELLOW}integer${NC} or '${YELLOW}once${NC}'."
      exit 1
    fi

    if [[ "$interval" -lt 50 ]]; then
      log -warn "Update interval ${YELLOW}${INTERVAL}${NC} is below ${GREEN}50ms${NC}, which may cause high CPU usage."
      log -info "Consider a higher interval; a range of ${GREEN}50${NC} to ${GREEN}200${NC} is recommended."
    elif [[ "$interval" -gt 200 ]]; then
      log -warn "Update interval ${YELLOW}${INTERVAL}${NC} exceeds ${GREEN}200ms${NC}, which may lead to reduced responsiveness."
      log -info "Consider lowering the interval; a range of ${GREEN}50${NC} to ${GREEN}200${NC} is recommended."
    fi

    # Convert interval from milliseconds to seconds
    INTERVAL=$(awk "BEGIN {printf \"%.2f\", $interval / 1000}")
  fi

  readonly INTERVAL
}

config::set_recipes_script() {
  local recipes_path
  recipes_path=$(get_prop "$CONFIG_DATA" recipes)

  if [[ -n "$recipes_path" ]]; then
    readonly RECIPES_SCRIPT="${recipes_path/#\~/$HOME}" # Expand the tilde
  else
    readonly RECIPES_SCRIPT # ~/.config/kanata/recipes.sh (Default)
  fi

  if [[ -f "$RECIPES_SCRIPT" ]]; then
    opt_exists rule || log -warn "Recipes detected."
  else
    log -info "No recipes found."
  fi
}

config::set_win_classes() {
  mapfile -t WIN_CLASSES < <(get_prop "$CONFIG_DATA" window_rules[].class enable_trans)
  readonly WIN_CLASSES
}

config::set_win_titles() {
  mapfile -t WIN_TITLES < <(get_prop "$CONFIG_DATA" window_rules[].title enable_trans)
  readonly WIN_TITLES
}

config::set_layer_names() {
  mapfile -t LAYER_NAMES < <(get_prop "$CONFIG_DATA" window_rules[].layer)

  for ((i = 0; i < WIN_RULES_COUNT; i++)); do
    if [[ "${LAYER_NAMES[i]}" == "true" ]]; then
      [[ -n $BASE_LAYER ]] && LAYER_NAMES[i]="$BASE_LAYER" || LAYER_NAMES[i]=""
    fi
  done

  readonly LAYER_NAMES
}

config::set_config_data() {
  [[ -s "$CONFIG_FILE" ]] || {
    log -error "${RED}${CONFIG_FILE}${NC} is empty." && exit 1
  }

  if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
    log -error "The config file contains invalid JSON: ${RED}${CONFIG_FILE}${NC}"
    log -info "Please check the file for syntax errors or formatting issues."
    exit 1
  fi

  CONFIG_DATA=$(cat "$CONFIG_FILE")
  readonly CONFIG_DATA
}

config::set_win_rules_count() {
  WIN_RULES_COUNT=$(jq ".window_rules | length" <<<"$CONFIG_DATA")
  readonly WIN_RULES_COUNT

  if [[ $WIN_RULES_COUNT -eq 0 ]]; then
    log -error "No window rules found in ${RED}$CONFIG_FILE${NC}."
    exit 1
  fi
}

config::set_base_layer() {
  BASE_LAYER=$(get_prop "$CONFIG_DATA" base_layer)
  readonly BASE_LAYER
}

config::load_config() {
  [[ -f "$CONFIG_FILE" ]] || {
    if opt_exists config; then
      log -error "${RED}${CONFIG_FILE}${NC} file doesn't exist." && return 1
    else
      log -error "A config file must be specified."
      log -info "Use ${BLUE}-c ${YELLOW}<config_file>${NC} to specify the config file."
      return 1
    fi
  }

  config::set_config_data # IMPORTANT: This should be called first

  # Call functions with assigned numbers first, in order of their numbers.
  # Functions without assigned numbers can run in any order.
  config::set_win_rules_count #1
  config::set_tcp_ip          #
  config::set_tcp_port        #
  config::set_update_interval #
  config::set_win_classes     #
  config::set_win_titles      #
  config::set_base_layer      #1
  config::set_layer_names     #2
  config::set_recipes_script  #
}

################################################################################
###                                USER GUIDE                                ###
################################################################################
# Provides help and usage information for the script.
# Use the -h or --help option to display this information.
# Example: nata --help
################################################################################

print_options() {
  local script_name
  local green="\e[1;32m" # Bold green color

  if [[ ${BASH_SOURCE[0]} =~ ^/home/$(whoami)/.local/bin/ ]]; then
    script_name="${0##*/}"
  else
    script_name=${BASH_SOURCE[0]}
  fi

  cat <<EOF
${green}Usage:${NC} $script_name ${BLUE}[options]${NC}

  Nata is an application-aware switching layer for Kanata.

  For comprehensive documentation for Nata, please see:
  ${GREEN}https://github.com/mdSlash/nata/blob/main/docs/script_options.md${NC}

${green}OPTIONS:${NC}

  ${BLUE}-h, --help${NC}
    Display the help message and exit.

  ${BLUE}-v, --version${NC}
    Show the script version and exit.

  ${BLUE}-q, --quiet${NC}
    Run in quiet mode; logs errors only, without logging informational messages or warnings.

  ${BLUE}-R, --rule${NC}
    Displays detailed information about the active window and the matching rule.

    See: ${GREEN}https://github.com/mdSlash/nata/blob/main/docs/config.md#window_rules${NC}

  ${BLUE}-i, --interval${NC} <${YELLOW}N${NC} or ${YELLOW}once${NC}>
    Set the update interval for checking the active window and changing the layer.
    ${GREEN}(Default) ${YELLOW}200${NC}

    Use ${YELLOW}once${NC} to perform a single check and exit immediately.

  ${BLUE}-p, --port${NC} <${YELLOW}PORT${NC} or ${YELLOW}IP:PORT${NC}>
    Specify a TCP port or an IP address with a port.
    ${GREEN}(Default) ${YELLOW}127.0.0.1:10000${NC}

  ${BLUE}-C, --class${NC} <${YELLOW}WINDOW_CLASS${NC}>
    Change to the layer and exit if the specified value matches the rule:
    ${YELLOW}{ "class": "<VALUE>", "title": "*" }${NC}

  ${BLUE}-t, --title${NC} <${YELLOW}WINDOW_TITLE${NC}>
    Change to the layer and exit if the specified value matches the rule:
    ${YELLOW}{ "class": "*", "title": " <VALUE>" }${NC}

  ${BLUE}-l, --layer${NC} <${YELLOW}LAYER_NAME${NC}>
    Specify a layer name to switch to that layer and exit.

  ${BLUE}-c, --config${NC} <${YELLOW}CONFIG_FILE${NC}>
    Specify the path to the config file.
    ${GREEN}(Default) ${YELLOW}~/.config/kanata/config.json${NC}

    See: ${GREEN}https://github.com/mdSlash/nata/blob/main/docs/config.md${NC}

  ${BLUE}-r, --recipes${NC} <${YELLOW}SCRIPT_PATH${NC}>
    Specify the path to a script that will run in the background whenever the layer changes.
    ${GREEN}(Default) ${YELLOW}~/.config/kanata/recipes.sh${NC}

    See: ${GREEN}https://github.com/mdSlash/nata/blob/main/docs/recipes.md${NC}
EOF
}

################################################################################
####                              MAIN FUNCTION                              ###
################################################################################

main() {
  # Parse options
  while [[ $# -gt 0 ]]; do
    local opt="$1"
    local value="$2" # Option value (if specified)

    if [[ $opt == "-"* ]]; then

      opt="${opt#"${opt%%[!-]*}"}" # Remove all leading dashes

      case "$opt" in
      c | config)
        check_opt_value "$opt" "$value"
        OPTIONS+=("config $value")
        readonly CONFIG_FILE=$value
        ;;
      C | class)
        check_opt_value "$opt" "$value"
        OPTIONS+=("class $value")
        readonly ACTIVE_WIN_CLASS=$value
        ;;
      t | title)
        check_opt_value "$opt" "$value"
        OPTIONS+=("title $value")
        readonly ACTIVE_WIN_TITLE=$value
        ;;
      l | layer)
        check_opt_value "$opt" "$value"
        OPTIONS+=("layer $value")
        LAYER_NAME=$value
        ;;
      i | interval)
        check_opt_value "$opt" "$value"
        OPTIONS+=("interval $value")
        INTERVAL=$value
        ;;
      p | port)
        check_opt_value "$opt" "$value"
        OPTIONS+=("port $value")
        if [[ "$value" == *:* ]]; then
          readonly IP="${value%%:*}"  # Get the part before the first colon
          readonly PORT="${value#*:}" # Get the part after the first colon
        else
          readonly IP # 127.0.0.1 (Default)
          readonly PORT=$value
        fi
        check_tcp_port || exit 1
        ;;
      r | recipes)
        check_opt_value "$opt" "$value"
        OPTIONS+=("recipes $value")
        RECIPES_SCRIPT="$value"
        check_recipes_script || exit 1
        RECIPES_SCRIPT=$(realpath "$value")
        readonly RECIPES_SCRIPT
        ;;
      R | rule) OPTIONS+=("rule") ;;
      q | quiet) QUIET_MODE=1 ;;
      v | version) echo -e "${PROJECT_NAME} ${GREEN}${SCRIPT_VERSION}${NC}" && exit 0 ;;
      h | help) echo -e "$(print_options)" && exit 0 ;;
      *)
        log -error "Invalid option ${RED}${opt}${NC}"
        log -info "use ${BLUE}-h${NC} for help." && exit 1
        ;;
      esac
    fi
    shift
  done

  check_cmd nc || exit 1

  ###########################################
  ###   If the layer option is provided   ###
  ###########################################

  if opt_exists layer; then
    # Change the layer and exit if the --layer is provided.
    opt_exists layer && change_layer

    opt_exists interval &&
      log -warn "The update interval does not take effect when the ${BLUE}layer${NC} option is used."

    exit 0
  fi

  ###########################################
  ### If the layer option is not provided ###
  ###########################################

  check_cmd jq || exit 1

  # If the --layer is not provided, load and validate
  # the user config file before executing other processes.
  config::load_config || exit 1

  if opt_exists rule; then
    win::print_rule && exit 0 || exit 1

  # Change the layer and exit if --class or --title are provided.
  elif opt_exists class || opt_exists title; then

    if win::set_win_rule; then
      [[ -n "$DRY_RUN" ]] && echo "$WIN_CLASS, $WIN_TITLE, $LAYER_NAME" && exit 0
      change_layer && exit 0
    else
      [[ -n "$DRY_RUN" ]] && echo "$WIN_CLASS, $WIN_TITLE, $LAYER_NAME"
      exit 1
    fi

  # If neither the --class nor --title are provided, attempt to
  # retrieve them from the active window and continue running the script.
  else
    while true; do
      win::set_win_rule && change_layer # Change the layer if necessary.
      [[ $INTERVAL == "once" ]] && exit 0
      sleep "$INTERVAL" # Pause to reduce CPU usage.
    done
  fi
}

main "$@"
