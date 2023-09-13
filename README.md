<div align="center">

<!-- badges: start -->
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT" /></a>
<a href="https://www.contributor-covenant.org/version/2/0/code_of_conduct/"><img src="https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg" alt="Contributor Covenant" /></a>
<!-- badges: end -->
<br />
</div>

# qformat

The **qformat** Quarto shortcode extension allows you to easily format values to HTML- and LaTeX-based output formats.

## How to Use

Within the `{{< ` / ` >}}`, this shortcode always begins with the `qformat` command and there are also subcommands to specify the type of formatting to be done. You can format numbers to contain decimals and grouping separators with `{{< qformat num <value> ... >}}`, for instance.

Aside from `num`, the other subcommands are `int` (for integer formatting), `sci` (formatting to scientific notation), and `auto` (allows **qformat** latitude to format the value with less user guidance). Not including a subcommand (i.e., using `{{< qformat <value> ... >}}`) is shorthand for using the `auto` subcommand.

The `...` is for named arguments that are used by some types of formatting but ignored by others should they be irrelevant.

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