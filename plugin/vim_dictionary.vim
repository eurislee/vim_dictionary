"======================================================================
"
" vim_dictionary.vim - Automatic loading of dictionary files of corresponding file types.
" Maintainer:          ACWars <http://github.com/euris>
" Version:             0.0.1
" Website:             <http://github.com/euris/vim_dictionary>
"
"======================================================================

"----------------------------------------------------------------------
" global config
"----------------------------------------------------------------------

" additional dictionary folder
let g:vim_dictionary_dictionary = get(g:, 'vim_dictionary_dictionary', [])

" additional tags folder
let g:vim_dictionary_tags = get(g:, 'vim_dictionary_tags', [])

" file type remap, eg: 'html': ['css', 'javascript']
let g:vim_dictionary_config = get(g:, 'vim_dictionary_config', {})

" weather or not add to tags for given filetype
let g:vim_dictionary_enable_tags = get(g:, 'vim_dictionary_enable_tags', {})


"----------------------------------------------------------------------
" internal config
"----------------------------------------------------------------------

" default location
let s:dictionary = expand(fnamemodify(expand('<sfile>'), ':p:h:h') . '/dictionary')

let s:tags = expand(fnamemodify(expand('<sfile>'), ':p:h:h') . '/tags')

" default remap
let s:config = {
			\ "html" : ['css', 'javascript', 'css3'],
			\ }

let s:windows = has('win32') || has('win64') || has('win95') || has('win16')


"----------------------------------------------------------------------
" collect file list
"----------------------------------------------------------------------

" search dictionary files from location
function! s:collect_location(ft, locations)
	let source = []
	for name in a:locations
		let name = fnamemodify(name, ':p')
		if name =~ '^.\+[\/\\]$'
			let name = strpart(name, 0, strlen(name) - 1)
		endif
		let source += [expand(name)]
	endfor
	let paths = join(source, ',')
	let names = globpath(paths, '**/' . a:ft . '.*')
	return split(names, "\n")
endfunc

function! s:pathcase(path)
	if has('win32') || has('win95') || has('win16') || has('win64')
		return tr(tolower(a:path), '/', "\\")
	else
		return a:path
	endif
endfunc

function! s:contains(rtp, filename)
	let name = s:pathcase(a:filename)
	for path in split(a:rtp, ',')
		if s:pathcase(path) == name
			return 1
		endif
	endfor
	return 0
endfunc

function! s:load_dictionary(ft)
	let names = []
	let fts = [a:ft]
	if has_key(g:vim_dictionary_config, a:ft)
		let hh = g:vim_dictionary_config[a:ft]
		if type(hh) == v:t_list
			let fts = hh
		elseif type(hh) == v:t_string
			let fts = []
			for ft in split(hh, ',')
				let ft = substitute(ft, '^\s*\(.\{-}\)\s*$', '\1', '')
				if ft != ''
					let fts += [ft]
				endif
			endfor
		else
			let fts = []
		endif
	endif
	let dictionary = [s:dictionary] + g:vim_dictionary_dictionary
	let tags = [s:tags] + g:vim_dictionary_tags
	for ft in fts
		let names = s:collect_location(ft, dictionary)
		for name in names
			if filereadable(name)
				if s:contains(&dictionaryionary, name) == 0
					exec 'setlocal dictionaryionary+=' . fnameescape(name)
				endif
			endif
		endfor
	endfor
	if get(g:vim_dictionary_enable_tags, a:ft, 0) != 0
		let names = s:collect_location(a:ft, tags)
		for name in names
			if filereadable(name)
				if s:contains(&tags, name) == 0
					exec 'setlocal tags+=' . fnameescape(name)
				endif
			endif
		endfor
	endif
endfunc

"----------------------------------------------------------------------
" autocmd
"----------------------------------------------------------------------
augroup VimDictionaryTags
	au!
	au FileType * call s:load_dictionary(&ft)
augroup END
