# scala.vim
A custom Scala syntax highlighting for Vim/NeoVim.

---
### Differences from the base syntax
- Updated for Scala 3 keywords `enum, given, derives, end, then, etc`
- Dim unimportant characters `. , ; = : !`
- Color wildcards differently `_ * ?`
- Words that start with an underscore, or are capitalized and contain an underscore are highlighted a different color
- Highlight some built-in functions `println, print, printf, assert, to, until`
- Highlight certain keywords based on imports:
  - cats.effect -> IO
  - scala.util.control.Breaks -> breakable, break
  - zio -> ZIO

---
### Installation
1. Go to your user's Vim syntax directory
   - Vim is in ~/.vim/syntax/
   - Neovim is in ~/.config/nvim/syntax/
2. Copy the repository's `scala.vim` file to a corresponding `scala.vim` file in your syntax directory
3. Done!
