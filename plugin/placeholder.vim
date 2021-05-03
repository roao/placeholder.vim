if exists('g:loaded_place_holder')
    finish
endif
let g:loaded_place_holder = 1

" ================================================================
"func from latex-suite
" ================================================================
" spaceholder

function! IMAP_Jumpfunc(direction, inclusive)

	" The user's placeholder settings.
	let phsUser = "<+"
	let pheUser = "+>"

	" Set up flags for the search() function
	let flags = a:direction
	if a:inclusive
		let flags .= 'c'
	end

	let searchString = '\V'.phsUser.'\_.\{-}'.pheUser

	" If we didn't find any placeholders return quietly.
	if !search(searchString, flags)
		return
	endif

	" Open any closed folds and make this part of the text visible.
	silent! foldopen!

	" We are at the starting placeholder. Start visual mode.
	normal! v

	" Calculate if we have an empty placeholder. It is empty if both
	" placeholders appear one after the other.
	" Check also whether the empty placeholder ends at the end of the line.
	let curline = strpart(getline('.'), col('.')-1)
	let phUser = phsUser.pheUser
	let placeHolderEmpty = (strpart(curline,0,strlen(phUser)) ==# phUser)
	let placeHolderEOL = (curline ==# phUser)

	" Search for the end placeholder and position the cursor.
	call search(searchString, 'ce')

	" If we are selecting in exclusive mode, then we need to move one step to
	" the right
	if &selection == 'exclusive'
		normal! l
	endif

    let Imap_DeleteEmptyPlaceHolders = 1
	" see texrc

	let Imap_GoToSelectMode = 0
	"as name show

	" Now either goto insert mode, visual mode or select mode.
	if placeHolderEmpty && Imap_DeleteEmptyPlaceHolders
		" Delete the empty placeholder into the blackhole.
		normal! "_d
		" Start insert mode. If the placeholder was at the end of the line, use
		" startinsert! (equivalent to 'A'), otherwise startinsert (equiv. 'i')
		if placeHolderEOL
			startinsert!
		else
			startinsert
		endif
	else
		if Imap_GoToSelectMode
			" Go to select mode
			execute "normal! \<C-g>"
		else
			" Do not go to select mode
		endif
	endif
endfunction
" }}}


" jumping forward and back in insert mode.
inoremap <silent> <Plug>IMAP_JumpForward    <C-\><C-N>:call IMAP_Jumpfunc('', 0)<CR>
inoremap <silent> <Plug>IMAP_JumpBack       <C-\><C-N>:call IMAP_Jumpfunc('b', 0)<CR>

" jumping in normal mode
nnoremap <silent> <Plug>IMAP_JumpForward        :call IMAP_Jumpfunc('', 0)<CR>
nnoremap <silent> <Plug>IMAP_JumpBack           :call IMAP_Jumpfunc('b', 0)<CR>

" deleting the present selection and then jumping forward.
vnoremap <silent> <Plug>IMAP_DeleteAndJumpForward       "_<Del>:call IMAP_Jumpfunc('', 0)<CR>
vnoremap <silent> <Plug>IMAP_DeleteAndJumpBack          "_<Del>:call IMAP_Jumpfunc('b', 0)<CR>

" jumping forward without deleting present selection.
vnoremap <silent> <Plug>IMAP_JumpForward       <C-\><C-N>:call IMAP_Jumpfunc('', 0)<CR>
vnoremap <silent> <Plug>IMAP_JumpBack          <C-\><C-N>`<:call IMAP_Jumpfunc('b', 0)<CR>

" }}}
" Default maps for IMAP_Jumpfunc {{{
" map only if there is no mapping already. allows for user customization.
" NOTE: Default mappings for jumping to the previous placeholder are not
"       provided. It is assumed that if the user will create such mappings
"       hself if e so desires.
if !hasmapto('<Plug>IMAP_JumpForward', 'i')
    imap <C-J> <Plug>IMAP_JumpForward
endif
if !hasmapto('<Plug>IMAP_JumpForward', 'n')
    nmap <C-J> <Plug>IMAP_JumpForward
endif

if !hasmapto('<Plug>IMAP_JumpBack', 'i')
    imap <C-K> <Plug>IMAP_JumpBack
endif
if !hasmapto('<Plug>IMAP_JumpBack', 'n')
    nmap <C-K> <Plug>IMAP_JumpBack
endif

let Imap_StickyPlaceHolders = 0
" see texrc
if  Imap_StickyPlaceHolders
	if !hasmapto('<Plug>IMAP_JumpForward', 'v')
		vmap <C-J> <Plug>IMAP_JumpForward
	endif
else
	if !hasmapto('<Plug>IMAP_DeleteAndJumpForward', 'v')
		vmap <C-J> <Plug>IMAP_DeleteAndJumpForward
	endif
endif

if  Imap_StickyPlaceHolders
	if !hasmapto('<Plug>IMAP_JumpForward', 'v')
		vmap <C-K> <Plug>IMAP_JumpBack
	endif
else
	if !hasmapto('<Plug>IMAP_DeleteAndJumpForward', 'v')
		vmap <C-K> <Plug>IMAP_DeleteAndJumpBack
	endif
endif
" }}}
