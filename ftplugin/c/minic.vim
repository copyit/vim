if exists('b:ftplugin_minic')
	finish
endif

let b:ftplugin_minic = 1

if !exists('g:ftplugin_init_splint')
	IncScript site/opt/ale_splint.vim
	IncScript site/opt/ale_cppcheck2.vim
	let g:ftplugin_init_splint = 1
endif


setlocal commentstring=//\ %s
setlocal comments-=:// comments+=:///,://

let b:commentary_format = "// %s"


