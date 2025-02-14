"" Get out of Vi mode, do some setup
set nocompatible
nnoremap Q <nop>

"" Comma leader
let mapleader = ','
let g:mapleader = ','

"" But totally also a space leader
map <space> <leader>

"" Backup, swap, and undo directories
if isdirectory(expand('~/.cache/vim/backup'))
  set backup
  set backupdir=~/.cache/vim/backup//
else
  set nobackup
endif
if isdirectory(expand('~/.cache/vim/swap'))
  set swapfile
  set directory=~/.cache/vim/swap//
else
  set noswapfile
endif
if isdirectory(expand('~/.cache/vim/undo'))
  set undofile
  set undodir=~/.cache/vim/undo//
else
  set noundofile
endif

"" String manipulation
function! s:Chomp(str)
  return substitute(a:str, '\m\C\n\+$', '', 'g')
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

"" Hopefully this makes Cygwin work
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
"" Filetype/highlighting/colorscheme options
""

"" Default shell dialect
let g:is_bash = 1

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
endif

"" Light background? In my Vim?
set background=dark

"" Most Vim installations should have slate, I hope
colorscheme slate

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

"" Initialize indentation
set autoindent
call Spaces(2)
filetype plugin indent on

"" Indents for specific filetypes
if has('autocmd')
  ""
  "" Indents for specific filetypes
  ""
  au FileType apiblueprint,c,cpp,d,groovy,java,kotlin,ld,lua,objc,  call SpacesLocal(4)
  au FileType objcpp,perl,php,python,rust,scala,swift,typescript    call SpacesLocal(4)

  au FileType go call TabsLocal(4)

  au FileType           bindzone,dosbatch,gitconfig,make,sudoers  call TabsLocal(8)
  au BufRead,BufNewFile *.entitlements,*.pbxproj,*.plist          call TabsLocal(8)
  au BufRead,BufNewFile postgresql.conf                           call TabsLocal(8)

  "" Column guides for specific filetypes
  au FileType c,cpp,rust          call SetColGuide(100)
  au FileType cs,java,objc,objcpp call SetColGuide(120)
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
cnoremap %% <C-r>=fnameescape(expand('%:h')).'/'<cr>

"" Re-indent the entire file
nnoremap <leader>I mmgg=G`m

"" Toggle paste mode
nmap <silent> <leader>xp :<C-u>set paste!<cr>

"" Send visual mode selection to pasteboard
xmap <silent> <leader>xy :<C-u>call PasteboardCopySelection()<cr>
"" Send whole buffer to pasteboard
nmap <silent> <leader>xy :<C-u>call PasteboardCopyBuffer()<cr>
"" Send file path to pasteboard
nmap <silent> <leader>xYP :<C-u>call PasteboardCopyPath()<cr>

"" Save a buffer as superuser while running Vim unprivileged
cnoremap w!! w !sudo tee -i % >/dev/null

"" Open .vimrc
nmap <leader>fed :<C-u>edit ~/.vimrc<cr>
"" Reload .vimrc
nmap <leader>feR :<C-u>source ~/.vimrc<cr>

"" <3 make
nmap <silent> <leader>m :<C-u>make<cr>
nmap <silent> <leader>mc :<C-u>make clean<cr>
nmap <silent> <leader>md :<C-u>make debug<cr>
nmap <silent> <leader>mr :<C-u>make release<cr>
nmap <silent> <leader>mu :<C-u>make run<cr>

"" Location list management
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
