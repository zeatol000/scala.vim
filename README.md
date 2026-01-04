# scala.vim
A custom Scala syntax highlighting for Vim/NeoVim.

---
### Differences from the base syntax
- Updated for Scala 3 keywords `enum, given, derives, end, then, etc`
- Dim unimportant characters `. , ; = : !`
- Color wildcards differently `_ * ?`
- Words that start with an underscore, or are capitalized and contain an underscore are highlighted a different color
- Highlight some built-in functions `println, print, printf, assert, breakable, break, to, until`
- Highlight `IO` and `ZIO` effect monads

---
### Installation
1. Go to your user's Vim syntax directory
   - Vim is in ~/.vim/syntax/
   - Neovim is in ~/.config/nvim/syntax/
2. Copy the repository's `scala.vim` file to a corresponding `scala.vim` file in the syntax directory
3. Done!
