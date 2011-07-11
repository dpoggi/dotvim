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
endif

" This be how we like our backspace
set bs=2

" Visible whitespace :)
set listchars=tab:>-,trail:.,extends:>

" Indentation
set autoindent
set softtabstop=2
set shiftwidth=2
set expandtab
filetype plugin indent on

" Python + Java fixes for indentation
" Silly goats, 4 space tabs are teh suck
if has('autocmd')
  autocmd filetype python set softtabstop=4
  autocmd filetype python set shiftwidth=4
  autocmd filetype java set softtabstop=4
  autocmd filetype java set shiftwidth=4
endif

" Line numbering and cursor on current line
set number
set numberwidth=5
set cursorline

" Syntax highlighting
syntax on
colorscheme molokai

" Search options - highlight while typing,
" highlight after search, smart case-insensitivity
set incsearch
set hlsearch
set ignorecase
set smartcase

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

" Random mappings that me likey
map <leader>z :set invhlsearch<cr>
map <leader>v :set list!<cr>
map <leader>n :NERDTreeToggle<cr>

" For Gvim - Inconsolata, no toolbar, xterm-256color, visual bell
set guifont=Inconsolata:h14.00
set guioptions-=T
set t_Co=256
set visualbell
