" Vim syntax file
" Language: GCODE
" Maintainer: Manuel Coenen <manuel.coenen@gmail.com>
" Last Change: 2018 April 12

" Quit when a (custom syntax file was already loaded
if exists("b:current_syntax")
    finish
endif

syntax case ignore

syntax match gcodeComment ";.*" contains=gcodeTodo
syntax keyword gcodeGCodes G0 G1 G2 G3 G4 G10 G11 G12 G20 G21 G26 G27 G28 G29 G30 G31 G32 G33 G38.2 G38.3 G53 G54 G59.3 G60 G80 G90 G91 G92
syntax keyword gcodeMCodes M0 M1 M2 M3 M4 M5 M6 M17 M18 M20 M21 M22 M23 M24 M25 M26 M27 M28 M29 M30 M31 M32 M33 M34 M36 M37 M38 M39 M42 M43 M48 M73 M75 M76 M77 M78 M80 M81 M82 M83 M84 M85 M92 M98 M99 M100 M104 M105 M106 M107 M108 M109 M110 M111 M112 M113 M114 M115 M116 M117 M118 M119 M120 M121 M122 M125 M126 M127 M128 M129 M135 M140 M141 M143 M144 M145 M149 M150 M155 M163 M164 M165 M190 M191 M200 M201 M203 M204 M205 M206 M207 M208 M209 M211 M218 M220 M221 M226 M240 M250 M260 M261 M280 M290 M291 M292 M300 M301 M302 M303 M304 M305 M307 M350 M351 M355 M360 M361 M362 M363 M364 M374 M375 M376 M380 M381 M400 M401 M402 M404 M405 M406 M407 M408 M410 M420 M421 M428 M450 M451 M452 M453 M500 M501 M502 M503 M540 M550 M551 M552 M553 M554 M555 M556 M557 M558 M559 M560 M561 M562 M563 M564 M566 M567 M568 M569 M570 M571 M572 M573 M574 M575 M577 M578 M579 M580 M581 M582 M583 M584 M585 M586 M587 M588 M589 M591 M592 M593 M600 M605 M665 M666 M667 M669 M670 M671 M672 M673 M701 M702 M703 M750 M751 M752 M753 M754 M755 M756 M851 M852 M900 M905 M906 M907 M908 M909 M910 M911 M912 M913 M914 M915 M916 M917 M918 M928 M929 M997 M998 M999
syntax match gcodeTool "\<T\d\+\>"

syntax match gcodeXAxis "\<[XY]-\?\d\+\>"
syntax match gcodeXAxis "\<[XY]-\?\.\d\+\>"
syntax match gcodeXAxis "\<[XY]-\?\d\+\."
syntax match gcodeXAxis "\<[XY]-\?\d\+\.\d\+\>"

syntax match gcodeZAxis "\<Z-\?\d\+\>"
syntax match gcodeZAxis "\<Z-\?\.\d\+\>"
syntax match gcodeZAxis "\<Z-\?\d\+\."
syntax match gcodeZAxis "\<Z-\?\d\+\.\d\+\>"

syntax match gcodeAAxis "\<[ABC]-\?\d\+\>"
syntax match gcodeAAxis "\<[ABC]-\?\.\d\+\>"
syntax match gcodeAAxis "\<[ABC]-\?\d\+\."
syntax match gcodeAAxis "\<[ABC]-\?\d\+\.\d\+\>"

syntax match gcodeEAxis "\<[E]-\?\d\+\>"
syntax match gcodeEAxis "\<[E]-\?\.\d\+\>"
syntax match gcodeEAxis "\<[E]-\?\d\+\."
syntax match gcodeEAxis "\<[E]-\?\d\+\.\d\+\>"

syntax match gcodeIAxis "\<[IJKR]-\?\d\+\>"
syntax match gcodeIAxis "\<[IJKR]-\?\.\d\+\>"
syntax match gcodeIAxis "\<[IJKR]-\?\d\+\."
syntax match gcodeIAxis "\<[IJKR]-\?\d\+\.\d\+\>"

syntax match gcodeRapid "\<G\(0\+\)\>"

syntax match gcodeFeed "\<F-\?\d\+\>"
syntax match gcodeFeed "\<F-\?\.\d\+\>"
syntax match gcodeFeed "\<F-\?\d\+\."
syntax match gcodeFeed "\<F-\?\d\+\.\d\+\>"

highlight def link gcodeComment Comment
highlight def link gcodeGCodes Keyword
highlight def link gcodeMCodes Keyword
highlight def link gcodeXAxis Operator
highlight def link gcodeYAxis Operator
highlight def link gcodeZAxis WarningMsg
highlight def link gcodeAAxis VimString
highlight def link gcodeEAxis Define

highlight def link gcodeRapid WarningMsg
highlight def link gcodeIAxis Identifier
highlight def link gcodeSpecials SpecialChar
highlight def link gcodeFeed SpecialChar
highlight def link gcodeTool Define

let b:current_syntax = "gcode"
