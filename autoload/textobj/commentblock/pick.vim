let s:cpoptions_save = &cpoptions
set cpoptions&vim

function! s:cleanup() abort
  for kind in ['wrap', 'oneline']
    if exists('b:textobj_commentblock_' . kind)
      execute 'unlet b:textobj_commentblock_' . kind
    endif
  endfor
endfunction


function! textobj#commentblock#pick#commentstring() abort
  call s:cleanup()
  let comment = split(substitute(&l:commentstring, '\s', '', 'g'), '%s')
  let len = len(comment)
  if len == 1
    let b:textobj_commentblock_oneline = comment[0]
  elseif len == 2
    let b:textobj_commentblock_wrap = comment
  endif
endfunction

function! textobj#commentblock#pick#caw() abort
  call s:cleanup()
  if exists('b:caw_oneline_comment')
    let b:textobj_commentblock_oneline = b:caw_oneline_comment
  endif
  if exists('b:caw_wrap_oneline_comment')
    let b:textobj_commentblock_wrap = b:caw_wrap_oneline_comment
  endif
endfunction

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
