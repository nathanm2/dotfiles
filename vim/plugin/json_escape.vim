vnoremap <leader>ej :<c-u>call JsonEscape(visualmode())<cr>

function! JsonEscape(type)
	'<,'>substitute/"/\\"/eg
	'<,'>substitute/^/"/&
	'<,'>substitute/$/"/&
endfunction
