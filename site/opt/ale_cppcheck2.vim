" Author: Bart Libert <bart.libert@gmail.com>
" Description: cppcheck linter for c files

call ale#Set('c_cppcheck_executable', 'cppcheck')
call ale#Set('c_cppcheck_options', '--enable=style')
call ale#Set('cpp_cppcheck_executable', 'cppcheck')
call ale#Set('cpp_cppcheck_options', '--enable=style')

function! s:c_cppcheck_GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'c_cppcheck_executable')
endfunction

function! s:cpp_cppcheck_GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cpp_cppcheck_executable')
endfunction

function! s:c_cppcheck_GetCommand(buffer) abort
    " Search upwards from the file for compile_commands.json.
    "
    " If we find it, we'll `cd` to where the compile_commands.json file is,
    " then use the file to set up import paths, etc.
    let l:compile_commmands_path = ale#path#FindNearestFile(a:buffer, 'compile_commands.json')

    let l:cd_command = !empty(l:compile_commmands_path)
    \   ? ale#path#CdString(fnamemodify(l:compile_commmands_path, ':h'))
    \   : ''
    let l:compile_commands_option = !empty(l:compile_commmands_path)
    \   ? '--project=compile_commands.json '
    \   : ''

    return l:cd_command
    \   . ale#Escape(s:c_cppcheck_GetExecutable(a:buffer))
    \   . ' -q --language=c++ '
    \   . l:compile_commands_option
    \   . ale#Var(a:buffer, 'c_cppcheck_options')
    \   . ' %t'
endfunction

function! s:cpp_cppcheck_GetCommand(buffer) abort
    " Search upwards from the file for compile_commands.json.
    "
    " If we find it, we'll `cd` to where the compile_commands.json file is,
    " then use the file to set up import paths, etc.
    let l:compile_commmands_path = ale#path#FindNearestFile(a:buffer, 'compile_commands.json')

    let l:cd_command = !empty(l:compile_commmands_path)
    \   ? ale#path#CdString(fnamemodify(l:compile_commmands_path, ':h'))
    \   : ''
    let l:compile_commands_option = !empty(l:compile_commmands_path)
    \   ? '--project=compile_commands.json '
    \   : ''

    return l:cd_command
    \   . ale#Escape(s:cpp_cppcheck_GetExecutable(a:buffer))
    \   . ' -q --language=c++ '
    \   . l:compile_commands_option
    \   . ale#Var(a:buffer, 'cpp_cppcheck_options')
    \   . ' %t'
endfunction

function! s:cppcheck_HandleCppCheckFormat(buffer, lines) abort
    " Look for lines like the following.
    "
    " [test.cpp:5]: (error) Array 'a[10]' accessed at index 10, which is out of bounds
    let l:pattern = '\v^\[(.+):(\d+)\]: \(([a-z]+)\) (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if ale#path#IsBufferPath(a:buffer, l:match[1])
            call add(l:output, {
            \   'lnum': str2nr(l:match[2]),
            \   'type': l:match[3] is# 'error' ? 'E' : 'W',
            \   'text': l:match[4],
            \})
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('c', {
\   'name': 'cppcheck2',
\   'output_stream': 'both',
\   'executable': {b -> ale#Var(b, 'c_cppcheck_executable')},
\   'command': function('s:c_cppcheck_GetCommand'),
\   'callback': function('s:cppcheck_HandleCppCheckFormat'),
\})

call ale#linter#Define('cpp', {
\   'name': 'cppcheck2',
\   'output_stream': 'both',
\   'executable': {b -> ale#Var(b, 'cpp_cppcheck_executable')},
\   'command': function('s:cpp_cppcheck_GetCommand'),
\   'callback': function('s:cppcheck_HandleCppCheckFormat'),
\})


