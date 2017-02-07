" Vim syntax file
" Language:	Go Present(Slide) Syntax
" Maintainer:	Koichi Shiraishi
" Filenames:	*.slide

if exists("b:current_syntax")
  finish
endif

if !exists('main_syntax')
  let main_syntax = 'goslide'
endif

runtime! syntax/html.vim
unlet! b:current_syntax


if !exists('g:slide_fenced_languages')
  let g:slide_fenced_languages = []
endif
for s:type in map(copy(g:slide_fenced_languages),'matchstr(v:val,"[^=]*$")')
  if s:type =~ '\.'
    let b:{matchstr(s:type,'[^.]*')}_subtype = matchstr(s:type,'\.\zs.*')
  endif
  exe 'syn include @slideHighlight'.substitute(s:type,'\.','','g').' syntax/'.matchstr(s:type,'[^.]*').'.vim'
  unlet! b:current_syntax
endfor
unlet! s:type


syn sync minlines=10
syn case ignore


" Slide Title:
" TODO(zchee): hardcoded line number
syn match  slideTitle      '^\%1l.*$' contains=slideLineStart
syn match  slideSubTitle   '^\%2l.*$' contains=slideLineStart
syn match  slideDate       '^\%3l.*$' contains=slideLineStart
syn match  slideTags       '^\%4l.*$' contains=slideLineStart
syn match  slideName       '^\%6l.*$' contains=slideLineStart
syn match  slideJobs       '^\%7l.*$' contains=slideLineStart
syn match  slideMail       '^\%8l.*$' contains=slideLineStart
syn match  slideAuthorUrl  '^\%9l.*$' contains=slideLineStart
syn match  slideTwitter   '^\%10l.*$' contains=slideLineStart


" Go Present Preproc:
syn region slideCodeLink        matchgroup=slideCodeDelimiter  start=/\v^\.code/ end="$"  oneline keepend skipwhite contained
syn region slidePlayLink        matchgroup=slidePlayDelimiter  start=/\v^\.play/ end="$"  oneline keepend skipwhite contained
syn region slideImage           matchgroup=slideImageDelimiter  start=/\v^\.image/ end="$" oneline keepend nextgroup=slideImageLink skipwhite contained
syn region slideImageLink       matchgroup=slideImageDelimiter start=" " end=" " oneline keepend contained
syn region slideImageSize       matchgroup=slideImageDelimiter start=/\v^\.image/ end="$" oneline keepend contained nextgroup=slideImageLink,slideImageSize skipwhite contains=slideLineStart,@slideInline,slideImageLink,slideImageSize
syn region slideBackgroundLink  matchgroup=slideBackgroundDelimiter  start=/\v^\.background/ end="$"  oneline keepend skipwhite contained
syn region slideIframeLink      matchgroup=slideIframeDelimiter  start=/\v^\.iframe/ end="$"  oneline keepend skipwhite contained
syn region slideVideoLink       matchgroup=slideVideoDelimiter  start=/\v^\.video/ end="$"  oneline keepend skipwhite contained
syn match  slideLink            /\v^\.link\s/
syn region slideHtmlLink        matchgroup=slideHtmlDelimiter  start=/\v^\.html/ end="$"  oneline keepend skipwhite contained
syn region slideCaption         matchgroup=slideCaptionDelimiter start=/\v^\.caption/ end="$" oneline keepend skipwhite contained


" Valid:
syn match slideValid '[<>]\c[a-z/$!]\@!'
syn match slideValid '&\%(#\=\w*;\)\@!'


syn match slideLineStart "^[<@]\@!" nextgroup=@slideBlock,htmlSpecialChar
syn cluster slideBlock contains=slideTitle,slideSubTitle,slideDate,slideTags,slideName,slideJobs,slideMail,slideAuthorUrl,slideTwitter,slideH1,slideH2,slideH3,slideBlockquote,slideListMarker,slideOrderedListMarker,slideCodeBlock,slideRule,slideCodeLink,slidePlayDelimiter,slideImage,slideImageDelimiter,slideImageLink,slideImageSize,slideBackground,slideIframeLink,slideVideoLink,slideLink,slideHtml,slideCaption
syn cluster slideInline contains=slideLineBreak,slideLinkText,slideItalic,slideBold,slideBoldItalic,slideCode,slideEscape,@htmlTop,slideError


" Header:
syn match slideHeadingRule "^[=-]\+$" contained
syn region slideH1 matchgroup=slideHeadingDelimiter start="\*\s#\@!"      end="#*\s*$" keepend oneline contains=slideLineStart,@slideInline,slideAutomaticLink contained
syn region slideH2 matchgroup=slideHeadingDelimiter start="\*\*\s#\@!"     end="#*\s*$" keepend oneline contains=slideLineStart,@slideInline,slideAutomaticLink contained
syn region slideH3 matchgroup=slideHeadingDelimiter start="\*\*\*\s#\@!"    end="#*\s*$" keepend oneline contains=slideLineStart,@slideInline,slideAutomaticLink contained


" Blockquote:
syn match slideBlockquote ">\%(\s\|$\)" contained nextgroup=@slideBlock


" ListMarker:
syn match slideListMarker "\%(\t\| \{0,4\}\)[-]\%(\s\+\S\)\@=" contained
syn match slideOrderedListMarker "\%(\t\| \{0,4}\)\<\d\+\.\%(\s\+\S\)\@=" contained


" Rule:
syn match slideRule "\* *\* *\*[ *]*$" contained
syn match slideRule "- *- *-[ -]*$" contained


" LineBreak:
syn match slideLineBreak " \{2,\}$"


" Url:
syn region slideIdDeclaration matchgroup=slideLinkDelimiter start="^ \{0,3\}!\=\[" end="\]:" oneline keepend nextgroup=slideUrl skipwhite
syn match  slideUrl "\S\+" nextgroup=slideUrlTitle skipwhite contained
syn region slideUrl matchgroup=slideUrlDelimiter start="<" end=">" oneline keepend nextgroup=slideUrlTitle skipwhite contained
syn region slideUrlTitle matchgroup=slideUrlTitleDelimiter start=+"+ end=+"+ keepend contained
syn region slideUrlTitle matchgroup=slideUrlTitleDelimiter start=+'+ end=+'+ keepend contained
syn region slideUrlTitle matchgroup=slideUrlTitleDelimiter start=+(+ end=+)+ keepend contained

" Link:
syn region slideLinkText matchgroup=slideLinkTextDelimiter start="!\=\[\%(\_[^]]*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@=" keepend nextgroup=slideLink,slideId skipwhite contains=slideLineStart,@slideInline
syn region slideLink matchgroup=slideLinkDelimiter start="(" end=")" contains=slideUrl keepend contained
syn region slideId matchgroup=slideIdDelimiter start="\[" end="\]" keepend contained

syn region slideAutomaticLink matchgroup=slideUrlDelimiter start="<\%(\w\+:\|[[:alnum:]_+-]\+@\)\@=" end=">" keepend oneline


" Bold: *foo*
syn region slideBold start="\S\@<=\*\|\*\S\w\@=" end="\S\w\@<=\*\|\*\S\w\@=" keepend oneline
" Italic: _foo_
syn region slideItalic start="\S\@<=_\|_\S\w\@=" end="\S\w\@<=_\|_\S\w\@=" keepend oneline
" BoldItalic: '*_foo_*' or '_*foo*_'
" syn region slideBoldItalic start="\S\@<=\*_\|\*_\S\w\@=" end="\S\w\@<=\*_\|\*_\S\w\@=" keepend
" syn region slideBoldItalic start="\S\@<=_\*\|_\*\S\w\@=" end="\S\w\@<=_\*\|_\*\S\w\@=" keepend


" Inline Code:
syn region slideCodeBlock matchgroup=slideCodeDelimiter start="    \|\t" end="$" keepend contains=@slideHighlightsh
syn region slideCode matchgroup=slideCodeDelimiter start="`" end="`" keepend contains=slideLineStart
syn region slideCode matchgroup=slideCodeDelimiter start="`` \=" end=" \=``" keepend contains=slideLineStart
syn region slideCode matchgroup=slideCodeDelimiter start="^\s*```.*$" end="^\s*```\ze\s*$" keepend


" Code Highlight:
if main_syntax ==# 'goslide'
  for s:type in g:slide_fenced_languages
    exe 'syn region slideHighlight'.substitute(matchstr(s:type,'[^=]*$'),'\..*','','').' matchgroup=slideCodeDelimiter start="^\s*```'.matchstr(s:type,'[^=]*').'\>.*$" end="^\s*```\ze\s*$" keepend contains=@slideHighlight'.substitute(matchstr(s:type,'[^=]*$'),'\.','','g')
  endfor
  unlet! s:type
endif

" Escape:
syn match slideEscape "\\[][\\`*_{}()#+.!-]"
" Error:
syn match slideError "\w\@<=\w\@="


" Highlight:
hi def link slideTitle                 htmlH1
hi def link slideSubTitle              htmlH2
hi def link slideDate                  Number
hi def link slideTags                  PreProc
hi def link slideName                  Delimiter
hi def link slideJobs                  String
hi def link slideMail                  htmlLink
hi def link slideAuthorUrl             htmlLink
hi def link slideTwitter               htmlLink


hi def link slideCodeDelimiter         PreProc
hi def link slideCodeLink              htmlLink
hi def link slidePlayDelimiter         PreProc
hi def link slidePlayLink              htmlLink
hi def link slideImageDelimiter        PreProc
hi def link slideImageLink             htmlLink
hi def link slideImageSize             Number
hi def link slideBackgroundDelimiter   PreProc
hi def link slideBackgroundLink        htmlLink
hi def link slideIframeDelimiter       PreProc
hi def link slideIframeLink            htmlLink
hi def link slideLink                  PreProc
hi def link slideHtmlDelimiter         PreProc
hi def link slideHtmlLink              htmlLink
hi def link slideVideoDelimiter        PreProc
hi def link slideVideoLink             htmlLink
hi def link slideCaptionDelimiter      PreProc
hi def link slideCaption               String


hi def link slideH1                    htmlH1
hi def link slideH2                    htmlH2
hi def link slideH3                    htmlH3
hi def link slideHeadingRule           slideRule
hi def link slideHeadingDelimiter      Delimiter
hi def link slideOrderedListMarker     slideListMarker
hi def link slideListMarker            htmlTagName
hi def link slideBlockquote            Comment
hi def link slideRule                  PreProc

hi def link slideLinkText              htmlLink
hi def link slideIdDeclaration         Typedef
hi def link slideId                    Type
hi def link slideAutomaticLink         slideUrl
hi def link slideUrl                   Float
hi def link slideUrlTitle              String
hi def link slideIdDelimiter           slideLinkDelimiter
hi def link slideUrlDelimiter          htmlTag
hi def link slideUrlTitleDelimiter     Delimiter

hi def link slideItalic                htmlItalic
hi def link slideBold                  htmlBold
hi def link slideBoldItalic            htmlBoldItalic
hi def link slideCodeDelimiter         Delimiter

hi def link slideEscape                Special
hi def link slideError                 Error

let b:current_syntax = "goslide"
if main_syntax ==# 'goslide'
  unlet main_syntax
endif

" vim:set sw=2:
