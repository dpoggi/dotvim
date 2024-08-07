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
\   'elm',
\   'funcoo',
\   'haml',
\   'ios',
\   'kiwi',
\   'mako',
\   'nginx',
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


""
"" org.apache.commons.lang3.StringUtils
"" ... lol. These chomp/strip _each line_ of their input.
""

function! s:Chomp(str)
  return substitute(a:str, '\m\C\n\+$', '', 'g')
endfunction

function! s:Strip(str)
  return substitute(a:str, '\m\C^\s*\(.\{-}\)\s*$', '\1', 'g')
endfunction


"" OS detection
if has('win32unix')
  let g:dcp_os = 'Cygwin'
elseif has('win32') || has('win64') || has('win95')
  let g:dcp_os = 'Windows'
elseif has('macunix') || has('osx')
  let g:dcp_os = 'Darwin'
else
  let g:dcp_os = s:Chomp(system('uname -s'))
endif

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

"" Completion menus are good
set wildmenu

"" Don't redraw if we don't need to
set lazyredraw

"" Show matching ([{
set showmatch

"" 300ms keymap
set timeoutlen=300

"" Enable mouse support, if possible
if has('mouse')
  set mouse=a
  set ttymouse=sgr
endif

"" Hopefully this makes Cygwin/MSYS/MinGW work?
if g:dcp_os ==# 'Cygwin'
  set shellslash
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
set wildignore+=.bundle/ruby/**
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
if $LC_NUMERIC ==# 'en_US.utf8'
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
  if s:glob =~# '\m\C\*\*$'
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

"" Delegate to ripgrep, ag, pt, or ack for searches if available
if executable('rg')
  let g:unite_source_grep_command = 'rg'
  let g:unite_source_grep_default_opts = '--no-heading --ignore --smart-case --vimgrep'
  let g:unite_source_grep_recursive_opt = ''
elseif executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '-i --vimgrep --hidden'
                                     \ . ' --ignore ''.git'''
                                     \ . ' --ignore ''.svn'''
                                     \ . ' --ignore ''.hg'''
  let g:unite_source_grep_recursive_opt = ''
elseif executable('pt')
  let g:unite_source_grep_command = 'pt'
  let g:unite_source_grep_default_opts = '-i -e --nogroup --nocolor'
                                      \ .' --global-gitignore --home-ptignore'
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

"" Disable Vim version warning from Go plugin
let g:go_version_warning = 0
"" Use goimports if available
if executable('goimports')
  let g:go_fmt_command = 'goimports'
endif

function! s:VimprocUsable()
  if index(g:pathogen_disabled, 'vimproc') >= 0
    return 0
  endif
  if !filereadable(g:vimproc#dll_path)
    return 0
  endif
  return 1
endfunction

function! s:RbenvMriPath(version)
  if a:version =~# '[^0-9.]'
    "" Only applies to MRI
    return ''
  endif

  return fnameescape(
    \ expand($RBENV_ROOT . '/versions/' . a:version . '/bin/ruby'))
endfunction

function! s:SyntasticDetectRbenvMri()
  if empty($RBENV_ROOT) || !s:VimprocUsable()
    return
  endif

  if !empty($RBENV_VERSION)
    let l:exec_path = s:RbenvMriPath($RBENV_VERSION)

    if executable(l:exec_path)
      let g:syntastic_ruby_mri_exec = l:exec_path
      return
    endif
  endif

  let l:version_path = fnameescape(expand($RBENV_ROOT . '/version'))

  if !filereadable(l:version_path)
    return
  endif

  let l:file = vimproc#fopen(l:version_path)
  let l:version = s:Chomp(l:file.read())
  call l:file.close()

  let l:exec_path = s:RbenvMriPath(l:version)

  if !executable(l:exec_path)
    return
  endif

  let g:syntastic_ruby_mri_exec = l:exec_path
endfunction

call s:SyntasticDetectRbenvMri()


"" Fix the filetype of certain misidentified shell scripts
function! s:FixShellFt()
  if &filetype ==# '' || &filetype ==# 'conf'
    set filetype=sh
  endif
endfunction

"" Filetype corrections
if has('autocmd')
  au BufRead,BufNewFile *.h                         set filetype=c
  au BufRead,BufNewFile *.pch                       set filetype=c
  au BufRead,BufNewFile *.pxi                       set filetype=cython
  au BufRead,BufNewFile *.mod                       set filetype=dosini
  au BufRead,BufNewFile go.mod                      set filetype=gomod
  au BufRead,BufNewFile *.gradle                    set filetype=groovy
  au BufRead,BufNewFile *.hjs                       set filetype=handlebars
  au BufRead,BufNewFile jquery.*.js                 set filetype=javascript syntax=jquery
  au BufRead,BufNewFile *.jquery.js                 set filetype=javascript syntax=jquery
  au BufRead,BufNewFile *.vmx                       set filetype=jproperties
  au BufRead,BufNewFile apple-app-site-association  set filetype=json
  au BufRead,BufNewFile .spacemacs                  set filetype=lisp
  au BufRead,BufNewFile *.make                      set filetype=make
  au BufRead,BufNewFile *.mako                      set filetype=mako
  au BufRead,BufNewFile *.mm                        set filetype=objcpp
  au BufRead,BufNewFile *.pth                       set filetype=python
  au BufRead,BufNewFile *.rpy                       set filetype=python
  au BufRead,BufNewFile Brewfile*                   set filetype=ruby
  au BufRead,BufNewFile Fastfile*                   set filetype=ruby
  au BufRead,BufNewFile *.ru                        set filetype=ruby
  au BufRead,BufNewFile *.swift.gyb                 set filetype=swift
  au BufRead,BufNewFile *.socket                    set filetype=systemd
  au BufRead,BufNewFile *vimrc*                     set filetype=vim
  au BufRead,BufNewFile *.xmp                       set filetype=xml
  au BufRead,BufNewFile .bundle/config              set filetype=yaml
  au BufRead,BufNewFile *gemrc*                     set filetype=yaml
  au BufRead,BufNewFile Procfile                    set filetype=yaml
  au BufRead,BufNewFile *.yml                       set filetype=yaml
  au BufRead,BufNewFile *.zsh*                      set filetype=zsh

  au BufRead,BufNewFile *env      call s:FixShellFt()
  au BufRead,BufNewFile *.env.*   call s:FixShellFt()
  au BufRead,BufNewFile *profile  call s:FixShellFt()
  au BufRead,BufNewFile *rc       call s:FixShellFt()
  au BufRead,BufNewFile *rc_*     call s:FixShellFt()

  au FileType gitcommit setlocal nospell
  au FileType latex     setlocal nospell
  au FileType markdown  setlocal nospell
  au FileType plaintex  setlocal nospell
  au FileType text      setlocal nospell

  au BufReadPre *.nfo setlocal fileencodings=cp437,utf-8

  au FileType unite AirlineRefresh
endif

"" Light background? In my Vim?
set background=dark

"" Normally we want Slate, but if we're at a basic TTY, Solarized looks
"" great, even though it doesn't look like Solarized.
if exists('$TERM') && ($TERM =~# '\m\C^xterm' || $TERM ==# 'screen-256color')
  colorscheme slate
else
  colorscheme solarized
endif

"" 'term' looks solid with Solarized in a plain TTY, or with Slate in a
"" graphical terminal.
let g:airline_theme = 'term'

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
let g:syntastic_quiet_messages = { 'level': 'warnings' }

"" Hack to make Syntastic forget it has support for running javac
let g:loaded_syntastic_java_javac_checker = 1

"" Passive mode by default for rpmbuild specs
let g:syntastic_mode_map = {
\   'mode': 'active',
\   'active_filetypes': [],
\   'passive_filetypes': ['html', 'jinja.html', 'spec'],
\ }

"" Enable syntax highlighting
syntax on


""
"" Indent options - default is 2 spaces
""

function! Spaces(num)
  set expandtab
  set smarttab
  let &tabstop = a:num
  let &shiftwidth = a:num
  set softtabstop=0
endfunction

function! SpacesLocal(num)
  setlocal expandtab
  setlocal smarttab
  let &l:tabstop = a:num
  let &l:shiftwidth = a:num
  setlocal softtabstop=0
endfunction

function! Tabs(width)
  set noexpandtab
  set nosmarttab
  let &tabstop = a:width
  let &shiftwidth = a:width
  set softtabstop=0
endfunction

function! TabsLocal(width)
  setlocal noexpandtab
  setlocal nosmarttab
  let &l:tabstop = a:width
  let &l:shiftwidth = a:width
  setlocal softtabstop=0
endfunction

"" editorconfig
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

"" Initialize indentation
set autoindent
call Spaces(2)
filetype plugin indent on

if has('autocmd')
  ""
  "" Indents for specific filetypes
  ""
  au FileType apiblueprint,c,cmake,cpp,d,groovy,java,kotlin,ld,lua,objc,  call SpacesLocal(4)
  au FileType objcpp,openscad,perl,php,python,rust,scala,swift,typescript call SpacesLocal(4)

  au FileType go call TabsLocal(4)

  au FileType           bindzone,dosbatch,gitconfig,make,sudoers  call TabsLocal(8)
  au BufRead,BufNewFile *.entitlements,*.pbxproj,*.plist          call TabsLocal(8)
  au BufRead,BufNewFile postgresql.conf                           call TabsLocal(8)

  "" Column guides for specific filetypes
  au FileType c,cpp,rust          call SetColGuide(100)
  au FileType cs,java,objc,objcpp call SetColGuide(120)

  "" Comment strings for SQL
  au FileType sql let &l:commentstring = '--%s'

  "" Make commentary behave
  au BufRead,BufNewFile *       call FixCommentString()
  au FileType           dosini  call FixCommentString()
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

function! s:MapRightArrow(space)
  if a:space ==# ' '
    inoremap <C-l> <space>-><space>
  else
    inoremap <C-l> ->
  endif
endfunction

function! SetColGuide(width)
  let g:col_guide_width = a:width

  call ColGuide()
  call ColGuide()
endfunction

function! PromptSetColGuide()
  call inputsave()
  let l:width = substitute(input('Column guide width: '), '\m\C\D', '', 'g')
  call inputrestore()
  redraw

  if l:width !=# ''
    call SetColGuide(l:width)

    echom 'Column guide width set to ' . l:width . '!'
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

function! FixCommentString()
  if &l:commentstring ==# '# %s'
    let &l:commentstring = '#%s'
  elseif &l:commentstring ==# '// %s' || &l:commentstring ==# '/* %s */' || &l:commentstring ==# '/*%s*/'
    if &l:filetype !=# 'css'
      let &l:commentstring = '//%s'
    endif
  elseif &l:commentstring ==# '-- %s'
    let &l:commentstring = '--%s'
  elseif &l:commentstring ==# '" %s'
    let &l:commentstring = '"%s'
  elseif &l:commentstring ==# '; %s'
    let &l:commentstring = ';%s'
  endif

  let b:commentary_format = &l:commentstring
endfunction

"" This is completely superfluous, but it's how I'm doing it for the moment.
function! SendSplitTo(direction, retain_focus)
  if a:retain_focus
    let l:start_win_id = win_getid()
    if l:start_win_id ==# 0
      return 1
    endif
  endif

  if a:direction ==# 'below'
    belowright split
  elseif a:direction ==# 'right'
    belowright vsplit
  elseif a:direction ==# 'above'
    aboveleft split
  elseif a:direction ==# 'left'
    aboveleft vsplit
  else
    return 1
  endif

  if a:retain_focus
    let l:result = win_gotoid(l:start_win_id)
    if l:result !=# 1
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

function! s:GetSelectedText()
  normal! gv"xy
  let l:selection = getreg('x')
  normal! gv
  normal! :<C-u><cr>
  return l:selection
endfunction

function! s:GetBufferText()
  return join(getline(1, '$'), "\n")
endfunction

function! s:GetBufferPath()
  return expand('%:p')
endfunction

function! s:SendTextToSlack(text)
  if !executable('slackcat')
    echoerr 'Couldn''t find slackcat.'
    return 1
  endif

  call inputsave()
  let l:channel = s:Strip(input('Send to: '))
  call inputrestore()
  redraw

  if l:channel !=# ''
    call system('slackcat'
    \           . ' -c "' . l:channel . '"'
    \           . ' -n "' . fnameescape(expand('%:t')) . '"',
    \           a:text)
    echom 'Sent to (#|@)' . l:channel . '!'
  else
    echoerr 'Please enter a channel/user to send to.'
    return 1
  endif
endfunction

function! SendSelectionToSlack()
  call s:SendTextToSlack(s:GetSelectedText())
endfunction

function! SendBufferToSlack()
  call s:SendTextToSlack(s:GetBufferText())
endfunction

if g:dcp_os ==# 'Darwin'
  let g:pasteboard_cmd = '/usr/bin/pbcopy'
elseif executable('xsel')
  let g:pasteboard_cmd = 'xsel --clipboard --input'
elseif executable('clip.exe')
  let g:pasteboard_cmd = 'clip.exe'
endif

function! s:PasteboardCopyText(text)
  if !exists('g:pasteboard_cmd')
    echoerr 'Couldn''t find pbcopy, xsel, or clip.exe'
    return 1
  endif

  call system(g:pasteboard_cmd, a:text)
  echom 'Copied to pasteboard!'
endfunction

function! PasteboardCopySelection()
  call s:PasteboardCopyText(s:GetSelectedText())
endfunction

function! PasteboardCopyBuffer()
  let l:buffer_text = s:GetBufferText()
  if line('$') ==# 1
    "" Don't copy the newline from single line buffers
    let l:buffer_text = s:Chomp(l:buffer_text)
  endif
  call s:PasteboardCopyText(l:buffer_text)
endfunction

function! PasteboardCopyPath()
  call s:PasteboardCopyText(s:GetBufferPath())
endfunction

if g:dcp_os ==# 'Darwin'
  let g:system_open_cmd = '/usr/bin/open'
elseif executable('xdg-open')
  let g:system_open_cmd = 'xdg-open'
endif

function! SystemOpen()
  if !exists('g:system_open_cmd')
    echoerr 'Couldn''t find a system open command.'
    return 1
  endif

  let l:selection = s:GetSelectedText()

  call system(g:system_open_cmd . ' "' . l:selection . '"')

  echom 'Opened!'
endfunction


""
"" Keymaps
""

"" Ditch <esc>
inoremap <silent> jk <esc>

"" Column guide
nmap <silent> <leader>\ :<C-u>call ColGuide()<cr>
nmap <silent> <leader>s\ :<C-u>call PromptSetColGuide()<cr>

"" Indents
nmap <leader>2 :<C-u>call Spaces(2)<cr>
nmap <leader>4 :<C-u>call Spaces(4)<cr>
nmap <leader>g4 :<C-u>call Tabs(4)<cr>
nmap <leader>8 :<C-u>call Tabs(8)<cr>

"" Get current file's directory in command mode
cnoremap %% <C-r>=fnameescape(expand('%:h')).'/'<cr>

"" Re-indent the entire file
nnoremap <leader>I mmgg=G`m

"" Toggle paste mode
nmap <silent> <leader>xp :<C-u>set paste!<cr>

"" Send visual mode selection to slackcat
xmap <silent> <leader>xs :<C-u>call SendSelectionToSlack()<cr>
"" Send whole buffer to slackcat
nmap <silent> <leader>xs :<C-u>call SendBufferToSlack()<cr>

"" Send visual mode selection to pasteboard
xmap <silent> <leader>xy :<C-u>call PasteboardCopySelection()<cr>
"" Send whole buffer to pasteboard
nmap <silent> <leader>xy :<C-u>call PasteboardCopyBuffer()<cr>
"" Send file path to pasteboard
nmap <silent> <leader>xYP :<C-u>call PasteboardCopyPath()<cr>

"" Open visual mode selection with system utility
xmap <silent> <leader>xOO :<C-u>call SystemOpen()<cr>

"" Save a buffer as superuser while running Vim unprivileged
cnoremap w!! w !sudo tee -i % > /dev/null

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
nmap <silent> <leader>mc :<C-u>make clean<cr>
nmap <silent> <leader>md :<C-u>make debug<cr>
nmap <silent> <leader>mr :<C-u>make release<cr>
nmap <silent> <leader>mu :<C-u>make run<cr>

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
nmap <silent> <leader>wv :<C-u>belowright vsplit<cr>
nmap <silent> <leader>wV :<C-u>call SendSplitTo('right', 1)<cr>
nmap <silent> <leader>ws :<C-u>belowright split<cr>
nmap <silent> <leader>wS :<C-u>call SendSplitTo('below', 1)<cr>

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
if !s:VimprocUsable()
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

  au FileType c     call s:MapRightArrow('')
  au FileType cpp   call s:MapRightArrow('')
  au FileType objc  call s:MapRightArrow('')

  au FileType java  call s:MapRightArrow(' ')
  au FileType rust  call s:MapRightArrow(' ')
  au FileType swift call s:MapRightArrow(' ')
endif


""
"" Load vimrc.local if it exists
""

if filereadable($HOME . '/.vim/vimrc.local')
  source ~/.vim/vimrc.local
endif
