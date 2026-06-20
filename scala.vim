" ---------------------------- HEADER ----------------------------------------
syn clear

if !exists('main_syntax')
  " quit when a syntax file was already loaded
  if exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'scala'
endif

scriptencoding utf-8

let b:current_syntax = "scala"

" Allows for embedding, see #59; main_syntax convention instead? Refactor TOP
"
" The @Spell here is a weird hack, it means *exclude* if the first group is
" TOP. Otherwise we get spelling errors highlighted on code elements that
" match scalaBlock, even with `syn spell notoplevel`.
function! s:ContainedGroup()
  try
    silent syn list @scala
    return '@scala,@NoSpell'
  catch /E392/
    return 'TOP,@Spell'
  endtry
endfunction

unlet! b:current_syntax

syn case match
syn sync minlines=200 maxlines=1000

" ---------------------------- MAIN SYNTAX -------------------------------

" main keywords found in the token file of the Scala 3 compiler
syn keyword scalaKeyword catch do else final finally for forSome if match
			\ throw try while yield then as
syn keyword scalaKeyword class trait object extends derives with enum		nextgroup=scalaInstanceDeclaration skipwhite
syn keyword scalaKeyword case						   	nextgroup=scalaKeyword,scalaCaseFollowing skipwhite
syn keyword scalaKeyword val						    	nextgroup=scalaNameDefinition,scalaQuasiQuotes skipwhite
syn keyword scalaKeyword def var return end given				nextgroup=scalaNameDefinition skipwhite

" soft modifiers:  TODO: definitely missing some for capture checking
" open			explicitly mark classes as extendable
" opaque		opaque types are treated as complete separate as the objective type but erased at runtime
" transparent           disable type inference to this type. Transparent inline functions allow for non-literal types
" infix 		allow infix notation. `foo startsWith bar` instead of `foo.startsWith(bar)`
" inline		force inlining on values and methods
" extension		add a method to another class. X.foo(Y) is compiled as foo(X)(Y)
syn keyword scalaKeywordModifier
			\ abstract final sealed open
			\ private protected
			\ opaque transparent[] infix inline extension
			\ override lazy implicit
			\ super null
syn keyword scalaSpecialFunction implicitly require

" is eq and ne better as special for unimportant?
syn keyword scalaSpecial this true false ne eq
syn keyword scalaSpecial new							nextgroup=scalaInstanceDeclaration skipwhite
syn match scalaSpecial "\%(=>\|?=>\|<-\|->\)"
syn match scalaSpecial /`[^`]\+`/  " Backtick literals

syn keyword scalaExternal package import export

hi def link scalaKeyword Keyword
hi def link scalaKeywordModifier Function
hi def link scalaSpecialFunction Function
hi def link scalaSpecial PreProc
hi def link scalaExternal Include


" Dim unimportant characters, highlight wildcards, and highlight */ in
" non-comments as well as the depracted arrows
syn match scalaUnimportant "\."
syn match scalaUnimportant ","
syn match scalaUnimportant ";"
syn match scalaUnimportant ":"
syn match scalaUnimportant "!"
syn match scalaUnimportant "@"
syn match scalaUnimportant "#"
syn match scalaUnimportant "%"
syn match scalaUnimportant "\^"
syn match scalaUnimportant "&"
syn match scalaUnimportant "*"
syn match scalaUnimportant "-"
syn match scalaUnimportant "+"
syn match scalaUnimportant "="
syn match scalaUnimportant "/"
syn match scalaUnimportant "|"
syn match scalaUnimportant "\\"
syn match scalaUnimportant "<"
syn match scalaUnimportant ">"
syn match scalaUnimportant "?"
syn match scalaError "*/"
syn match scalaError "\%(⇒\|←\|→\)"
syn match scalaWildcard "*"
syn match scalaWildcard "_\([a-zA-Z0-9$_]\+\)\@!"
"syn match scalaWildcard "?"
hi def link scalaUnimportant Operator
hi def link scalaError Error
hi def link scalaWildcard Macro

exe 'syn region scalaBlock start=/{/ end=/}/ contains=' . s:ContainedGroup() . ' fold'


" Character escapes and such
syn match scalaChar /'.'/
syn match scalaChar /'\\[\\"'ntbrf]'/						contains=scalaEscapedChar
syn match scalaChar /'\\u[A-Fa-f0-9]\{4}'/					contains=scalaUnicodeChar
syn match scalaEscapedChar /\\[\\"'ntbrf]/
syn match scalaUnicodeChar /\\u[A-Fa-f0-9]\{4}/
hi def link scalaChar Character
hi def link scalaEscapedChar Special
hi def link scalaUnicodeChar Special


" names
syn match scalaNameDefinition /\<[_A-Za-z0-9$]\+\>/ 				contained nextgroup=scalaPostNameDefinition,scalaVariableDeclarationList
syn match scalaNameDefinition /`[^`]\+`/ 					contained nextgroup=scalaPostNameDefinition
syn match scalaVariableDeclarationList /\s*,\s*/ 				contained nextgroup=scalaNameDefinition
syn match scalaPostNameDefinition /\_s*:\_s*/ 					contained nextgroup=scalaTypeDeclaration
hi def link scalaNameDefinition Function


" Instance names
syn match scalaInstanceDeclaration /\<[_\.A-Za-z0-9$]\+\>/ 			contained nextgroup=scalaInstanceHash
syn match scalaInstanceDeclaration /`[^`]\+`/ 					contained
syn match scalaInstanceHash /#/ 						contained nextgroup=scalaInstanceDeclaration
hi def link scalaInstanceDeclaration Special
hi def link scalaInstanceHash Type


" in the PreDef, def ???: Nothing = throw new UnimplementedException or 
" something like that
syn match scalaUnimplemented /???/
hi def link scalaUnimplemented ERROR


" Capitalized keywords are often classes. Similarly FULLY_CAPITALIZED_KEYWORDS
" are often globals or something of note 
syn match scalaUScoreCapWord /\<[A-Z_][A-Z0-9$_]*\>/
syn match scalaCapitalWord /\<[A-Z][a-zA-Z0-9$_]*\>/
hi def link scalaUScoreCapWord PreProc
hi def link scalaCapitalWord Special


" Handle type declarations specially
" if we have /\<type\_s\+\ze/ then we match until the end of the line 
" but we also don't want to do anything if its a  Foo.type
syn region scalaTypeStatement matchgroup=Keyword start=/\(\.\)\@<!\<type\_s\+\ze/ end=/$/
			\ contains=scalaTypeTypeDeclaration,scalaSquareBrackets,scalaTypeTypeEquals,scalaTypeStatement

syn match scalaTypeTypeDeclaration /(/						contained nextgroup=scalaTypeTypeExtension,scalaTypeTypeEquals contains=scalaRoundBrackets skipwhite
syn match scalaTypeTypeDeclaration /\%(⇒\|=>\)\ze/ 				contained nextgroup=scalaTypeTypeDeclaration contains=scalaTypeTypeExtension skipwhite
syn match scalaTypeTypeDeclaration /\<[_\.A-Za-z0-9$]\+\>/ 			contained nextgroup=scalaTypeTypeExtension,scalaTypeTypeEquals skipwhite
syn match scalaTypeTypeDeclaration /?/						contained nextgroup=scalaTypeTypeExtension,scalaTypeTypeEquals skipwhite
syn match scalaTypeTypeEquals /=\ze[^>]/ 					contained nextgroup=scalaTypeTypePostDeclaration skipwhite
syn match scalaTypeTypeExtension /)\?\_s*\zs\%(=>\|<:\|:>\|=:=\|:\|#\||\|&\)/ 	contained contains=scalaTypeOperator nextgroup=scalaTypeTypeDeclaration skipwhite
syn match scalaTypeTypePostDeclaration /\<[_\.A-Za-z0-9$]\+\>/ 			contained nextgroup=scalaTypeTypePostExtension skipwhite
syn match scalaTypeTypePostExtension /\%(=>\|<:\|:>\|=:=\|::\||\|&\)/ 		contained contains=scalaTypeOperator nextgroup=scalaTypeTypePostDeclaration skipwhite
hi def link scalaTypeTypeDeclaration Type
hi def link scalaTypeTypeExtension Keyword
hi def link scalaTypeTypePostDeclaration Special
hi def link scalaTypeTypePostExtension Keyword


" and MORE type stuff
syn match scalaTypeDeclaration /(/						contained nextgroup=scalaTypeExtension contains=scalaRoundBrackets skipwhite
syn match scalaTypeDeclaration /\%(=>\)\ze/					contained nextgroup=scalaTypeDeclaration contains=scalaTypeExtension skipwhite
syn match scalaTypeDeclaration /\<[_\.A-Za-z0-9$]\+\>/				contained nextgroup=scalaTypeExtension skipwhite
syn match scalaTypeExtension /)\?\_s*\zs\%(=>\|<:\|:>\|=:=\|::\|#\||\|&\)/	contained contains=scalaTypeOperator nextgroup=scalaTypeDeclaration skipwhite
hi def link scalaTypeDeclaration Type
hi def link scalaTypeExtension Keyword
hi def link scalaTypePostExtension Keyword


" x: Y
syn match scalaTypeAnnotation /\%([_a-zA-Z0-9$\s]:\_s*\)\ze[_=(\.A-Za-z0-9$]\+/	skipwhite nextgroup=scalaTkw,scalaTypeDeclaration contains=scalaUnimportant,scalaRoundBrackets
syn match scalaTypeAnnotation /)\_s*:\_s*\ze[_=(\.A-Za-z0-9$]\+/ 		skipwhite nextgroup=scalaTkw,scalaTypeDeclaration contains=scalaUnimportant
hi clear scalaTypeAnnotation


" pattern match
syn match scalaCaseFollowing /\<[_\.A-Za-z0-9$]\+\>/ 				contained contains=scalaCapitalWord
syn match scalaCaseFollowing /`[^`]\+`/ 					contained contains=scalaCapitalWord
hi def link scalaCaseFollowing Special


" strings
syn match scalaStringEmbeddedQuote /\\"/ 					contained
syn region scalaString start=/"/ end=/"/ 					contains=scalaStringEmbeddedQuote,scalaEscapedChar,scalaUnicodeChar
hi def link scalaString String
hi def link scalaStringEmbeddedQuote String


" interpolation
syn region scalaIString matchgroup=scalaInterpolationBrackets
			\ start=/\<[a-zA-Z][a-zA-Z0-9_]*"/ skip=/\\"/ end=/"/
			\ contains=scalaInterpolation,scalaInterpolationB,scalaEscapedChar,scalaUnicodeChar
syn region scalaTripleIString matchgroup=scalaInterpolationBrackets
			\ start=/\<[a-zA-Z][a-zA-Z0-9_]*"""/ end=/"""\ze\%([^"]\|$\)/
			\ contains=scalaInterpolation,scalaInterpolationB,scalaEscapedChar,scalaUnicodeChar
hi def link scalaIString String
hi def link scalaTripleIString String

syn match scalaInterpolation /\$[a-zA-Z0-9_$]\+/ 				contained
exe 'syn region scalaInterpolationB matchgroup=scalaInterpolationBoundary start=/\${/ end=/}/ contained contains=' . s:ContainedGroup()
hi def link scalaInterpolation Function
hi clear scalaInterpolationB


" F strings are special
syn region scalaFString matchgroup=scalaInterpolationBrackets start=/f"/
			\ skip=/\\"/ end=/"/
			\ contains=scalaFInterpolation,scalaFInterpolationB,scalaEscapedChar,scalaUnicodeChar
syn match scalaFInterpolation /\$[a-zA-Z0-9_$]\+\(%[-A-Za-z0-9\.]\+\)\?/ 	contained
exe 'syn region scalaFInterpolationB matchgroup=scalaInterpolationBoundary start=/${/ end=/}\(%[-A-Za-z0-9\.]\+\)\?/ contained contains=' . s:ContainedGroup()
hi def link scalaFString String
hi def link scalaFInterpolation Function
hi clear scalaFInterpolationB

syn region scalaTripleString start=/"""/ end=/"""\%([^"]\|$\)/ contains=scalaEscapedChar,scalaUnicodeChar
syn region scalaTripleFString matchgroup=scalaInterpolationBrackets
			\ start=/f"""/ end=/"""\%([^"]\|$\)/
			\ contains=scalaFInterpolation,scalaFInterpolationB,scalaEscapedChar,scalaUnicodeChar
hi def link scalaTripleString String
hi def link scalaTripleFString String

hi def link scalaInterpolationBrackets Special
hi def link scalaInterpolationBoundary Function



syn match scalaNumber /\<0[dDfFlL]\?\>/ " Just a bare 0
syn match scalaNumber /\<[1-9]\d*[dDfFlL]\?\>/  " A multi-digit number - octal numbers with leading 0's are deprecated in Scala
syn match scalaNumber /\<0[xX][0-9a-fA-F]\+[dDfFlL]\?\>/ " Hex number
syn match scalaNumber /\%(\<\d\+\.\d*\|\.\d\+\)\%([eE][-+]\=\d\+\)\=[fFdD]\=/ " exponential notation 1
syn match scalaNumber /\<\d\+[eE][-+]\=\d\+[fFdD]\=\>/ " exponential notation 2
syn match scalaNumber /\<\d\+\%([eE][-+]\=\d\+\)\=[fFdD]\>/ " exponential notation 3
hi def link scalaNumber Number



" Scala 3.8 has the into type, which is for implicit conversions
" def foo(x: into[Int]): Int = ???
syn keyword scalaTkw into with contained nextgroup=ScalaTypeDeclaration skipwhite
hi def link scalaTkw Operator

syn region scalaRoundBrackets start="(" end=")" skipwhite contained
        \ contains=scalaTypeDeclaration,scalaSquareBrackets,scalaRoundBrackets,scalaTkw
syn match scalaParenM /[(){}]/
hi def link scalaParenM Comment

syn region scalaSquareBrackets matchgroup=scalaSquareBracketsBrackets
			\ start="\[" end="\]" skipwhite nextgroup=scalaTypeExtension
			\ contains=scalaTypeDeclaration,scalaSquareBrackets,scalaTypeOperator,scalaTypeAnnotationParameter,scalaString,scalaTkw
syn match scalaTypeOperator /[-+=:<>]\+/					contained
syn match scalaTypeAnnotationParameter /@\<[`_A-Za-z0-9$]\+\>/ 			contained
hi def link scalaSquareBracketsBrackets Type
hi def link scalaTypeOperator Keyword
hi def link scalaTypeAnnotationParameter Function

syn match scalaShebang "\%^#!.*" display
syn region scalaMultilineComment start="/\*" end="\*/"
			\ contains=scalaMultilineComment,scalaDocLinks,scalaParameterAnnotation,scalaCommentAnnotation,scalaTodo,scalaCommentCodeBlock,@Spell
			\ keepend fold
syn match scalaCommentAnnotation "@[_A-Za-z0-9$]\+" 				contained
syn match scalaParameterAnnotation "\%(@tparam\|@param\|@see\)" 		nextgroup=scalaParamAnnotationValue skipwhite contained
syn match scalaParamAnnotationValue /[.`_A-Za-z0-9$]\+/ 			contained
syn region scalaDocLinks                                                        start="\[\[" end="\]\]" contained
syn region scalaCommentCodeBlock                                                matchgroup=Keyword start="{{{" end="}}}" contained
syn match scalaTodo "\vTODO|FIXME|XXX" 						contained
hi def link scalaShebang Comment
hi def link scalaMultilineComment Comment
hi def link scalaDocLinks Function
hi def link scalaParameterAnnotation Function
hi def link scalaParamAnnotationValue Keyword
hi def link scalaCommentAnnotation Function
hi def link scalaCommentCodeBlock String
hi def link scalaTodo Todo

syn keyword scalaCliUsing using                                               	contained nextgroup=scalaCliKeyword skipwhite
syn match scalaCliKeyword /\_S\+/																contained
syn match scalaCliOptLine /^\_s*\/\/>.*$/                                      	contains=scalaCliUsing
hi def link scalaCliOptLine Comment
hi def link scalaCliKeyword Keyword
hi def link scalaCliUsing PreProc

syn match scalaAnnotation /@\<[`_A-Za-z0-9$.]\+\>/
hi def link scalaAnnotation PreProc

syn match scalaTrailingComment "//.*$" 						contains=scalaTodo,@Spell,scalaCliOptLine
hi def link scalaTrailingComment Comment

" -------------------------- LIBRARY SYNTAX ----------------------------------
syn keyword scalaBuiltinFunction println print printf assert to until breakable break
hi def link scalaBuiltinFunction Function

syn keyword scalaUnimportant Unit



syn keyword scalaLibEffects IO ZIO
hi def link scalaLibEffects PreProc

syn keyword scalaAkkaSpecialWord when goto using startWith initialize onTransition stay become unbecome
hi def link scalaAkkaSpecialWord PreProc

syn keyword scalatestSpecialWord shouldBe
syn match scalatestShouldDSLA /^\s\+\zsit should/
syn match scalatestShouldDSLB /\<should\>/
hi def link scalatestSpecialWord PreProc
hi def link scalatestShouldDSLA PreProc
hi def link scalatestShouldDSLB PreProc

syn match scalaAkkaFSM /goto([^)]*)\_s\+\<using\>/ contains=scalaAkkaFSMGotoUsing
syn match scalaAkkaFSM /stay\_s\+using/
syn match scalaAkkaFSM /^\s*stay\s*$/
syn match scalaAkkaFSM /when\ze([^)]*)/
syn match scalaAkkaFSM /startWith\ze([^)]*)/
syn match scalaAkkaFSM /initialize\ze()/
syn match scalaAkkaFSM /onTransition/
syn match scalaAkkaFSM /onTermination/
syn match scalaAkkaFSM /whenUnhandled/
syn match scalaAkkaFSMGotoUsing /\<using\>/
syn match scalaAkkaFSMGotoUsing /\<goto\>/
hi def link scalaAkkaFSM PreProc
hi def link scalaAkkaFSMGotoUsing PreProc


" -------------------------- FINALIZE ----------------------------------------


let b:current_syntax = 'scala'

if main_syntax ==# 'scala'
  unlet main_syntax
endif

" vim:set sw=2 sts=2 ts=8 et:
