# Nata Script Options

This document lists all [Nata script](../nata) options in detail.

## Table of Contents

- [`-h`, `--help`](#-h---help)
- [`-v`, `--version`](#-v---version)
- [`-q`, `--quiet`](#-q---quiet)
- [`-R`, `--rule`](#-r---rule)
- [`-i`, `--interval`](#-i---interval)
- [`-p`, `--port`](#-p---port)
- [`-C`, `--class`](#-c---class)
- [`-t`, `--title`](#-t---title)
- [`-l`, `--layer`](#-l---layer)
- [`-c`, `--config`](#-c---config)
- [`-r`, `--recipes`](#-r---recipes)

---

### `-h`, `--help`

|          |                                    |
| -------- | ---------------------------------- |
| **DESC** | Display the help message and exit. |

---

### `-v`, `--version`

|          |                                   |
| -------- | --------------------------------- |
| **DESC** | Show the script version and exit. |

---

### `-q`, `--quiet`

|          |                                                                                          |
| -------- | ---------------------------------------------------------------------------------------- |
| **DESC** | Run in quiet mode; logs errors only, without logging informational messages or warnings. |

---

### `-R`, `--rule`

|          |                                                                              |
| -------- | ---------------------------------------------------------------------------- |
| **DESC** | Displays detailed information about the active window and the matching rule. |

This option can be useful for testing whether the active window matches any rules defined in your configuration.

---


### `-i`, `--interval`

|          |                                                                                |
| -------- | ------------------------------------------------------------------------------ |
| **DESC** | Set the update interval for checking the active window and changing the layer. |
| **ARG**  | `N` (in milliseconds)                                                          |
| **Def**  | `200`                                                                          |

> [!NOTE]
> If the [interval](https://github.com/mdSlash/nata/blob/main/docs/config.md#interval) is specified in the configuration file as well, the interval option will override it.

> [!Warning]
> The recommended range for the update interval is `50` to `200` milliseconds. Using value below `50` milliseconds will increase CPU usage.

---

### `-p`, `--port`

|          |                                                  |
| -------- | ------------------------------------------------ |
| **DESC** | Specify a TCP port or an IP address with a port. |
| **ARG**  | `PORT` or `IP:PORT`                              |
| **Def**  | `127.0.0.1:10000`                                |

> [!IMPORTANT]
> Ensure that the specified IP and port match those used by **Kanata** to avoid connection issues. For example:
>
> ```bash
> kanata -p 127.0.0.1:10000
> ```

---

### `-C`, `--class`

|          |                                                                                                                  |
| -------- | ---------------------------------------------------------------------------------------------------------------- |
| **DESC** | Change to the layer and exit if the specified argument matches the rule: `{ "class": "<VALUE>", "title": "*" }`. |
| **ARG**  | `WINDOW_CLASS`                                                                                                   |

For more information about rules, see the [window rules](https://github.com/mdSlash/nata/blob/main/docs/config.md#window_rules) doc.

---

### `-t`, `--title`

|          |                                                                                                                  |
| -------- | ---------------------------------------------------------------------------------------------------------------- |
| **DESC** | Change to the layer and exit if the specified argument matches the rule: `{ "class": "*", "title": "<VALUE>" }`. |
| **ARG**  | `WINDOW_TITLE`                                                                                                   |

For more information about rules, see the [window rules](https://github.com/mdSlash/nata/blob/main/docs/config.md#window_rules) doc.

---

### `-l`, `--layer`

|          |                                                        |
| -------- | ------------------------------------------------------ |
| **DESC** | Specify a layer name to switch to that layer and exit. |
| **ARG**  | `LAYER_NAME`                                           |

---

### `-c`, `--config`

|          |                                                     |
| -------- | --------------------------------------------------- |
| **DESC** | Specify the path to the config file in JSON format. |
| **ARG**  | `CONFIG_FILE`                                       |
| **DEF**  | `~/.config/kanata/config.json`                      |

For more information and examples, see the [config](https://github.com/mdSlash/nata/blob/main/docs/config.md) doc.

---

### `-r`, `--recipes`

|          |                                                                                                                                                      |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| **DESC** | Specify the path to a script that will run in the [background](https://www.gnu.org/software/bash/manual/bash.html#Lists) whenever the layer changes. |
| **ARG**  | `SCRIPT_PATH`                                                                                                                                        |
| **DEF**  | `~/.config/kanata/recipes.sh`                                                                                                                        |

For more information and examples, see the [recipes](https://github.com/mdSlash/nata/blob/main/docs/recipes.md) doc.

---

If you find something unclear or have suggestions for improvements, we welcome your contributions! Please feel free to report any bugs or issues you encounter.
