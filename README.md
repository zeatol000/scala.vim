# scala.vim
A custom Scala syntax highlighting for Vim/NeoVim.

---
## Installation
Either use the installation script and pass "-nvim" or "-vim" depending on which
to use, or follow these steps:
1. Go to your user's Vim syntax directory
   - Vim is in ~/.vim/syntax/
   - Neovim is in ~/.config/nvim/syntax/
2. Copy the repository's `scala.vim` file to a corresponding `scala.vim` file in your syntax directory
3. Done!


## Features
- Scala 3 Keyword like `enum` `given` `derives` `end` `then` `opaque`
- Dim unimportant characters `. , ; : ! @ # % ^ - + = / \ < > ( ) { }`
- Color widcards differently `_ * ?`
- Highlight CAPITALIZED_AND_UNDERSCORED identifiers
- Color built-in functions `print printf println assert to until break breakable`
- Dim `into` when used as a type parameter
- Other Scala 3 features
