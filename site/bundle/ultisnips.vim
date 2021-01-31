
"----------------------------------------------------------------------
" UltiSnips
"----------------------------------------------------------------------
let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h:h:h')

let g:UltiSnipsExpandTrigger="<m-e>"
let g:UltiSnipsJumpForwardTrigger="<m-n>"
let g:UltiSnipsJumpBackwardTrigger="<m-p>"
let g:UltiSnipsListSnippets="<m-m>"
let g:UltiSnipsSnippetDirectories=['UltiSnips', s:home."/usnip"]
let g:snips_author = 'skywind'

