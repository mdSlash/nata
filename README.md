# Nata

**Nata** is an application-aware switching layer for [Kanata](https://github.com/jtroo/kanata) on Linux.

> [!IMPORTANT]
> Please be aware that **Nata** is currently in its beta version. As such, it may contain bugs that have not yet been identified or resolved.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Options](#options)
- [Recipes](#recipes)
- [Contributing](#contributing)

## Installation

### Download the Script and Make It Executable

1. **Manual Download**: Download the **Nata** [script](/nata) and make it executable:

   ```bash
   chmod +x nata
   ```

2. **Using `curl` to download the script and make it executable in a single Line**:

   ```bash
   curl -O https://raw.githubusercontent.com/mdSlash/nata/refs/heads/main/nata && chmod +x nata
   ```

### Dependencies

To run **Nata** script, you will need the following dependencies installed on your system:

- **nc**: A utility to send data to the **Kanata** server via TCP to change the layer.
- **[jq](https://jqlang.github.io/jq/)**: A command-line JSON processor for managing data from the [config](#Configuration) file.

#### Additional Requirements for Active Window Information

To retrieve active window information such as window class and title, you will need one of the following tools based on your display server:

#### For X11 Users:

- [xdotool](https://github.com/jordansissel/xdotool)

#### For Wayland Users:

These tools are typically installed by default if you are using:

- **Hyprland**: [hyprctl](https://wiki.hyprland.org/Configuring/Using-hyprctl/)
- **Sway**: [swaymsg](https://github.com/swaywm/sway/blob/master/swaymsg/swaymsg.1.scd)

## Usage

To use **Nata** script:

1. Configure your [configuration](#config) file.
2. Execute the script with the desired [options](#options) if necessary.

## Configuration

| Property                            | Description                                                                   |
| ----------------------------------- | ----------------------------------------------------------------------------- |
| [`ip`][prop_ip]                     | IP address                                                                    |
| [`port`][prop_port]                 | Port number                                                                   |
| [`interval`][prop_interval]         | Interval (in ms) for checking active window rules and changing layers.        |
| [`base_layer`][prop_base_layer]     | Base layer for window rules.                                                  |
| [`recipes`][prop_recipes]           | Location of the recipe script.                                                |
| [`window_rules`][prop_window_rules] | If the active window matches the rule, it will change to the specified layer. |

See the [config](/docs/config.md) doc for more details.

## Options

| Option                             | Description                                                                                                               |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| [`-h`, `--help`][opt_help]         | Display help message and exit.                                                                                            |
| [`-v`, `--version`][opt_version]   | Show script version and exit.                                                                                             |
| [`-q`, `--quiet`][opt_quiet]       | Run quietly; log errors only.                                                                                             |
| [`-i`, `--interval`][opt_interval] | Set update interval for checking the active window.                                                                       |
| [`-p`, `--port`][opt_port]         | Specify a TCP port or IP address with a port.                                                                             |
| [`-C`, `--class`][opt_class]       | Change layer if the argument matches the rule: `{ "class": "<VALUE>", "title": "*" }`.                                    |
| [`-t`, `--title`][opt_title]       | Change layer if the argument matches the rule: `{ "class": "*", "title": "<VALUE>" }`.                                    |
| [`-l`, `--layer`][opt_layer]       | Specify a layer name to switch to.                                                                                        |
| [`-c`, `--config`][opt_config]     | Path to the [config](#config) file in JSON format.                                                                        |
| [`-r`, `--recipes`][opt_recipes]   | Path to a script that runs in the [background](https://www.gnu.org/software/bash/manual/bash.html#Lists) on layer change. |

See the [options](/docs/script-options.md) doc for more details.

### Recipes

See the [Recipes](/docs/recipes.md) doc for more details.

## Contributing

We welcome contributions! If you find bugs or have suggestions for improvements, please open an [issue](https://github.com/mdSlash/nata/issues/new) or submit a pull request.

<!-- CONFIG PROPERTIES -->

[prop_ip]: /docs/config.md#ip
[prop_port]: /docs/config.md#port
[prop_interval]: /docs/config.md#interval
[prop_base_layer]: /docs/config.md#base_layer
[prop_recipes]: /docs/config.md#recipes
[prop_window_rules]: /docs/config.md#window_rules

<!-- OPTIONS -->

[opt_help]: /docs/script_options.md#-h---help
[opt_version]: /docs/script_options.md#-v---version
[opt_quiet]: /docs/script_options.md#-q---quiet
[opt_interval]: /docs/script_options.md#-i---interval
[opt_port]: /docs/script_options.md#-p---port
[opt_class]: /docs/script_options.md#-c---class
[opt_title]: /docs/script_options.md#-t---title
[opt_layer]: /docs/script_options.md#-l---layer
[opt_config]: /docs/script_options.md#-c---config
[opt_recipes]: /docs/script_options.md#-r---recipes
