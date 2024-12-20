# Script Environment Variables

This document outlines the environment variables used in the script, detailing their purpose and data types. You can use these variables within your [recipes](/docs/recipes.md) script.

## Table of Contents

- [Environment Variables](#environment-variables)
- [Accessing Environment Variables](#accessing-environment-variables)

## Environment Variables

### Window Matching Rule

| Variable Name      | Type   | Description                                    |
| ------------------ | ------ | ---------------------------------------------- |
| `ACTIVE_WIN_CLASS` | String | Class of the currently active window.          |
| `ACTIVE_WIN_TITLE` | String | Title of the currently active window.          |
| `LAYER_NAME`       | String | Name of the layer for the matched window rule. |

### Config

| Variable Name    | Type    | Description                                                     |
| ---------------- | ------- | --------------------------------------------------------------- |
| `CONFIG_FILE`    | String  | Path to the configuration file.                                 |
| `RECIPES_SCRIPT` | String  | Path to the recipes script.                                     |
| `CONFIG_DATA`    | String  | Configuration data from the config file, stored in JSON format. |
| `BASE_LAYER`     | String  | Base layer name.                                                |
| `INTERVAL`       | Number  | Time interval in seconds.                                       |
| `IP`             | String  | IP address.                                                     |
| `PORT`           | Integer | Port number.                                                    |

### Config Window Rules

| Variable Name     | Type    | Description                                        |
| ----------------- | ------- | -------------------------------------------------- |
| `WIN_RULES_COUNT` | Integer | Number of window rules defined in the config file. |
| `WIN_CLASSES`     | Array   | List of window classes from the config file.       |
| `WIN_TITLES`      | Array   | List of window titles from the config file.        |
| `LAYER_NAMES`     | Array   | List of layer names from the config file.          |

## Accessing Environment Variables

To access an environment variable in your [recipes](/docs/recipes.md) script, use the `$` prefix followed by the variable name:

```bash
echo "Active window title: $ACTIVE_WIN_TITLE"
```

---

If you find something unclear or have suggestions for improvements, we welcome your contributions! Please feel free to report any bugs or issues you encounter.
