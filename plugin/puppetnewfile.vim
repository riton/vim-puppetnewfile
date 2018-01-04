" puppetnewfile.vim - Helper for day2day puppet module development
" Maintainer:         Remi Ferrand (riton)
" Version:            1.0

if exists('g:loaded_puppetnewfile') || &cp
  finish
endif
let g:loaded_puppetnewfile = 1

if !exists('g:puppetnewfile_templates')
  let g:puppetnewfile_templates = resolve(expand('<sfile>:p:h').'/../templates')
endif

if !exists('g:puppetnewfile_auto_create_dirs')
  let g:puppetnewfile_auto_create_dirs = 1
endif

if !exists('g:puppetnewfile_prune_dir_prefix')
  let g:puppetnewfile_prune_dir_prefix = [ 'module-', 'puppet-' ]
endif

"
" Helpers
"
function! s:getCurrentModuleNameFromWorkdir()
  let cwd = getcwd()
  let dirname = split(cwd, "/")[-1]
  let module_name = split(dirname, ".git")[0]
  
  for pattern_to_prune in g:puppetnewfile_prune_dir_prefix
    let module_name = substitute(l:module_name, "^".pattern_to_prune, "", "")
  endfor

  return l:module_name
endfunc

function! s:readTemplate(tplName) abort
  let tplFilePath = printf("%s/%s", g:puppetnewfile_templates, a:tplName)

  if ! filereadable(tplFilePath)
    throw "Template file ".l:tplFilePath." does not exist"
  endif

  return readfile(l:tplFilePath)
endfunc

function! s:substituteClassName(str, className)
  return substitute(a:str, "__RESOURCENAME__", a:className, "g")
endfunc

function! s:substituteModuleName(str, moduleName)
  return substitute(a:str, "__MODULENAME__", a:moduleName, "g")
endfunc

function! s:writeBufferFromTemplate(templateName, moduleName, resourceName) abort
  let tplLines = s:readTemplate(a:templateName)

  let lineno = 1
  for line in l:tplLines

    let line = s:substituteClassName(line, a:resourceName)
    let line = s:substituteModuleName(line, a:moduleName)

    call setline(lineno, line)

    let lineno = l:lineno + 1
    if l:lineno > len(l:tplLines)
      break
    endif
  endfor
endfunc

function! s:resourceNameFromComponents(moduleName, components)
  if len(a:components) == 1 && a:components[0] == 'init'
    let className = a:moduleName
  else
    let className = join([a:moduleName] + a:components, "::")
  endif
  return l:className
endfunc

function! s:createNewClassFile(moduleName, components)
  let className = s:resourceNameFromComponents(a:moduleName, a:components)
  call s:writeBufferFromTemplate('class.pp', a:moduleName, l:className)
endfunc

function! s:createNewFunctionFile(moduleName, components)
  let funcName = s:resourceNameFromComponents(a:moduleName, a:components)
  call s:writeBufferFromTemplate('function.pp', a:moduleName, l:funcName)
endfunc
 
"
" Public function
"
function! puppetnewfile#createNewPuppetFile() abort
  let fileNameNoExtension = expand("%:r")
  let filePathComponents = split(l:fileNameNoExtension, "/")
  let fileDirectory = join(filePathComponents[0:len(filePathComponents)-2], "/")
  let resourceNameComponents = filePathComponents[1:]
  let moduleName = s:getCurrentModuleNameFromWorkdir()

  " Create directories if requested
  if ! isdirectory(l:fileDirectory)
    if g:puppetnewfile_auto_create_dirs == 1
      call mkdir(l:fileDirectory, 'p')
    endif
  endif

  if filePathComponents[0] == "manifests"
    call s:createNewClassFile(l:moduleName, l:resourceNameComponents)
  elseif filePathComponents[0] == "functions"
    call s:createNewFunctionFile(l:moduleName, l:resourceNameComponents)
  endif

endfunc

autocmd BufNewFile *.pp :call puppetnewfile#createNewPuppetFile()
