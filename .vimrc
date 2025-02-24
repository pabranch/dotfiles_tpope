" ~/.vimrc

" Section: Bootstrap

if v:version < 600 | finish | endif

if !get(v:, 'vim_did_enter', !has('vim_starting'))
  filetype off
  if has('win32') || has('nvim')
    setglobal runtimepath^=~/.vim runtimepath+=~/.vim/after
  endif
  if isdirectory(expand('~/Dropbox/Code/vim'))
    setglobal runtimepath^=~/Dropbox/Code/vim runtimepath+=~/Dropbox/Code/vim/after
  endif
  if has('packages')
    let &packpath = &runtimepath
  else
    let s:rtp = []
    for s:dir in split(&runtimepath, ',')
      if $VIMRUNTIME ==# s:dir
        call add(s:rtp, s:dir)
      elseif s:dir =~# 'after$'
        call extend(s:rtp, [s:dir[0:-6] . 'pack/*/start/*/after', s:dir])
      else
        call extend(s:rtp, [s:dir, s:dir . '/pack/*/start/*'])
      endif
    endfor
    let &runtimepath = join(s:rtp, ',')
    unlet! s:rtp s:dir
  endif
endif

if $VIM_BARE
  setglobal noloadplugins
  finish
endif

setglobal nocompatible
setglobal pastetoggle=<F2>

nmap <script><silent> <Space> :call getchar()<CR>
nmap <C-@> <Space>
filetype plugin indent on
" vint: -ProhibitAutocmdWithNoGroup
exe 'augroup my'
autocmd!

nmap <Space>r  :so ~/.vimrc<Bar>filetype detect<Bar>doau VimEnter -<CR>
autocmd VimEnter - if exists(':Dotenv') | exe 'Dotenv! ~/.env.local|Dotenv! ~/.env.'.substitute($DISPLAY, '\.\d\+$', '', '') | endif

" Section: Moving around, searching, patterns, and tags

setglobal startofline
setglobal cpoptions+=J
if has('vim_starting')
  setglobal noignorecase
endif
setglobal smartcase
setglobal incsearch
setglobal tags=./tags;
setglobal include=
setglobal path=.,,

autocmd FileType c,cpp           setlocal path+=/usr/include include&
autocmd FileType sh,zsh,csh,tcsh setlocal include=^\\s*\\%(\\.\\\|source\\)\\s
autocmd FileType dosbatch setlocal include=^call | let &l:sua = tr($PATHEXT, ';', ',')
autocmd FileType sh,zsh,csh,tcsh,dosbatch let &l:path =
      \ tr($PATH, has('win32') ? ';' : ':', ',') . ',.'
autocmd FileType lua
      \ if expand('%:p') =~# '/awesome/' |
      \   let &l:path = expand('~/.config/awesome') . ',/etc/xdg/awesome,/usr/share/awesome/lib,' . &l:path |
      \ endif
autocmd FileType ruby setlocal tags-=./tags;

" Section: Displaying text

if has('vim_starting') && exists('+breakindent')
  set breakindent showbreak=\ +
endif
setglobal display=lastline
setglobal scrolloff=1
setglobal sidescrolloff=5
setglobal lazyredraw
if (&termencoding ==# 'utf-8' || &encoding ==# 'utf-8') && v:version >= 700
  let &g:listchars = "tab:\u21e5\u00b7,trail:\u2423,extends:\u21c9,precedes:\u21c7,nbsp:\u00b7"
  let &g:fillchars = "vert:\u250b,fold:\u00b7"
else
  setglobal listchars=tab:>\ ,trail:-,extends:>,precedes:<
endif

" Section: Windows

setglobal laststatus=2
setglobal showtabline=2
if empty(&g:statusline)
  setglobal statusline=[%n]\ %<%.99f\ %y%h%w%m%r%=%-14.(%l,%c%V%)\ %P
endif
setglobal titlestring=%{v:progname}\ %{tolower(empty(v:servername)?'':'--servername\ '.v:servername.'\ ')}%{fnamemodify(getcwd(),':~')}%{exists('$SSH_TTY')?'\ <'.hostname().'>':''}
setglobal iconstring=%{tolower(empty(v:servername)?v:progname\ :\ v:servername)}%{exists('$SSH_TTY')?'@'.hostname():''}
if has('vim_starting')
  setglobal nohidden
endif

autocmd SourcePre */macros/less.vim setglobal laststatus=0 showtabline=0

nnoremap <C-J> <C-w>w
nnoremap <C-K> <C-w>W

" Section: GUI

setglobal printoptions=paper:letter
setglobal mousemodel=popup
if $TERM =~# '^screen'
  if exists('+ttymouse') && &ttymouse ==# ''
    setglobal ttymouse=xterm
  endif
endif

if !has('gui_running') && empty($DISPLAY) || !has('gui')
  setglobal mouse=
else
  setglobal mouse=nvi
endif
if exists('+macmeta')
  setglobal macmeta
endif
setglobal winaltkeys=no

function! s:font()
  if has('mac')
    return 'Monaco:h14'
  elseif has('win32')
    return 'Consolas:h14,Courier New:h14'
  else
    return 'Monospace 14'
  endif
endfunction

command! -bar -nargs=0 Bigger  :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)+1','')
command! -bar -nargs=0 Smaller :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)-1','')
nnoremap <M-->        :Smaller<CR>
nnoremap <M-=>        :Bigger<CR>

autocmd VimEnter *  if !has('gui_running') | set noicon background=dark | endif
autocmd GUIEnter * set background=light icon guioptions-=T guioptions-=m guioptions-=e guioptions-=r guioptions-=L
autocmd GUIEnter * silent! colorscheme vividchalk
autocmd GUIEnter * let &g:guifont = substitute(&g:guifont, '^$', s:font(), '')
autocmd FocusLost * let s:confirm = &confirm | setglobal noconfirm | silent! wall | let &confirm = s:confirm

" Section: Messages and info

setglobal confirm
setglobal showcmd
setglobal visualbell

" Section: Editing text and indent

setglobal backspace=2
setglobal complete-=i     " Searching includes can be slow
if v:version + has('patch541') >= 704
  setglobal formatoptions+=j
endif
silent! setglobal dictionary+=/usr/share/dict/words
setglobal infercase
setglobal showmatch
setglobal virtualedit=block

setglobal shiftround
setglobal smarttab
if has('vim_starting')
  set tabstop=8 softtabstop=0
  if exists('*shiftwidth')
    set shiftwidth=0 softtabstop=-1
  endif
  set autoindent
  set omnifunc=syntaxcomplete#Complete
  set completefunc=syntaxcomplete#Complete
endif

" Section: Folding and Comments

if has('vim_starting')
  if has('folding')
    set foldmethod=marker
    set foldopen+=jump
  endif
  set commentstring=#\ %s
endif

autocmd FileType c,cpp,cs,java,arduino setlocal commentstring=//\ %s
autocmd FileType desktop              setlocal commentstring=#\ %s
autocmd FileType sql                  setlocal commentstring=--\ %s
autocmd FileType xdefaults            setlocal commentstring=!%s
autocmd FileType git,gitcommit        setlocal foldmethod=syntax foldlevel=1

" Section: Maps

setglobal timeoutlen=1200
setglobal ttimeoutlen=50

if has('digraphs')
  digraph ,. 8230
  digraph cl 8984
endif

nnoremap Y  y$

inoremap <C-C> <Esc>`^

if exists(':xnoremap')
  xnoremap <Space> I<Space><Esc>gv
endif

nmap <script><silent><expr> <CR> &buftype ==# 'quickfix' ? "\r" : ":\025confirm " . (&buftype !=# 'terminal' ? (v:count ? 'write' : 'update') : &modified <Bar><Bar> exists('*jobwait') && jobwait([&channel], 0)[0] == -1 ? 'normal! i' : 'bdelete!') . "\r"

inoremap <M-o>      <C-O>o
inoremap <M-O>      <C-O>O
inoremap <M-i>      <Left>
inoremap <M-I>      <C-O>^
inoremap <M-A>      <C-O>$

nnoremap <silent> <C-w>z :wincmd z<Bar>cclose<Bar>lclose<CR>
nnoremap <silent> <C-w>Q :tabclose<CR>
nnoremap <silent> <C-w>, :if exists(':Wcd')<Bar>exe 'Wcd'<Bar>elseif exists(':Lcd')<Bar>exe 'Lcd'<Bar>elseif exists(':Glcd')<Bar>exe 'Glcd'<Bar>else<Bar>lcd %:h<Bar>endif<CR>
nmap cd <C-w>,

if exists('&termwinkey')
  tmap <script><expr> <SID>: (empty(&termwinkey) ? "\027" : eval('"\' . &termwinkey . '"')) . ':'
  tmap <script><expr> <C-\>: (empty(&termwinkey) ? "\027" : eval('"\' . &termwinkey . '"')) . ':'
elseif exists(':tmap')
  tmap <script> <SID>: <C-\><C-N>:
  tmap <script> <C-\>: <C-\><C-N>:
endif

function! s:MapEx(one, ...) abort
  let rhs = join(a:000, ' ')
  exe 'map  <script>' a:one '<C-\><C-N>:' . rhs . '<CR>'
  exe 'cmap <script>' a:one '<C-\><C-N>:' . rhs . '<CR>'
  exe 'imap <script>' a:one '<C-\><C-O>:' . rhs . '<CR>'
  if exists(':tmap')
    exe 'tmap <script>' a:one    '<SID>:' . rhs . '<CR>'
  endif
  return ''
endfunction

vnoremap <S-Del> "+x
vnoremap <C-Insert> "+y
map  <script> <S-Insert> "+gP
map! <script> <S-Insert> <C-R><C-R>+
if has('eval')
  runtime! autoload/paste.vim
  if exists('g:paste#paste_cmd')
    exe 'imap <script> <S-Insert> <C-G>u' . g:paste#paste_cmd['i']
    exe 'vmap <script> <S-Insert> ' . g:paste#paste_cmd['v']
  endif
endif
if exists(':tmap')
  tmap <script><expr> <S-Insert> tr(@+, "\n", "\r")
  tmap <script><silent> <C-PageUp>   <SID>:tabprevious<CR>
  tmap <script><silent> <C-PageDown> <SID>:tabnext<CR>
endif

if !has('mac')
  map  <M-x> <S-Del>
  map! <M-x> <S-Del>
  map  <M-c> <C-Insert>
  map! <M-c> <C-Insert>
  map  <M-v> <S-Insert>
  map! <M-v> <S-Insert>
endif

call s:MapEx('<C-F4>', 'confirm quit')
call s:MapEx('<F28>', 'confirm quit')
if !has('gui_running')
  silent! execute "set <F28>=" . ($TERM =~# 'rxvt' ? "\e[14^" : "\e[1;5S")
endif

call s:MapEx('<C-S-PageUp>', '-tabmove')
call s:MapEx('<C-S-PageDown>', '+tabmove')

let s:mod = has('mac') ? 'D' : 'M'
for s:i in range(1, 9)
  exe 'noremap  <' . s:mod . '-' . s:i . '> <C-\><C-N>' . s:i . 'gt'
  exe 'noremap! <' . s:mod . '-' . s:i . '> <C-\><C-N>' . s:i . 'gt'
  if exists(':tmap')
    exe 'tnoremap <' . s:mod . '-' . s:i . '> <C-w>:' . s:i . 'tabnext<CR>'
  endif
endfor

" Section: Reading and writing files

setglobal autoread
setglobal autowrite
if has('multi_byte')
  let &g:fileencodings = substitute(&fileencodings, 'latin1', 'cp1252', '')
endif
setglobal fileformats=unix,dos,mac
setglobal backupskip+=/private/tmp/*

if exists('##CursorHold')
  autocmd CursorHold,BufWritePost,BufReadPost,BufLeave *
        \ if !$VIMSWAP && isdirectory(expand('<amatch>:h')) | let &swapfile = &modified | endif
endif

if has('vim_starting') && exists('+undofile')
  set undofile
endif

if v:version >= 700
  setglobal viminfo=!,'20,<50,s10,h
endif
if !empty($SUDO_USER) && $USER !=# $SUDO_USER
  setglobal viminfo=
  setglobal directory-=~/tmp
  setglobal backupdir-=~/tmp
elseif exists('+undodir') && !has('nvim-0.5')
  if !empty($XDG_DATA_HOME)
    let s:data_home = substitute($XDG_DATA_HOME, '/$', '', '') . '/vim/'
  elseif has('win32')
    let s:data_home = expand('~/AppData/Local/vim/')
  else
    let s:data_home = expand('~/.local/share/vim/')
  endif
  let &undodir = s:data_home . 'undo//'
  let &directory = s:data_home . 'swap//'
  let &backupdir = s:data_home . 'backup//'
  if !isdirectory(&undodir) | call mkdir(&undodir, 'p') | endif
  if !isdirectory(&directory) | call mkdir(&directory, 'p') | endif
  if !isdirectory(&backupdir) | call mkdir(&backupdir, 'p') | endif
endif

" Section: Command line editing

setglobal history=1000
setglobal wildmenu
setglobal wildmode=full
setglobal wildignore+=tags,.*.un~,*.pyc

cnoremap <C-O>      <Up>
cnoremap <C-R><C-L> <C-R>=substitute(getline('.'), '^\s*', '', '')<CR>

" Section: External commands

setglobal grepformat=%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f\ \ %l%m
if executable('ag')
  setglobal grepprg=ag\ -s\ --vimgrep
elseif has('unix')
  setglobal grepprg=grep\ -rn\ $*\ /dev/null
endif

autocmd BufReadPost *
      \ if getline(1) =~# '^#!' |
      \   let b:dispatch =
      \       matchstr(getline(1), '#!\%(/usr/bin/env \+\)\=\zs.*') . ' %:S' |
      \   let b:start = '-wait=always ' . b:dispatch |
      \ endif
autocmd BufReadPost ~/.xbindkeys* let b:dispatch = '-dir=~ pkill -f "xbindkeys -X $DISPLAY"; xbindkeys -X $DISPLAY'
autocmd BufReadPost ~/.Xkbmap let b:dispatch = 'setxkbmap `cat %`'
autocmd BufReadPost ~/.Xresources let b:dispatch = 'xrdb ' . $XRDBOPT . ' -override %'
autocmd BufReadPost /etc/init.d/* let b:dispatch = 'tpope service %:t restart'
autocmd BufReadPost /etc/init/*.conf let b:dispatch = 'tpope service %:t:r restart'
autocmd BufReadPost /etc/udev/* let b:dispatch = 'tpope service udev restart'
autocmd BufReadPost ~/.config/awesome/*
      \ let b:current_compiler = 'awesome' |
      \ setlocal makeprg=awesome\ -k
      \   efm=%-G%.\ Configuration\ file\ syntax\ OK.,%f:%l:%m,%+G%.%#
autocmd FileType eruby,html,haml command! -buffer -range=% Haml
      \ exe '<line1>,<line2>!html2haml --erb --html-attributes'
      \ (indent(<line1>) ? '|sed -e "s/^/'.matchstr(getline(<line1>), '^\s*').'/"' : '') | setf haml
autocmd FileType html let b:dispatch = ':Browse'
autocmd BufReadPost ~/public_html/**,~/.public_html/** let b:url =
      \ 'http://'.hostname().'/~tpope'.expand('%:p:~:s?\~/[^/]*??')
autocmd FileType tmux let b:dispatch = 'tmux source %:p:S'
autocmd FileType cucumber call extend(b:, {'dispatch': 'cucumber %:S'}, 'keep')
autocmd FileType haskell let b:dispatch = 'ghc %:S'
autocmd FileType java let b:dispatch = 'javac %:S'
autocmd FileType perl let b:dispatch = 'perl -Wc %:S'
autocmd FileType ruby
      \ if !exists('b:start') |
      \   let b:start = executable('pry') ? 'pry -r %:p:S' : 'irb -r %:p:S' |
      \ endif |
      \ if expand('%') =~# '_test\.rb$' |
      \   let b:dispatch = 'testrb %' |
      \ elseif expand('%') =~# '_spec\.rb$' |
      \   let b:dispatch = get(b:, 'dispatch', 'rspec %:s/$/\=exists("l#") ? ":".l# : ""/') |
      \ elseif join(getline(max([line('$')-8,1]), '$'), "\n") =~# '\$0\>' |
      \   let b:dispatch = 'ruby %' |
      \ elseif !exists('b:dispatch') |
      \   let b:dispatch = 'ruby -wc %' |
      \ endif
autocmd FileType tex let b:dispatch = 'latex -interaction=nonstopmode %'

function! s:open(...) abort
  if has('win32')
    let cmd = 'start'
  elseif executable('xdg-open')
    let cmd = 'xdg-open'
  else
    let cmd = 'open'
  endif
  if !empty(v:servername) && !has('win32')
    let cmd = 'env VISUAL="vim --servername '.v:servername.'" '.cmd
  endif
  let args = a:0 ? copy(a:000) : [get(b:, 'url', '%:p')]
  if type(args[0]) == type(function('tr'))
    let args[0] = call(args[0], [{}], {})
  endif
  call map(args, 'shellescape(expand(v:val))')
  return 'echo ' . string(system(cmd . ' ' . join(args, ' '))[0:-2])
endfunction
command! -nargs=* -complete=file O :exe s:open(<f-args>)

" Section: Filetype settings

autocmd FileType * setlocal nolinebreak
autocmd FileType sh,zsh,csh,tcsh,perl,python,ruby,tcl setlocal fo-=t |
      \ if !&tw | setlocal tw=78 | endif
autocmd FileType help setlocal ai formatoptions+=2n formatoptions-=ro
autocmd FileType markdown,text setlocal linebreak keywordprg=dict
autocmd FileType markdown if !&tw && expand('%:e') =~# '\<\%(md\|markdown\)\>' | setlocal tw=78 | endif
autocmd FileType tex setlocal formatoptions+=l
autocmd FileType vim setlocal keywordprg=:help |
      \ if &foldmethod !=# 'diff' | setlocal foldmethod=expr foldlevel=1 | endif |
      \ setlocal foldexpr=getline(v:lnum)=~'^\"\ Section:'?'>1':'='

autocmd BufNewFile,BufRead *named.conf* setlocal ft=named
autocmd BufWritePre,FileWritePre /etc/* if &ft == 'dns' |
      \ exe "normal msHmt" |
      \ exe "gl/^\\s*\\d\\+\\s*;\\s*Serial$/normal ^\<C-A>" |
      \ exe "normal g`tztg`s" |
      \ endif

let g:sh_fold_enabled = has('folding')
let g:is_posix = 1
let g:go_fmt_autosave = 0
let g:sql_type_default = 'pgsql'

" Section: Highlighting

if has('spell')
  if has('vim_starting')
    set spelllang=en_us
    set spellfile=~/.vim/spell/en.utf-8.add
    if &rtp =~# 'Dropbox.Code.vim'
      set spellfile^=~/Dropbox/Code/vim/spell/en.utf-8.add
    endif
  endif
  let g:spellfile_URL = 'http://ftp.vim.org/vim/runtime/spell'
  autocmd FileType gitcommit setlocal spell
  autocmd FileType help if &buftype ==# 'help' | setlocal nospell | endif
endif

if $TERM !~? 'linux' && &t_Co == 8
  setglobal t_Co=16
endif

if (&t_Co > 2 || has('gui_running')) && has('syntax')
  if !exists('syntax_on') && !exists('syntax_manual')
    exe 'augroup END'
    syntax on
    exe 'augroup my'
  endif
  if has('vim_starting')
    set list
    if !exists('g:colors_name')
      colorscheme tpope
    endif
  endif

  autocmd Syntax sh   syn sync minlines=500
  autocmd Syntax css  syn sync minlines=50
endif

" Section: Plugin settings

imap <C-L>          <Plug>CapsLockToggle
imap <C-G>c         <Plug>CapsLockToggle

let g:omni_sql_no_default_maps = 1
let g:sh_noisk = 1
let g:markdown_fenced_languages = ['ruby', 'html', 'javascript', 'css', 'bash=sh', 'sh']
let g:liquid_highlight_types = g:markdown_fenced_languages + ['jinja=liquid', 'html+erb=eruby.html', 'html+jinja=liquid.html']

let g:CSApprox_verbose_level = 0
let g:NERDTreeHijackNetrw = 0
let g:netrw_dirhistmax = 0
let g:ragtag_global_maps = 1
let b:surround_{char2nr('e')} = "\r\n}"
let g:surround_{char2nr('-')} = "<% \r %>"
let g:surround_{char2nr('=')} = "<%= \r %>"
let g:surround_{char2nr('8')} = "/* \r */"
let g:surround_{char2nr('s')} = " \r"
let g:surround_{char2nr('^')} = "/^\r$/"
let g:surround_indent = 1

" Section: Misc

setglobal sessionoptions-=buffers sessionoptions-=curdir sessionoptions+=sesdir,globals
autocmd VimEnter * nested
      \ if !argc() && empty(v:this_session) && filereadable('Session.vim') && !&modified |
      \   source Session.vim |
      \ endif

" Section: Fin

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif

exe 'augroup END'

" vim:set et sw=2 foldmethod=expr
