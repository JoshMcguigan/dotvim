highlight TestOk ctermfg=Green
highlight TestFail ctermfg=Red
syn keyword TestOk contained ok
syn keyword TestFail contained FAILED
syn match TestResult "test .*\.\.\. .*$" contains=TestOk,TestFail

setlocal norelativenumber
setlocal nonumber
