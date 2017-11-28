.macro _plainchr char
        .if (char < 256)
                .byte   <(.strat ("h@dbdlhh", char >> 5) << 4) ^ char
        .else
                .error  "plainchr: Character constant out of range"
        .endif
.endmacro

.macro  plainchr arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9

        .if     .blank ({arg1})
                .exitmacro
        .endif

        .if     .match ({arg1}, "")

                .repeat .strlen (arg1), i
                        _plainchr        {.strat (arg1, i)}
                .endrepeat

        .elseif .match (.left (1, {arg1}), 0)

                _plainchr        arg1

        .elseif .match (.left (1, {arg1}), 'a')

                _plainchr        arg1

        .else

                .error  "plainchr: invalid argument type"

        .endif

        plainchr arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9
.endmacro


.macro _revchr char
        .if (char < 256)
                .byte   <(.strat ("h@dbdlhh", char >> 5) << 4) ^ char | $80
        .else
                .error  "revchr: Character constant out of range"
        .endif
.endmacro

.macro  revchr arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9

        .if     .blank ({arg1})
                .exitmacro
        .endif

        .if     .match ({arg1}, "")

                .repeat .strlen (arg1), i
                        _revchr        {.strat (arg1, i)}
                .endrepeat

        .elseif .match (.left (1, {arg1}), 0)

                _revchr        arg1

        .elseif .match (.left (1, {arg1}), 'a')

                _revchr        arg1

        .else

                .error  "revchr: invalid argument type"

        .endif

        revchr arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9
.endmacro


