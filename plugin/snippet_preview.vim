
let g:Lf_Extensions = get(g:, 'Lf_Extensions', {})

function! SnipMateClear(body)
	let text = join(split(a:body, '\n')[:3], ' ; ')
	let text = substitute(text, '^\s*\(.\{-}\)\s*$', '\1', '')
	let text = strcharpart(text, 0, 80)
	let text = substitute(text, '\${[^{}]*}', '...', 'g')
	let text = substitute(text, '\${[^{}]*}', '...', 'g')
	let text = substitute(text, '\s\+', ' ', 'g')
	return text
endfunc

function! SnipMateQuery(word, exact)
	let matches = snipMate#GetSnippetsForWordBelowCursor(a:word, a:exact)
	let result = []
	let size = 4
	for [trigger, dict] in matches
		let body = ''
		if trigger =~ '^\u'
			continue
		endif
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
			let body = SnipMateClear(body)
			let size = max([size, len(trigger)])
			let result += [[trigger, body]]
		endif
	endfor
	for item in result
		let t = item[0] . repeat(' ', size - len(item[0]))
		call extend(item, [t])
	endfor
	return result
endfunc

" for [a, b, c] in SnipMateQuery('', 0)
" 	echo c . '   ' . b
" endfor

function! s:lf_snippet_source(...)
	let source = []
	let matches = SnipMateQuery('', 0)
	call sort(matches)
	for item in matches
		let text = item[2] . ' ' . ' : ' .  item[1]
		let source += [text]
	endfor
	return source
endfunc

function! s:lf_snippet_accept(line, arg)
	let pos = stridx(a:line, ':')
	if pos < 0
		return
	endif
	let name = strpart(a:line, 0, pos)
	let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
	redraw
	if name != ''
		" exec "normal a" . name . "\<m-e>"
		call feedkeys("a" . name . "\<m-e>", "t")
	endif
endfunc

function! s:lf_snippet_preview(...)
	let text = getline('.')
	let pos = stridx(text, ':')
	if pos < 0
		return []
	endif
	let name = strpart(text, 0, pos)
	let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
	return ['this', 'is', name, 'size: '. len(name)]
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

let g:Lf_PreviewResult = get(g:, 'Lf_PreviewResult', {})
let g:Lf_PreviewResult.snippet = 1
let g:Lf_PreviewResult.BufTag = 1
let g:Lf_PreviewResult.Rg = 1



