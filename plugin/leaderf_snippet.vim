"----------------------------------------------------------------------
" Query SnipMate Database
"----------------------------------------------------------------------
function! SnipMateQuery(word, exact) abort
	let matches = snipMate#GetSnippetsForWordBelowCursor(a:word, a:exact)
	let result = []
	let size = 4
	for [trigger, dict] in matches
		let body = ''
		for key in keys(dict)
			let value = dict[key]
			if type(value) == v:t_list
				if len(value) > 0
					let body = value[0]
					break
				endif
			endif
		endfor
		if body != ''
			let size = max([size, len(trigger)])
			let result += [[trigger, body]]
		endif
	endfor
	for item in result
		let t = item[0] . repeat(' ', size - len(item[0]))
		call extend(item, [t])
	endfor
	call sort(result)
	return result
endfunc


"----------------------------------------------------------------------
" Simplify Snippet Body
"----------------------------------------------------------------------
function! SnipMateDescription(body, width) abort
	let text = join(split(a:body, '\n')[:4], ' ; ')
	let text = substitute(text, '^\s*\(.\{-}\)\s*$', '\1', '')
	let text = substitute(text, '\${[^{}]*}', '...', 'g')
	let text = substitute(text, '\${[^{}]*}', '...', 'g')
	let text = substitute(text, '\s\+', ' ', 'g')
	let text = strcharpart(text, 0, a:width)
	return text
endfunc


"----------------------------------------------------------------------
" internal 
"----------------------------------------------------------------------
let s:bufid = -1
let s:filetype = ''
let s:accept = ''
let s:snips = {}
let g:Lf_Extensions = get(g:, 'Lf_Extensions', {})


function! s:lf_snippet_source(...)
	let source = []
	let matches = SnipMateQuery('', 0)
	let snips = {}
	let width = 100
	for item in matches
		let trigger = item[0]
		if trigger =~ '^\u'
			continue
		endif
		let desc = SnipMateDescription(item[1], width)
		let text = item[2] . ' ' . ' : ' . desc
		let snips[trigger] = item[1]
		let source += [text]
	endfor
	let s:snips = snips
	return source
endfunc

" echo s:lf_snippet_source()

function! s:lf_snippet_accept(line, arg)
	let pos = stridx(a:line, ':')
	if pos < 0
		return
	endif
	let name = strpart(a:line, 0, pos)
	let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
	redraw
	if name != ''
		let s:accept = name . "\<Plug>snipMateTrigger"
		if mode(1) =~ 'i'
			call feedkeys(name . "\<Plug>snipMateTrigger", '!')
			" call feedkeys(name . "\<c-r>=snipMate#TriggerSnippet(1)\<cr>", '!')
		else
			call feedkeys('a' . name . "\<Plug>snipMateTrigger", '!')
		endif
	endif
endfunc


function! s:lf_snippet_preview(orig_buf_nr, orig_cursor, line, args)
	let text = a:line
	let pos = stridx(text, ':')
	if pos < 0 
		return []
	endif
	let name = strpart(text, 0, pos)
	let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
	let body = get(s:snips, name, '')
	if body == ''
		unsilent echom "SUCK"
		return []
	endif
	if s:bufid < 0
		let s:bufid = bufadd('')
		let bid = s:bufid
		call bufload(bid)
		call setbufvar(bid, '&buflisted', 0)
		call setbufvar(bid, '&bufhidden', 'hide')
		call setbufvar(bid, '&modifiable', 1)
		call deletebufline(bid, 1, '$')
		call setbufvar(bid, '&modified', 0)
		call setbufvar(bid, 'current_syntax', '')
		call setbufvar(bid, '&filetype', '')
	endif
	let bid = s:bufid
	let textlist = split(body, '\n')
	call setbufvar(bid, '&modifiable', 1)
	call setbufline(bid, 1, textlist)
	call setbufvar(bid, '&modified', 0)
	call setbufvar(bid, '&modifiable', 0)
	return [bid, 1, '']
endfunc

function! s:lf_win_init(...)
	setlocal nonumber nowrap
endfunc

let g:Lf_Extensions.snippet = {
			\ 'source': string(function('s:lf_snippet_source'))[10:-3],
			\ 'accept': string(function('s:lf_snippet_accept'))[10:-3],
			\ 'preview': string(function('s:lf_snippet_preview'))[10:-3],
			\ 'highlights_def': {
			\     'Lf_hl_funcScope': '^\S\+',
			\ },
			\ 'after_enter': string(function('s:lf_win_init'))[10:-3],
		\ }



