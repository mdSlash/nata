# Recipes

You can create a custom script (recipes script), to execute when switching layers.

> [!NOTE]
> The script executes in the background, ensuring it does not delay layer switching

The default path for the recipes script is `~/.config/kanata/recipes.sh`. You can modify this path using the [`-r`, `--recipes`](/docs/script_options.md#-r---recipes) option, or by setting the [`recipes`](/docs/config.md#recipes) property in your configuration file.

> [!IMPORTANT]
> Ensure the recipes script is executable by running `chmod +x <path-to-your-recipes-script>`.

For example, if you want to send a notification every time the layer changes, you can add the following recipe to your recipes script:

```bash
# Send a notification with the layer name
notify-send -r 12345 "Current Layer" "Layer Name: $LAYER_NAME"
```

In this example, `$LAYER_NAME` is an [environment variables](/docs/env_vars.md) provided to the recipes script.

---

If you find something unclear or have suggestions for improvements, we welcome your contributions! Please feel free to report any bugs or issues you encounter.
