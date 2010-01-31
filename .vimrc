set background=light

"if &columns < 100
"	set columns=100
"end
"if &lines < 35
"	set lines=35
"end

" basics
set nocompatible        " use vim defaults
set mouse=a             " make sure mouse is used in all cases.
set fileformat=unix     " force unix-style line breaks
set tabpagemax=30       " maximum number of tabs
" tabs and indenting
"set expandtab           " insert spaces instead of tab chars
set tabstop=8          " a n-space tab width
set shiftwidth=8        " allows the use of < and > for VISUAL indenting
set softtabstop=0       " counts n spaces when DELETE or BCKSPCE is used
set fileencoding=utf-8

if has("autocmd")
  filetype plugin indent on " indents behaviour depends on type
else
  set autoindent        " auto indents next new line
endif
  
" searching
set nohlsearch          " dont highlight all search results
set incsearch           " increment search
set ignorecase          " case-insensitive search
set smartcase           " upper-case sensitive search

" formatting
set backspace=2         " full backspacing capabilities
set history=100         " 100 lines of command line history
set cmdheight=1         " command line height
set laststatus=1        " occasions to show status line, 2=always.
set ruler               " ruler display in status line
set showmode            " show mode at bottom of screen
set showcmd             " display some infos (in visual)

set number              " show line numbers
set nobackup            " disable backup files (filename~)
set showmatch           " show matching brackets (),{},[]
set ww=<,>,[,]          " whichwrap -- left/right keys can traverse up/down

" syntax highlighting
syntax on               " enable syntax highlighting

" set templatepath .vim/plugin/templates.vim 
let g:templatePath = "/home/ben/.vim/templates"

" highlight redundant whitespaces and tabs.
"highlight RedundantSpaces ctermbg=red guibg=red
"match RedundantSpaces /\s\+$\| \+\ze\t\|\t/

" gvim settings
"set guioptions-=T" Disable toolbar icons
set guifont=Dejavu\ Sans\ Mono\ 10 " backslash spaces
"set lines=30
"set columns=95

" F5 toggles spell checking
:map <F5> :setlocal spell! spelllang=de_de<cr>
:imap <F5> <C-o>:setlocal spell! spelllang=de_de<cr>

" common save shortcuts ~ dont work with vim :(
"inoremap <C-s> <esc>:w<cr>a
"nnoremap <C-s> :w<cr>

" Mapping for Copy/Paste
map <C-x> "+x
map <C-y> "+y
map <C-p> "+p
" enter ex mode with semi-colon
nnoremap ; :
vnoremap ; :

" strip ^M linebreaks from dos formatted files
map M :%s/$//g

" mutt rules
autocmd BufRead /tmp/mutt-* set tw=72 spell

" disable line numbers when using vim als manpager
autocmd FileType man set nonumber
