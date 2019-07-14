let s:cpoptions_save = &cpoptions
set cpoptions&vim

call textobj#user#plugin('commentblock', {
      \ '-': {
      \     'select-a': 'ac',
      \     'select-a-function': 'textobj#commentblock#select_a',
      \     'select-i': 'ic',
      \     'select-i-function': 'textobj#commentblock#select_i',
      \     }
      \ })

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
