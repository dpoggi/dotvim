""
"" Get out of Vi mode, load Pathogen, do some setup
""

set nocompatible
nnoremap Q <nop>
let g:pathogen_disabled = []

"" Local pre-load hook for plugin disables/configuration
if filereadable($HOME . '/.vim/plugins.local')
  source ~/.vim/plugins.local
endif

"" Because submodules will inevitably overstay their welcome ¯\_(ツ)_/¯
call extend(g:pathogen_disabled, [
\   'clojure',
\   'cocoa',
\   'command-t',
\   'funcoo',
\   'haml',
\   'ios',
\   'kiwi',
\   'mako',
\   'systemverilog',
\   'ts',
\ ])

"" Comma leader
let mapleader = ','

"" Load pathogen
execute pathogen#infect()

"" But totally also a space leader
map <space> <leader>

"" Backup, swap, and undo directories
set backup
set backupdir=~/.vim/backup//
set swapfile
set directory=~/.vim/swap//
set undofile
set undodir=~/.vim/undo//

"" Search options
set incsearch
set hlsearch
set ignorecase
set smartcase

"" Line numbers and rulers
set number
set numberwidth=5
set cursorline
set ruler

"" Backspace behavior, listchars
set backspace=indent,eol,start
set listchars=tab:>-,trail:.,nbsp:.

"" Status bar
set laststatus=2

"" How did I go without this?
set showcmd

"" 300ms keymap
set timeoutlen=300

"" Enable mouse support, if possible
if has('mouse')
  set mouse=a
  set ttymouse=xterm2
endif


""
"" Wildcards to ignore
""

set wildignore+=.git/**,.svn/**,.hg/**
set wildignore+=*.tmp*,tmp/**
set wildignore+=backup/**,swap/**,undo/**,view/**
set wildignore+=*.dSYM*,*.syms
set wildignore+=*.o,*.obj,pkg/**
set wildignore+=*.exe,*.app,*.ipa
set wildignore+=*.jar,target/**,.idea/**
set wildignore+=.bundle/**,Pods/**,Carthage/**
set wildignore+=bundle/**,vendor/src/**
set wildignore+=build/**,dist/**
set wildignore+=node_modules/**,bower_components/**
set wildignore+=.imported_roles/**


""
"" Unite.vim options
""

"" Same prompt as muh zsh theme <3
let g:unite_prompt = '» '
"" Fuzzy matchers, sort by rank, command defaults
call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])
call unite#custom#profile('default', 'context', {
\   'auto_resize': 1,
\   'direction': 'dynamicbottom',
\   'start_insert': 1,
\ })

function! UniteIgnoreGlobs()
  let l:globs = split(&wildignore, ',')
  "" Filter globs from wildignore *after* candidates come from the source.
  call unite#custom#source('file_rec,file_rec/async,grep',
  \ 'ignore_globs', l:globs) 

  "" Add globs from wildignore to file_rec/async's find(1) args.
  "" For some reason using wildignore to ignore .keep/.gitkeep etc. causes
  "" strange behavior. Fortunately I wanted to start this list with something
  "" to keep the loop simpler anyway, so here it is.
  let g:unite_source_rec_find_args = ['-path', '*.*keep']
  for l:glob in l:globs
    call extend(g:unite_source_rec_find_args, ['-o', '-path'])
    "" If the glob represents a dir (ends in **), add -prune so find(1) won't
    "" descend into it.
    if l:glob =~ '\*\*$'
      call extend(g:unite_source_rec_find_args, [
      \   '*/' . strpart(l:glob, 0, len(l:glob) - 1),
      \   '-prune',
      \ ])
    else
      call extend(g:unite_source_rec_find_args, ['*/' . l:glob])
    endif
  endfor
  "" Handle symlinks and print.
  call extend(g:unite_source_rec_find_args, ['-o', '-type', 'l', '-print'])

  "" TODO: Find a decent way to give the grep source similar arguments.
  "" Why's it not here already? Each one of these tools has slightly different
  "" semantics for passing such arguments, and there are options available to
  "" mitigate the issue. .ptignore, .agignore, and .ackrc all do the trick.
  ""
  "" ack is the single largest impediment, as it has no way to ignore pathname
  "" globs. You get four options: exact match, exact extension, Perl regexp,
  "" or Perl regexp run on the file's first line (shebangs and such). Dang.
endfunction

call UniteIgnoreGlobs()

"" FIXME: If the above TODO gets done, running pt/ag with -U (or even -u) as
"" well as adding globs from wildignore to their args might not be a bad idea.
"" Sometimes you want to search in files you've gitignored or something.

"" Delegate to pt, ag, or ack for searches if available
if executable('pt')
  let g:unite_source_grep_command = 'pt'
  let g:unite_source_grep_default_opts = '-i -e --nogroup --nocolor'
  \ . ' --global-gitignore --home-ptignore'
  let g:unite_source_grep_recursive_opt = ''
elseif executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '-i --vimgrep --hidden'
  \ . ' --ignore ''.git'' --ignore ''.svn'' --ignore ''.hg'''
  let g:unite_source_grep_recursive_opt = ''
elseif executable('ack') || executable('ack-grep')
  if executable('ack')
    let g:unite_source_grep_command = 'ack'
  elseif executable('ack-grep')
    let g:unite_source_grep_command = 'ack-grep'
  endif
  let g:unite_source_grep_default_opts = '-i -k -H --no-heading --no-color'
  let g:unite_source_grep_recursive_opt = ''
else
  let g:unite_source_grep_command = 'grep'
  let g:unite_source_grep_default_opts = '-i -n -H'
  let g:unite_source_grep_recursive_opt = '-r'
endif


""
"" Filetype/highlighting/colorscheme options
""

"" Default shell dialect
let g:is_bash = 1

"" Fix the filetype of certain misidentified shell scripts
function! s:FixShellFt()
  if &filetype == '' || &filetype == 'conf'
    set filetype=sh
  endif
endfunction

"" Fix the filetype for things that look like nginx config
function! s:FixNginxFt()
  if (&filetype == '' || &filetype == 'conf') && &filetype != 'yaml'
    set filetype=nginx
  endif
endfunction

"" Filetype corrections
if has('autocmd')
  au BufRead,BufNewFile Fastfile     set filetype=ruby
  au BufRead,BufNewFile *gemrc*      set filetype=yaml
  au BufRead,BufNewFile *.gradle     set filetype=groovy
  au BufRead,BufNewFile *.hjs        set filetype=handlebars
  au BufRead,BufNewFile jquery.*.js  set filetype=javascript syntax=jquery
  au BufRead,BufNewFile *.jquery.js  set filetype=javascript syntax=jquery
  au BufRead,BufNewFile *.json       set filetype=javascript
  au BufRead,BufNewFile *.mako       set filetype=mako
  au BufRead,BufNewFile *.ru         set filetype=ruby
  au BufRead,BufNewFile *.socket     set filetype=systemd
  au BufRead,BufNewFile Procfile     set filetype=yaml

  au BufRead,BufNewFile *env         call s:FixShellFt()
  au BufRead,BufNewFile *.env.*      call s:FixShellFt()
  au BufRead,BufNewFile *nginx*.conf call s:FixNginxFt()
  au BufRead,BufNewFile */nginx/*    call s:FixNginxFt()
  au BufRead,BufNewFile *profile     call s:FixShellFt()
  au BufRead,BufNewFile *vimrc*      set filetype=vim
  au BufRead,BufNewFile *rc          call s:FixShellFt()
  au BufRead,BufNewFile *rc_*        call s:FixShellFt()
  au BufRead,BufNewFile *.yml        set filetype=yaml
  au BufRead,BufNewFile *.zsh*       set filetype=zsh

  au FileType gitcommit setlocal spell
  au FileType latex     setlocal spell
  au FileType markdown  setlocal spell
  au FileType plaintex  setlocal spell
  au FileType text      setlocal spell
endif

"" Normally we want molokai, but if we're at a basic TTY, solarized looks
"" great, even though it doesn't look like solarized.
set background=dark
if $TERM =~ '^linux' || $TERM =~ '^screen$'
  colorscheme solarized
else
  colorscheme molokai
endif

"" Syntastic options
let g:syntastic_check_on_open = 1
let g:syntastic_quiet_messages = {'level': 'warnings'}

"" Enable syntax highlighting
syntax on


""
"" Indent options - default is 2 spaces
""

function! Spaces(num)
  set expandtab
  set smarttab
  let &tabstop = a:num
  let &softtabstop = 0
  let &shiftwidth = a:num
endfunction

function! Tabs(size)
  set noexpandtab
  set nosmarttab
  let &tabstop = a:size
  let &softtabstop = 0
  let &shiftwidth = a:size
endfunction

"" editorconfig
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

"" Initialize indentation
set autoindent
call Spaces(2)
filetype plugin indent on

"" Indents for specific filetypes
if has('autocmd')
  au FileType * call Spaces(2)

  au FileType apiblueprint  call Spaces(4)
  au FileType cpp           call Spaces(4)
  au FileType java          call Spaces(4)
  au FileType lua           call Spaces(4)
  au FileType php           call Spaces(4)
  au FileType python        call Spaces(4)
  au FileType scala         call Spaces(4)
  au FileType typescript    call Spaces(4)
  au FileType xml           call Spaces(4)

  au FileType bindzone          call Tabs(8)
  au FileType c                 call Tabs(8)
  au FileType make              call Tabs(8)
  au BufRead,BufNewFile *.plist call Tabs(8)
  au FileType sudoers           call Tabs(8)

  au FileType go call Tabs(4)
endif


""
"" Keymap functions
""

function! s:MapHashrocket()
  inoremap <C-l> <space>=><space>
endfunction

function! s:MapLeftArrow()
  inoremap <C-l> <-
endfunction

function! s:MapRightArrow(spaces)
  if a:spaces == 0
    inoremap <C-l> ->
  elseif a:spaces == 1
    inoremap <C-l> <space>->
  elseif a:spaces > 1
    inoremap <C-l> <space>-><space>
  endif
endfunction

function! SetColGuide()
  call inputsave()
  let l:width = substitute(input('Column guide width: '), '[^0-9]', '', 'g')
  call inputrestore()
  redraw

  if l:width != ''
    let g:col_guide_width = l:width
    call ColGuide()
    call ColGuide()
    echom 'Column guide width @ ' . g:col_guide_width . '!'
  else
    echom 'Column guide width must be a number.'
  endif
endfunction

function! ColGuide()
  try
    call matchdelete(g:col_guide)
    return 0
  catch
    if exists('g:col_guide_width')
      let l:width = g:col_guide_width
    else
      let l:width = '80'
    endif
    let g:col_guide = matchadd('Error', '\%>' . l:width . 'v.\+')
    return 1
  endtry
endfunction

function! IgnoreGlob()
  call inputsave()
  let l:glob = substitute(input('Glob to ignore: '), "\n", '', 'g')
  call inputrestore()
  redraw

  if l:glob != ''
    let &wildignore = &wildignore . ',' . l:glob
    call UniteIgnoreGlobs()
  endif
endfunction

function! GetSelectedText(global)
  if a:global
    let l:selection = join(getline(1, '$'), "\n")
  else
    normal! gv"xy
    let l:selection = getreg('x')
    normal! gv
    normal! :<C-u><cr>
  endif

  return l:selection
endfunction

function! Slackcat(global)
  if !executable('slackcat')
    echoerr 'slackcat is not installed.'
    return
  endif

  let l:selection = GetSelectedText(a:global)

  call inputsave()
  let l:channel = substitute(input('Send to: '), "\n", '', 'g')
  call inputrestore()
  redraw

  if l:channel != ''
    call system('slackcat'
    \ . ' -c "' . l:channel . '"'
    \ . ' -n "' . expand('%:t') . '"',
    \ l:selection)
    echom 'Sent to (#|@)' . l:channel . '!'
  else
    echoerr 'Please enter a channel/person to send to.'
  endif
endfunction

function! PasteboardCopy(global)
  if executable('pbcopy')
    let l:cmd = 'pbcopy'
  elseif executable('xsel')
    let l:cmd = 'xsel --clipboard --input'
  else
    echoerr 'Couldn''t find pbcopy or xsel.'
    return
  endif

  let l:selection = GetSelectedText(a:global)
  call system(l:cmd, l:selection)
  echom 'Copied to pasteboard!'
endfunction


""
"" Keymaps
""

"" Ditch <esc>
inoremap <silent> jk <esc>

"" Column guide
nmap <silent> <leader>\ :<C-u>call ColGuide()<cr>
nmap <silent> <leader>s\ :<C-u>call SetColGuide()<cr>

"" Append glob to wildignore
nmap <silent> <leader>ig :<C-u>call IgnoreGlob()<cr>

"" Indents
nmap <leader>2 :<C-u>call Spaces(2)<cr>
nmap <leader>4 :<C-u>call Spaces(4)<cr>
nmap <leader>g4 :<C-u>call Tabs(4)<cr>
nmap <leader>8 :<C-u>call Tabs(8)<cr>

"" Get current file's directory in command mode
cnoremap %% <C-r>=expand('%:h').'/'<cr>

"" Re-indent the entire file
nnoremap <leader>I mmgg=G`m

"" Send visual mode selection to slackcat
xmap <silent> <leader>sc :<C-u>call Slackcat(0)<cr>
"" Send entire file to slackcat
nmap <silent> <leader>sc :<C-u>call Slackcat(1)<cr>

"" Send visual mode selection to pasteboard
xmap <silent> <leader>pc :<C-u>call PasteboardCopy(0)<cr>
"" Send entire file to pasteboard
nmap <silent> <leader>pc :<C-u>call PasteboardCopy(1)<cr>

"" Save a buffer as superuser while running Vim unprivileged
cnoremap w!! w !sudo tee -i % >/dev/null

"" Reload .vimrc
nmap <leader>Rl :<C-u>source ~/.vimrc<cr>

"" <3 make
nmap <silent> <leader>m :<C-u>make<cr>
nmap <silent> <leader>mc :<C-u>make clean<cr>

"" Location list management
nmap <silent> <leader>co :<C-u>copen<cr>
nmap <silent> <leader>cc :<C-u>cclose<cr>
nmap <silent> <leader>cn :<C-u>cn<cr>
nmap <silent> <leader>cp :<C-u>cp<cr>
nmap <silent> <leader>cf :<C-u>cfirst<cr>
nmap <silent> <leader>cl :<C-u>clast<cr>

"" Toggle search highlights + listchars
nmap <leader><tab> :<C-u>set invhlsearch!<cr>
nmap <leader><space> :<C-u>set list!<cr>

"" Flip-flop buffers
nnoremap <leader><leader> <C-^>

"" Tab management
nmap <silent> <leader>tc :<C-u>tabnew<cr>
nmap <silent> <leader>tp :<C-u>tabprev<cr>
nmap <silent> <leader>tn :<C-u>tabnext<cr>
nmap <silent> <leader>td :<C-u>tabclose<cr>

"" Unite.vim
if index(g:pathogen_disabled, 'vimproc') >= 0
  nnoremap <silent> <leader>f :<C-u>Unite file_rec:!<cr>
  nnoremap <silent> <leader>f. :<C-u>Unite file_rec:.<cr>
else
  nnoremap <silent> <leader>f :<C-u>Unite file_rec/async:!<cr>
  nnoremap <silent> <leader>f. :<C-u>Unite file_rec/async:.<cr>
endif
nnoremap <silent> <leader>/ :<C-u>Unite -no-empty grep:.<cr>
nnoremap <silent> <leader>bb :<C-u>Unite buffer<cr>

"" Filetype-specific keymaps
if has('autocmd')
  au FileType php         call s:MapHashrocket()
  au FileType ruby        call s:MapHashrocket()
  au FileType eruby       call s:MapHashrocket()
  au FileType haml        call s:MapHashrocket()
  au FileType puppet      call s:MapHashrocket()
  au FileType scala       call s:MapHashrocket()
  au FileType javascript  call s:MapHashrocket()
  au FileType typescript  call s:MapHashrocket()

  au FileType go call s:MapLeftArrow()

  au FileType c     call s:MapRightArrow(0)
  au FileType cpp   call s:MapRightArrow(0)
  au FileType objc  call s:MapRightArrow(0)

  au FileType coffee call s:MapRightArrow(1)

  au FileType java  call s:MapRightArrow(2)
  au FileType rust  call s:MapRightArrow(2)
  au FileType swift call s:MapRightArrow(2)
endif


""
"" Load vimrc.local if it exists
""

if filereadable($HOME . '/.vim/vimrc.local')
  source ~/.vim/vimrc.local
endif


""
"" CamelCaseMotion
""

if exists('g:camel_override_motions') && g:camel_override_motions
  map <silent> w <Plug>CamelCaseMotion_w
  sunmap w
  map <silent> b <Plug>CamelCaseMotion_b
  sunmap b
  map <silent> e <Plug>CamelCaseMotion_e
  sunmap e
  map <silent> ge <Plug>CamelCaseMotion_ge
  sunmap ge
else
  call camelcasemotion#CreateMotionMappings('<leader>')
endif
