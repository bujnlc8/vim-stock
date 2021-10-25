function! stock#random()
    if has('python')
python << EOF
import random
res = random.random()
EOF
    elseif has('python3')
python3 << EOF
import json
import random
res = random.random()
EOF
    endif
    if has('python')
        return pyeval('res')
    elseif has('python3')
        return py3eval('res')
    endif
endfunction
