""
"" Get out of Vi mode, load Pathogen, do some setup
""

set nocompatible
let g:pathogen_disabled = []

"" Local pre-load hook for plugin disables/configuration
if filereadable($HOME . '/.vim/plugins.local')
  source ~/.vim/plugins.local
endif

"" Because submodules will inevitably overstay their welcome :shrug:
call extend(g:pathogen_disabled,
\   ['clojure', 'cocoa', 'funcoo', 'haml', 'ios', 'mako',
\    'systemverilog', 'ts'])

"" Load pathogen
execute pathogen#infect()
call pathogen#helptags()

"" Comma leader
let mapleader = ','

"" Enable mouse support, if possible
if has('mouse')
  set mouse=a
  set ttymouse=xterm2
endif

"" Backup, swap, and undo directories
set backup
set backupdir=~/.vim/backups//
set swapfile
set directory=~/.vim/swap//
set undofile
set undodir=~/.vim/undo//

"" Wildcards for :e / Command-T to ignore
set wildignore+=*.o,*.obj,pkg/**,*.exe,*.app,*.ipa,*.dSYM*
set wildignore+=tmp/**,build/**,dist/**,target/**
set wildignore+=.bundle/**,Pods/**,Carthage/**
set wildignore+=node_modules/**,bower_components/**,vendor/src/**

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

"" Annoyances
set timeoutlen=300
imap jk <esc>


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
  au BufRead,BufNewFile Procfile     set filetype=yaml
  au BufRead,BufNewFile *.ru         set filetype=ruby
  au BufRead,BufNewFile *.thrift     set filetype=thrift

  au BufRead,BufNewFile *env      call s:FixShellFt()
  au BufRead,BufNewFile *.env.*   call s:FixShellFt()
  au BufRead,BufNewFile *profile  call s:FixShellFt()
  au BufRead,BufNewFile *vimrc*   set filetype=vim
  au BufRead,BufNewFile *rc       call s:FixShellFt()
  au BufRead,BufNewFile *.zsh*    set filetype=zsh

  au FileType gitcommit setlocal spell
  au FileType latex     setlocal spell
  au FileType markdown  setlocal spell
  au FileType plaintex  setlocal spell
  au FileType text      setlocal spell
endif

"" Normally we want zenburn, but if we're at a basic TTY, solarized looks
"" great, even though it doesn't look like solarized.
if $TERM =~ '^linux' || $TERM =~ '^screen$'
  set background=dark
  colorscheme solarized
else
  set background=
  colorscheme zenburn
endif

"" Syntastic options
let g:syntastic_check_on_open = 1
let g:syntastic_quiet_messages = {'level': 'warnings'}

"" Enable syntax highlighting
syntax on


""
"" Indent options/binds - default is 2 spaces
""

function! Tabs(size)
  set noexpandtab
  let &tabstop = a:size
  let &softtabstop = 0
  let &shiftwidth = a:size
endfunction
map <leader>0 :call Tabs(8)<cr>
map <leader>g0 :call Tabs(4)<cr>

function! Spaces(num)
  set expandtab
  let &tabstop = a:num
  let &softtabstop = 0
  let &shiftwidth = a:num
endfunction
map <leader>2 :call Spaces(2)<cr>
map <leader>4 :call Spaces(4)<cr>

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
"" Keybind functions
""

function! s:MapHashrocket()
  imap <C-l> <space>=><space>
endfunction

function! s:MapLeftArrow()
  imap <C-l> <-
endfunction

function! s:MapRightArrow(spaces)
  if a:spaces == 0
    imap <C-l> ->
  elseif a:spaces == 1
    imap <C-l> <space>->
  elseif a:spaces > 1
    imap <C-l> <space>-><space>
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
      let l:width = 80
    endif
    let g:col_guide = matchadd('Error', '\%>' . l:width . 'v.\+')
    return 1
  endtry
endfunction


""
"" Keybinds
""

"" Column guide
map <leader>\ :call ColGuide()<cr>
map <leader>s\ :call SetColGuide()<cr>

"" Get current file's directory in command mode
cnoremap %% <C-R>=expand('%:h').'/'<cr>

"" Re-indent the entire file
map <leader>I mmgg=G`m

"" Save a buffer as superuser while running Vim unprivileged
cnoremap w!! w !sudo tee -i % >/dev/null

"" Reload .vimrc
map <leader>Rl :source ~/.vimrc<cr>

"" <3 make
map <leader>m :make<cr>
map <leader>mc :make clean<cr>

"" Location list management
map <leader>co :copen<cr>
map <leader>cc :cclose<cr>
map <leader>cn :cn<cr>
map <leader>cp :cp<cr>
map <leader>cf :cfirst<cr>
map <leader>cl :clast<cr>

"" Show/hide search highlights + listchars
map <leader>/ :set invhlsearch<cr>
map <leader><space> :set list!<cr>

"" Previous/next buffer
map <leader>h :bp<cr>
map <leader>l :bn<cr>
"" Flip-flop buffers
nnoremap <leader><leader> <c-^>

"" Tab management
map <leader>tc :tabnew<cr>
map <leader>tp :tabprev<cr>
map <leader>tn :tabnext<cr>
map <leader>td :tabclose<cr>

"" Command-T
map <leader>f :CommandTFlush<cr>\|:CommandT<cr>
map <leader>F :CommandTFlush<cr>\|:CommandT %%<cr>

"" Filetype-specific keybinds
if has('autocmd')
  au FileType php         call s:MapHashrocket()
  au FileType ruby        call s:MapHashrocket()
  au FileType eruby       call s:MapHashrocket()
  au FileType haml        call s:MapHashrocket()
  au FileType puppet      call s:MapHashrocket()
  au FileType scala       call s:MapHashrocket()
  au FileType javascript  call s:MapHashrocket()

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
