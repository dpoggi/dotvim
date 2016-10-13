""
"" Get out of Vi mode, load Pathogen, do some setup
""

set nocompatible
nnoremap Q <nop>
let g:pathogen_disabled = []
let g:airline_extensions = []

"" Local pre-load hook for plugin disables/configuration
if filereadable($HOME . '/.vim/plugins.local')
  source ~/.vim/plugins.local
endif

"" Because submodules will inevitably overstay their welcome ¯\_(ツ)_/¯
call extend(g:pathogen_disabled, [
\   'CamelCaseMotion',
\   'clojure',
\   'cocoa',
\   'command-t',
\   'funcoo',
\   'haml',
\   'ios',
\   'kiwi',
\   'mako',
\   'powerline',
\   'systemverilog',
\   'ts',
\ ])

"" Skip vim-airline extensions unless specified.
let g:airline#extensions#disable_rtp_load = 1
let g:airline#extensions#tabline#enabled = 1
call extend(g:airline_extensions, [
\   'branch',
\   'hunks',
\   'syntastic',
\   'tabline',
\   'unite',
\   'whitespace',
\ ])

"" Comma leader
let mapleader = ','
let g:mapleader = ','

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

"" Finder metadata
set wildignore+=.DS_Store
"" Source control
set wildignore+=.git/**
set wildignore+=.hg/**
set wildignore+=.svn/**
set wildignore+=.keep,.gitkeep,.hgkeep
"" Temporary files
set wildignore+=tmp/**
set wildignore+=*.tmp
"" ~/.vim
set wildignore+=backup/**
set wildignore+=undo/**
"" Native objects/debug symbols/binaries
set wildignore+=*.o,*.obj,*.dSYM,*.exe,*.app,*.ipa
"" Java
set wildignore+=target/**
set wildignore+=.gradle/**
set wildignore+=*.class,*.jar
"" IDEA
set wildignore+=.idea/**
"" Ruby
set wildignore+=.bundle/**
"" Python
set wildignore+=*.pyc
"" CocoaPods/Carthage
set wildignore+=Pods/**
set wildignore+=Carthage/**
"" Common build directories
set wildignore+=build/**
set wildignore+=dist/**
"" Go (projects built with gb)
set wildignore+=vendor/src/**
"" JavaScript
set wildignore+=node_modules/**
"" Ansible
set wildignore+=.imported_roles/**


""
"" Unite.vim options
""

"" Fix Unite setting LC_NUMERIC improperly, causing locale errors... grrr...
if $LC_NUMERIC == 'en_US.utf8'
  let $LC_NUMERIC = 'en_US.UTF-8'
endif

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

let s:globs = split(&wildignore, ',')
let s:unite_glob_sources = 'file_rec,file_rec/async,file_mru,file,buffer,grep'

"" Filter globs from wildignore *after* candidates come from the source.
call unite#custom#source(s:unite_glob_sources, 'ignore_globs', s:globs)
"" Set max_candidates to 0 (no limit).
call unite#custom#source(s:unite_glob_sources, 'max_candidates', 0)

let g:unite_source_rec_find_args = ['-name', 'Thumbs.db']
for s:glob in s:globs
  if s:glob =~ '\*\*$'
    "" If the glob represents a dir (ends in **), remove the final asterisk,
    "" prepend a wildcard and a path separator, and match as a path part.
    let s:path_glob = '*/' . strpart(s:glob, 0, len(s:glob) - 1)
    call extend(g:unite_source_rec_find_args, ['-o', '-path', s:path_glob])
  else
    "" If it's a file, match as a regular name wildcard.
    call extend(g:unite_source_rec_find_args, ['-o', '-name', s:glob])
  endif
endfor

"" Prune the above, add in symlinks, and print.
call extend(g:unite_source_rec_find_args, [
\   '-prune',
\   '-o', '-type', 'l',
\ ])

"" Delegate to pt, ag, or ack for searches if available
if executable('pt')
  let g:unite_source_grep_command = 'pt'
  let g:unite_source_grep_default_opts = '-i -e --nogroup --nocolor' .
  \                                      ' --global-gitignore --home-ptignore'
  let g:unite_source_grep_recursive_opt = ''
elseif executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '-i --vimgrep --hidden' .
  \                                      ' --ignore ''.git''' .
  \                                      ' --ignore ''.svn''' .
  \                                      ' --ignore ''.hg'''
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

"" Hack to make Syntastic forget it has support for running javac
let g:loaded_syntastic_java_javac_checker = 1

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
  "" lol (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧
  "" because why not edit Elisp in Vim and Vimscript in Emacs
  au BufRead,BufNewFile .spacemacs   set filetype=lisp
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

  au FileType unite AirlineRefresh
endif

"" Normally we want molokai, but if we're at a basic TTY, solarized looks
"" great, even though it doesn't look like solarized.
set background=dark
if $TERM =~ '^linux' || $TERM =~ '^screen$'
  colorscheme solarized
  let g:airline_theme = 'solarized'
else
  colorscheme molokai
  let g:airline_theme = 'molokai'
endif

"" Have vim-airline avoid Powerline fonts until told otherwise in vimrc.local
let g:airline_powerline_fonts = 0

"" Signify should avoid SVN for now...
let g:signify_vcs_list = ['git', 'hg']
"" And check when we focus Vim
let g:signify_update_on_focusgained = 1

"" Syntastic options
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
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

  au FileType bindzone          call Tabs(8)
  au FileType c                 call Tabs(8)
  au FileType gitconfig         call Tabs(8)
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
    echom 'Column guide width set to ' . g:col_guide_width . '!'
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
      let l:width = '79'
    endif

    let g:col_guide = matchadd('Error', '\%>' . l:width . 'v.\+')
    return 1
  endtry
endfunction

"" This is completely superfluous, but it's how I'm doing it for the moment.
function! SendSplitTo(direction, retain_focus)
  if a:retain_focus
    let l:start_win_id = win_getid()
    if l:start_win_id == 0
      return 1
    endif
  endif

  if a:direction == 'below'
    belowright split
  elseif a:direction == 'right'
    belowright vsplit
  elseif a:direction == 'above'
    aboveleft split
  elseif a:direction == 'left'
    aboveleft vsplit
  else
    return 1
  endif

  if a:retain_focus
    let l:result = win_gotoid(l:start_win_id)
    if l:result != 1
      return 1
    endif
  endif
endfunction

function! SyntasticToggleErrors()
  let l:buffers = filter(tabpagebuflist(), 'getbufvar(v:val, "&buftype") is# "quickfix"')
  if empty(l:buffers)
    Errors
  else
    lclose
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
    echoerr 'Couldn''t find slackcat.'
    return
  endif

  let l:selection = GetSelectedText(a:global)

  call inputsave()
  let l:channel = substitute(input('Send to: '), "\n", '', 'g')
  call inputrestore()
  redraw

  if l:channel != ''
    call system('slackcat'
    \           . ' -c "' . l:channel . '"'
    \           . ' -n "' . expand('%:t') . '"',
    \           l:selection)
    echom 'Sent to (#|@)' . l:channel . '!'
  else
    echoerr 'Please enter a channel/user to send to.'
  endif
endfunction

if executable('pbcopy')
  let g:pasteboard_cmd = 'pbcopy'
elseif executable('xsel')
  let g:pasteboard_cmd = 'xsel --clipboard --input'
endif

function! PasteboardCopy(global)
  if !exists('g:pasteboard_cmd')
    echoerr 'Couldn''t find pbcopy or xsel.'
    return
  endif

  let l:selection = GetSelectedText(a:global)
  call system(g:pasteboard_cmd, l:selection)
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
xmap <silent> <leader>xs :<C-u>call Slackcat(0)<cr>
"" Send entire file to slackcat
nmap <silent> <leader>xs :<C-u>call Slackcat(1)<cr>

"" Send visual mode selection to pasteboard
xmap <silent> <leader>xy :<C-u>call PasteboardCopy(0)<cr>
"" Send entire file to pasteboard
nmap <silent> <leader>xy :<C-u>call PasteboardCopy(1)<cr>

"" Save a buffer as superuser while running Vim unprivileged
cnoremap w!! w !sudo tee -i % >/dev/null

"" Open plugins.local
nmap <leader>fei :<C-u>edit ~/.vim/plugins.local<cr>
"" Open vimrc.local
nmap <leader>fed :<C-u>edit ~/.vim/vimrc.local<cr>
"" Open .vimrc
nmap <leader>feV :<C-u>edit ~/.vimrc<cr>
"" Reload .vimrc
nmap <leader>feR :<C-u>source ~/.vimrc<cr>

"" <3 make
nmap <silent> <leader>m :<C-u>make<cr>
nmap <silent> <leader>md :<C-u>make debug<cr>
nmap <silent> <leader>mc :<C-u>make clean<cr>

"" Location list management
nmap <silent> <leader>ll :<C-u>call SyntasticToggleErrors()<cr>
nmap <silent> <leader>lt :<C-u>SyntasticToggleMode<cr>
nmap <silent> <leader>lj :<C-u>lnext<cr>
nmap <silent> <leader>lk :<C-u>lprevious<cr>
nmap <silent> <leader>lg :<C-u>lfirst<cr>
nmap <silent> <leader>lG :<C-u>llast<cr>

"" Toggle search highlights + listchars
nmap <leader>? :<C-u>set invhlsearch!<cr>
nmap <leader><tab> :<C-u>set list!<cr>

"" Flip-flop buffers
nnoremap <leader><leader> <C-^>

"" Buffer management
nmap <silent> <leader>bp :<C-u>bprevious<cr>
nmap <silent> <leader>bn :<C-u>bnext<cr>
nmap <silent> <leader>bd :<C-u>bdelete<cr>

"" Window management
nmap <silent> <leader>wc :<C-u>close<cr>
nmap <silent> <leader>wd :<C-u>wincmd q<cr>
nmap <silent> <leader>wM :<C-u>wincmd x<cr>
nmap <silent> <leader>wr :<C-u>wincmd r<cr>
nmap <silent> <leader>wR :<C-u>wincmd R<cr>
nmap <silent> <leader>ww :<C-u>wincmd w<cr>

"" Do the splits!
nmap <silent> <leader>wv :<C-u>call SendSplitTo('right', 1)<cr>
nmap <silent> <leader>wV :<C-u>belowright vsplit<cr>
nmap <silent> <leader>ws :<C-u>call SendSplitTo('bottom', 1)<cr>
nmap <silent> <leader>wS :<C-u>belowright split<cr>

"" Window movement
nmap <silent> <leader>wh :<C-u>wincmd h<cr>
nmap <silent> <leader>wj :<C-u>wincmd j<cr>
nmap <silent> <leader>wk :<C-u>wincmd k<cr>
nmap <silent> <leader>wl :<C-u>wincmd l<cr>

"" Tab management
nmap <silent> <leader>tc :<C-u>tabnew<cr>
nmap <silent> <leader>tp :<C-u>tabprev<cr>
nmap <silent> <leader>tn :<C-u>tabnext<cr>
nmap <silent> <leader>td :<C-u>tabclose<cr>

"" Peace out
nmap <silent> <leader>qQ :<C-u>qall!<cr>

"" Unite.vim
if index(g:pathogen_disabled, 'vimproc') >= 0
  nnoremap <silent> <leader>f :<C-u>Unite file_rec:!<cr>
  nnoremap <silent> <leader>f. :<C-u>Unite file_rec:.<cr>
else
  nnoremap <silent> <leader>f :<C-u>Unite file_rec/async:!<cr>
  nnoremap <silent> <leader>f. :<C-u>Unite file_rec/async:.<cr>
endif
nnoremap <silent> <leader>/ :<C-u>Unite -no-empty grep:!<cr>
nnoremap <silent> <leader>/. :<C-u>Unite -no-empty grep:.<cr>
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
