# Configuration

This document lists all available options you can use in your configuration file, which should be in [JSON](https://en.wikipedia.org/wiki/JSON) format.

To see a sample configuration file, see: [`config.json`](../examples/config.json)

## Table of Contents

- [`ip`](#ip)
- [`port`](#port)
- [`interval`](#interval)
- [`base_layer`](#base_layer)
- [`recipes`](#recipes)
- [`window_rules`](#window_rules)
- [Rule Priority](#rule-priority)

## `ip`

```json
{ "ip": "127.0.0.1" }
```

Specifies the IP address used in the configuration. Replace `"127.0.0.1"` with your desired IP address.

## `port`

```json
{ "port": 10000 }
```

Specifies the port number. Change the value `10000` to the port you wish to use.

> [!IMPORTANT]
> Ensure that the specified `ip` and `port` match those used by **Kanata** to avoid connection issues. For example:
>
> ```bash
> kanata -p 127.0.0.1:10000
> ```

## `interval`

```json
{ "interval": 200 }
```

Sets the interval (in milliseconds) for checking the active window rule and changing the layer if it matches.

## `base_layer`

```json
{ "base_layer": "BaseLayer" }
```

Defines the base layer for window rules. Replace `"BaseLayer"` with the desired base layer name.

You can use this in the `layer` key to avoid repeating the base layer name in each [rule](#window_rules). For example:

```json
{ "layer": true }
```

## `recipes`

```json
{ "recipes": "~/.config/kanata/recipes.sh" }
```

Specifies the location of the recipe script. This file contains additional configuration or scripts to run. Replace the value with the path to your script file.

You can also use [Nata environment variables](../docs/env_vars.md) inside your [recipes](../docs/recipes.md) script.

## `window_rules`

```json
{
  "window_rules": [
    { "class": "", "title": "", "layer": "" },
    { "class": "", "title": "", "layer": "" }
  ]
}
```

Each window rule consists of three keys:

- `class`: Matches the class of the window.
- `title`: Matches the title of the window.
- [`layer`](#layer): Determines the layer to switch to.

> [!NOTE]
> **Nata** does not currently support classes with the [Sway](https://swaywm.org) window manager. Therefore, you can either omit the `class` key or set it to [`*` wildcard](#-wildcard) to match any class.

### Regex Patterns

[Regex](https://en.wikipedia.org/wiki/Regular_expression) patterns can be used to match specific window classes or titles:

- `^Neovim$`: Matches only `Neovim`.
- `^code`: Matches any window whose class or title starts with `code`.

> [!NOTE]
> If no regex patterns are specified, it will match any string. For example, `Firefox` matches `Mozilla Firefox - Home`, `Firefox Developer Edition`, etc.

#### `\\` Regex Escaping

Double backslashes (`\\`) before characters like `^` or `[` disable regex functionality, treating them as literal characters. For example:

```json
{ "class": "", "title": "nvim - \\[Scratch]", "layer": "" }
```

In this case, `nvim - \\[Scratch]` matches `nvim - [Scratch]` literally, where `[` and `]` are treated as normal characters instead of regex character sets.

### `*` Wildcard

`*` acts as a wildcard to match any window class or title.

```jsonc
// Matches the "Code - OSS" title, regardless of the class, and switches to the "vs_code" layer
{ "class": "*", "title": "Code - OSS", "layer": "vs_code" },

// Matches the "Vivaldi" class with any title but does nothing since the layer is null
{ "class": "Vivaldi", "title": "*", "layer": null },
```

This rule matches any window based on either its title or class.

#### Fallback Rule

The `*` wildcard also serves as a fallback rule, applying to any window (regardless of class or title):

```json
{ "class": "*", "title": "*", "layer": "base" }
```

It can be useful if no other window rule matches the active window. You can set `layer` to `true` to switch to the [base layer](#base_layer), or to `false` or `null` to do nothing.

#### `layer`

`layer` can take the following values:

- `str`: The rule will match and switch to the specified layer.
- `true`: The rule will switch to the base layer if a [`base_layer`](#base_layer) is specified.
- `false`, `null`, or an empty value: No action will be taken if the rule is matched.

## Rule Priority

The priority of window rules is determined by their order in the [`config.json`](..//examples/config.json#L7). When multiple rules apply to the same window, the first matching rule in the list will be the one that takes effect. This means more specific rules should appear before general ones. Here’s how the rules are processed based on the order:

1. **Most Specific First**: The first rule that matches the window will be applied.
2. **Wildcard and Fallback Last**: Wildcard (`*`) rules or fallback rules should be placed at the end to ensure they don't override more specific matches.

Here’s an example of rule prioritization:

```jsonc
"window_rules": [
  // Matches "Ferdium" with the title "ChatGPT" and switches to the "ai_mode" layer
  { "class": "Ferdium", "title": "ChatGPT", "layer": "ai_mode" },

  // Matches the "Code - OSS" title, regardless of the class, and switches to the "vs_code" layer
  { "class": "*", "title": "Code - OSS", "layer": "vs_code" },

  // Matches the "Vivaldi" class with any title but does nothing since the layer is null
  { "class": "Vivaldi", "title": "*", "layer": null },

  // Matches the exact "nvim" class with the title "nvim - [Scratch]" and switches to the "vim_dashboard" layer
  {
    "class": "^nvim$",
    "title": "nvim - \\[Scratch]",
    "layer": "vim_dashboard"
  },

  // Fallback rule: matches any window (with any class or title) and switches to the base layer if no other match
  { "class": "*", "title": "*", "layer": true }
]
```

See [config.json](../examples/config.json) for a sample configuration file.

> [!NOTE]
> To view detailed information about the active window and the matching rules, use the [`-R`, `--rule`](../docs/script_options.md#-r---rule) option.

---

If you find something unclear or have suggestions for improvements, we welcome your contributions! Please feel free to report any bugs or issues you encounter.
