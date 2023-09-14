<div align="center">

<img src="docs/images/qformat.svg" height="350px"/>

<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT" /></a>
<a href="https://www.contributor-covenant.org/version/2/0/code_of_conduct/"><img src="https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg" alt="Contributor Covenant" /></a>

</div>

The **qformat** [Quarto](https://quarto.org) shortcode extension allows you to easily format values to HTML- and LaTeX-based output formats.

## How to Use

Within the `{{< ` / ` >}}`, this shortcode always begins with the `qformat` command; next, you'd add a subcommand to specify the type of formatting to be done. You can, for instance, format numbers to contain decimals and grouping separators with `{{< qformat num <value> ... >}}`.

Aside from `num`, the other subcommands are `int` (for integer formatting), `sci` (formatting to scientific notation), and `auto` (allows **qformat** latitude to format the value with less user guidance). Not including a subcommand (i.e., using `{{< qformat <value> ... >}}`) is shorthand for using the `auto` subcommand.

The `...` is for named arguments that are used by some types of formatting but ignored by others should they be irrelevant. Let's now go through each of the formatting types.

### Numeric formatting (`num`)

Numeric formatting takes the form `{{< qformat num <value> ... >}}`. By default, the number `369234.263` becomes `369,234.26` with the default numeric formatting. Here are the named arguments and their defaults:

- `decimals` (default: `2`) / The number of decimal places to use
- `use_seps` (default: `true`) / Should digit-grouping separators be used?
- `dec_mark` (default: `"."`) / The character(s) used to signify the decimal mark
- `sep_mark` (default: `"."`) / The character(s) used to signify the separator mark

Here are some examples:

`{{< qformat num 369234.263 >}}` -> 369,234.26

`{{< qformat num 369234.263 decimals=4 >}}` -> 369,234.2630

`{{< qformat num 369234.263 decimals=0 >}}` -> 369,234

`{{< qformat num 369234.263 use_seps=false >}}` -> 369234.26

`{{< qformat num 369234.263 dec_mark=',' sep_mark='.' >}}` -> 369.234,26

### Integer formatting (`int`)

Integer formatting of the form `{{< qformat num <value> ... >}}` is similar to numeric formatting, though the `decimals` and `dec_mark` arguments are disregarded. The value will be rounded before undergoing formatting. Here are a few examples:

`{{< qformat int 733744.653 >}}` -> 733,745

`{{< qformat int 733744.653 use_seps=no >}}` -> 733745

`{{< qformat int 733744.653 sep_mark=space >}}` -> 733 745

Some notes are in order. You can use either `"true"`/`"yes"` or `"false"`/`"no"` for those arguments looking for a boolean value. The `sep_mark` argument can take the special keyword `"space"` to mean that you want a single space character for the digit-grouping separator.

### Scientific notation (`sci`)

You can transform numbers to scientific notation by using the form `{{< qformat sci <value> ... >}}`. This type of formatting allows the use of the `decimals` and `dec_mark` arguments (any other named arguments, if provided, will be disregarded). Here are four examples:

`{{< qformat sci 13463733744.653 >}}` -> 1.35 × 10<sup style="font-size: 65%;">10</sup>

`{{< qformat sci 0.00000000000392752 >}}` -> 3.93 × 10<sup style="font-size: 65%;">-12</sup>

`{{< qformat sci 6.343 >}}` -> 6.34

`{{< qformat sci 623846 dec_mark="," >}}` -> 6,24 × 10<sup style="font-size: 65%;">5</sup>

## Installation

```sh
quarto add rich-iannone/qformat
```

This will install the **qformat** extension within the `_extensions` directory (you should see `_extensions/qformat`). Using version control? Check in this directory.

If you encounter a bug, have usage questions, or want to share ideas to make this package better, feel free to file an [issue](https://github.com/rich-iannone/qformat/issues).

## Code of Conduct

Please note that the **qformat** project is released with a [contributor code of conduct](https://www.contributor-covenant.org/version/2/0/code_of_conduct/).
<br>By participating in this project you agree to abide by its terms.

## 📄 License

**qformat** is licensed under the MIT license.
See the [`LICENSE.md`](LICENSE.md) file for more details.

## 🏛️ Governance

This project is primarily maintained by [Rich Iannone](https://twitter.com/riannone).