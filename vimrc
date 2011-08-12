" Initialize pathogen
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" Set backup/tmp folders
set backup
set backupdir=~/.vim/backups
set directory=~/.vim/tmp

" Correct bad filetype detection
if has('autocmd')
  autocmd BufRead *.erb set filetype=eruby
  autocmd BufRead *.ru set filetype=ruby
  autocmd BufRead *.thrift set filetype=thrift
  autocmd BufRead *.zsh-theme set filetype=zsh
endif

" This be how we like our backspace
set bs=2

" Visible whitespace :)
set listchars=tab:>-,trail:.,nbsp:.

" Indentation
set autoindent
set softtabstop=2
set shiftwidth=2
set expandtab
filetype plugin indent on

" Java + PHP + Python fixes for indentation
" Silly goats, 4 space tabs are teh suck
function FourSpaceIndent()
  set softtabstop=4
  set shiftwidth=4
endfunction
if has('autocmd')
  autocmd filetype java call FourSpaceIndent()
  autocmd filetype php call FourSpaceIndent()
  autocmd filetype python call FourSpaceIndent()
endif

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

" Subtle highlighting for lines over 80 characters,
" when I get time I'mma script this into a toggle like Goldsrc.
highlight Eighty ctermbg=red ctermfg=white guibg=#FFC4BE guifg=white
function ToggleEighty()
  try
    call matchdelete(g:eighty)
  catch
    let g:eighty = matchadd('Eighty', '\%>80v.\+')
  endtry
endfunction
map <leader>l :call ToggleEighty()<cr>

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
imap <C-l> <Space>=><Space>

" Mappings for NERD Tree, removing search highlights,
" and visible whitespace.
map <leader>n :NERDTreeToggle<cr>
map <leader>h :set invhlsearch<cr>
map <leader>v :set list!<cr>

" I don't always write C/C++, but when I do...
" I have sexy Vim mappings for make
function MapMakeShortcuts()
  map <leader>m :make<cr>
  map <leader>co :copen<cr>
  map <leader>cn :cn<cr>
  map <leader>cp :cp<cr>
  map <leader>cf :cfirst<cr>
  map <leader>cl :clast<cr>
endfunction
if has('autocmd')
  autocmd filetype c call MapMakeShortcuts()
  autocmd filetype cpp call MapMakeShortcuts()
  autocmd filetype objc call MapMakeShortcuts()
endif
