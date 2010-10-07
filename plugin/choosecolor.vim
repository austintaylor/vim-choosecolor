" File: choosecolor.vim
" Author: Austin Taylor
" Version: 0.1
" License: Distributable under the same terms as Vim itself (see :help license)
" Description: 
"   Opens the Mac OS X color picker, and inserts the chosen color
"   at the current location.
"
" 	Based on the ColorX script by Maximilian Nickel.
" 	(http://www.vim.org/scripts/script.php?script_id=3014)

if (exists("g:loaded_choosecolor") && g:loaded_choosecolor) || !has('mac')
  finish
endif
let g:loaded_choosecolor = 1

function! s:action_script()
  let app = 'Terminal.app'
  if has('gui_macvim')
    let app = 'MacVim.app'
  endif
  let commands = ['-e "tell application \"' . s:app . '\""', 
                \ '-e "activate"', 
                \ "-e \"set AppleScript's text item delimiters to {\\\",\\\"}\"",
                \ '-e "set col to (choose color' . s:parse_hex_color() . ') as text',
                \ '-e "end tell"']
  return "osascript" . join(commands, ' ')
endfunction

function! s:parse_hex_color()
	let c = expand("<cword>")
	if c !=~ '\v\c[A-F1-9]{3,6}'
    let c = 'FFFFFF'
  endif

  if len(c) == 3
    let sr = strpart(c,0,1) . strpart(c,0,1)
    let sg = strpart(c,1,1) . strpart(c,1,1)
    let sb = strpart(c,2,1) . strpart(c,2,1)
  else
    let sr = strpart(c,0,2)
    let sg = strpart(c,2,2)
    let sb = strpart(c,4,2)
  endif
  let cr = str2nr(sr, 16) * 256
  let cg = str2nr(sg, 16) * 256
  let cb = str2nr(sb, 16) * 256
  return printf('default color {%d,%d,%d}', cr, cg, cb) 
endfunction

function! s:choose_color()
  let result = system(s:action_script())
  if result =~ ','
    let rgb = split(result, ',')
    let hex = printf('%02X%02X%02X', str2nr(rgb[0])/256, str2nr(rgb[1])/256, str2nr(rgb[2])/256)
    let word = expand("<cword>")
    if word =~ '\([a-fA-F1-9]\{3,6\}\)'
      exe "normal ciw" . hex
    else
      exe "normal a#" . hex
    endif
  endif
endfunction

command! ChooseColor :call s:choose_color()

