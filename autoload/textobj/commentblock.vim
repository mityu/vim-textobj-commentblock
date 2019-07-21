let s:cpoptions_save = &cpoptions
set cpoptions&vim


if !exists('s:opts')
  let s:opts = {
        \ 'include_spaces': 1,
        \ }
endif

if !exists('s:region')
  let s:region = []
endif

function! s:getopt(kind) abort
  return get(g:, 'textobj_commentblock_' . a:kind, s:opts[a:kind])
endfunction

" Check if the text on the cursor is string or not.
function! s:is_in_string() abort
  return synIDattr(synID(line('.'), col('.'), 0), 'name') =~? 'string'
endfunction

function! s:decide_region(start, end) abort
  let s:region = ['v', a:start, a:end]
  throw 'textobj-commentblock: found-region'
endfunction

" Region for wrap comment.
function! s:select_wrap(kind) abort
  if !(exists('b:textobj_commentblock_wrap') &&
        \ len(b:textobj_commentblock_wrap) == 2)
    return
  endif

  let pattern_open = '\V' . b:textobj_commentblock_wrap[0]
  let pattern_close = '\V' . b:textobj_commentblock_wrap[1] . '\zs'

  if !s:searchpair(pattern_open, pattern_close, 1)
    return
  endif
  let start = getpos('.')

  if !s:searchpair(pattern_open, pattern_close, 0)
    return
  endif
  let end = getpos('.')
  let end[2] -= 1

  if a:kind ==# 'i'
    let start[2] += strlen(b:textobj_commentblock_wrap[0])
    let end[2] -= strlen(b:textobj_commentblock_wrap[1])
  endif

  call s:decide_region(start, end)
endfunction

" If pairs found, returns true.
function! s:searchpair(open, close, use_backward) abort
  let flags = 'W' . (a:use_backward ? 'cb' : '')
  let result = searchpair(a:open, '', a:close, flags, 's:is_in_string()')

  " NOTE: If pair didn't found, searchpair() returns 0 or -1.
  return result > 0
endfunction

" Region for oneline comment.
function! s:select_oneline(kind) abort
  if !(exists('b:textobj_commentblock_oneline') &&
        \ b:textobj_commentblock_oneline !=# '')
    return
  endif

  let pattern = '\V' . b:textobj_commentblock_oneline
  if a:kind ==# 'i'
    let pattern .= '\zs'
  endif

  let linenr_save = line('.')
  let start = []

  while search(pattern, 'bcW', line('.'))
    if s:is_in_string()
      " Try to check if this line is oneline comment or not again!
      " (Strngs sometimes appear on comments)
      continue
    endif
    let start = getpos('.')
    if line('.') == 1
      " It's already reached the top of file.
      break
    elseif getline('.') =~# '^\s*' . pattern
      " If the comment exists at hatpos, check if the prev line is also a
      " oneline comment or not.
      normal! k$
    else
      break
    endif
  endwhile

  if empty(start)  " The cursor isn't on a oneline comment.
    return
  endif

  call cursor(linenr_save, 0)
  let lastline = line('$')

  while 1
    normal! $
    let end = getpos('.')
    if line('.') == lastline
      break
    endif

    " Check if the next line is also a oneline comment or not.
    normal! j
    if getline('.') !~# '^\s*' . pattern
      break
    endif
  endwhile

  if a:kind ==# 'a'
    " Select also newline character.
    let end[2] += 1
  endif

  call s:decide_region(start, end)
endfunction

function! s:select(kind) abort
  let curpos = getpos('.')
  try
    call s:select_wrap(a:kind)
    call s:select_oneline(a:kind)
    return 0
  catch /^textobj-commentblock: found-region$/
    return s:region
  finally
    call setpos('.', curpos)
  endtry
endfunction

function! textobj#commentblock#select_a() abort
  return s:select('a')
endfunction

function! textobj#commentblock#select_i() abort
  return s:select('i')
endfunction

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
