# qformat

The **qformat** Quarto shortcode extension allows you to easily format values to HTML- and LaTeX-based output formats.

## Installation

```sh
quarto add rich-iannone/qformat
```

This will install the **qformat** extension within the `_extensions` directory (you should see `_extensions/qformat`). Using version control? Check in this directory.

## How to Use

Within the `{{< ` / ` >}}`, this shortcode always begins with the `qformat` command and there are also subcommands to specify the type of formatting to be done. You can format numbers to contain decimals and grouping separators with `{{< qformat num <value> ... >}}`, for instance. Aside from `num`, the other subcommands are `int` (for integer formatting), `sci` (formatting to scientific notation), and `auto` (allows **qformat** latitude to format the value with less user guidance). Not including a subcommand (i.e., using `{{< qformat <value> ... >}}`) is shorthand for using the `auto` subcommand. The `...` is for named arguments that are used by some types of formatting but ignored by others should they be irrelevant.

