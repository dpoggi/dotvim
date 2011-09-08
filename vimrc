" HAHAHA NO ONE LOVES YOU VI
set nocompatible
if has('mouse')
  set mouse=a
endif

" Initialize pathogen
call pathogen#infect()
call pathogen#helptags()

" Set backup/tmp folders
set backup
set backupdir=~/.vim/backups
set directory=~/.vim/tmp

" Correct bad filetype detection
if has('autocmd')
  autocmd BufRead,BufNewFile *.erb set filetype=eruby
  autocmd BufRead,BufNewFile *.ru set filetype=ruby
  autocmd BufRead,BufNewFile *.thrift set filetype=thrift
  autocmd BufRead,BufNewFile *.zsh-theme set filetype=zsh
  autocmd BufRead,BufNewFile jquery.*.js set filetype=javascript syntax=jquery
  autocmd BufRead,BufNewFile *.jquery.js set filetype=javascript syntax=jquery
endif

" This be how we like our backspace
set bs=2

" Visible whitespace :)
set listchars=tab:>-,trail:.,nbsp:.

" Indentation
set autoindent
set expandtab
set tabstop=8
filetype plugin indent on

function TwoSpaceIndent()
  set softtabstop=2
  set shiftwidth=2
endfunction

function FourSpaceIndent()
  set softtabstop=4
  set shiftwidth=4
endfunction

function TabIndent()
  set softtabstop=0
  set shiftwidth=8
endfunction

if has('autocmd')
  autocmd FileType * call TwoSpaceIndent()
  autocmd FileType java call FourSpaceIndent()
  autocmd FileType php call FourSpaceIndent()
  autocmd FileType python call FourSpaceIndent()
endif

call TwoSpaceIndent()

" Line numbering and cursor on current line,
" ruler at the bottom.
set number
set numberwidth=5
set cursorline
set ruler

" Syntax highlighting
syntax on
let g:molokai_original=1
colorscheme molokai

" Status line
set laststatus=2
set statusline=[%n]
set statusline+=\ %<%.99f
set statusline+=\ %h%w%m%r%y
set statusline+=%{exists('g:loaded_fugitive')?fugitive#statusline():''}
set statusline+=%{exists('g:loaded_rvm')?rvm#statusline():''}
set statusline+=%=%-16(\ %l,%c-%v\ %)%P

" Toggle highlight lines over 80 characters
function ToggleEighty()
  try
    call matchdelete(g:eighty)
  catch
    let g:eighty = matchadd('Error', '\%>80v.\+')
  endtry
endfunction
map <leader>l :call ToggleEighty()<cr>

function GregMotherfuckingKlein()
  highlight ColorColumn ctermbg=darkgrey guibg=darkgrey
  set colorcolumn=80
endfunction
map <leader>g :call GregMotherfuckingKlein()<cr>

" Search options - highlight while typing,
" highlight after search, smart case-insensitivity
set incsearch
set hlsearch
set ignorecase
set smartcase

" Le NERD Tree
let NERDTreeIgnore=['\.pyc$', '\.pyo$', '\.o$', '\.obj$']

" Buffer mappings
map <leader>bn :bn<cr>
map <leader>bp :bp<cr>
map <leader>bc :bd<cr>

" Tab mappings
map <leader>tt :tabnew<cr>
map <leader>tc :tabclose<cr>
map <leader>tn :tabnext<cr>
map <leader>tp :tabprevious<cr>

" Le hashrocket!!!
function MapRubyHashrocket()
  imap <C-l> <Space>=><Space>
endfunction
function MapCStructOperator()
  imap <C-l> ->
endfunction
if has('autocmd')
  autocmd FileType * call MapRubyHashrocket()
  autocmd FileType c call MapCStructOperator()
  autocmd FileType cpp call MapCStructOperator()
  autocmd FileType objc call MapCStructOperator()
endif
call MapRubyHashrocket()

" Mappings for NERD Tree, removing search highlights,
" visible whitespace, and Command-T.
map <leader>n :NERDTreeToggle<cr>
map <leader>h :set invhlsearch<cr>
map <leader>v :set list!<cr>
map <leader>u :set number!<cr>
map <leader>tf :CommandTFlush<cr>

" I don't always write C/C++, but when I do...
" I have sexy Vim mappings for make
function MapCShortcuts()
  map <leader>m :make<cr>
  map <leader>co :copen<cr>
  map <leader>cn :cn<cr>
  map <leader>cp :cp<cr>
  map <leader>cf :cfirst<cr>
  map <leader>cl :clast<cr>
endfunction
if has('autocmd')
  autocmd FileType c call MapCShortcuts()
  autocmd FileType cpp call MapCShortcuts()
  autocmd FileType objc call MapCShortcuts()
endif
