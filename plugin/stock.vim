scriptencoding utf-8

if !exists('g:stock_width_split_num')
    let g:stock_width_split_num = 5
endif

if !exists('g:stock_height_split_num')
    let g:stock_height_split_num = 4
endif

let s:has_popup = has('patch-8.2.0286')

let s:curl = "curl -s 'https://22.push2.eastmoney.com/api/qt/clist/get?cb=j&pn=1&pz=100&po=1&np=1&ut=bd1d9ddb04089700cf9c27f6f7426281&fltt=2&invt=2&fid=f3&fs=m:90+t:2+f:\u002150&fields=f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f12,f13,f14,f15,f16,f17,f18,f20,f21,f23,f24,f25,f26,f22,f33,f11,f62,f128,f136,f115,f152,f124,f107,f104,f105,f140,f141,f207,f208,f209,f222&_=1635173473556'
            \ -H 'Connection: keep-alive'
            \ -H 'Cache-Control: max-age=0'
            \ -H 'sec-ch-ua: \"Google Chrome\";v=\"95\", \"Chromium\";v=\"95\", \";Not A Brand\";v=\"99\"'
            \ -H 'sec-ch-ua-mobile: ?0'
            \ -H 'sec-ch-ua-platform: \"macOS\"'
            \ -H 'DNT: 1'
            \ -H 'Upgrade-Insecure-Requests: 1'
            \ -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.54 Safari/537.36'
            \ -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'
            \ -H 'Sec-Fetch-Site: none'
            \ -H 'Sec-Fetch-Mode: navigate'
            \ -H 'Sec-Fetch-User: ?1'
            \ -H 'Sec-Fetch-Dest: document' \
            \ -H 'Accept-Language: zh,en-US;q=0.9,en;q=0.8'
            \ -H 'Cookie: qgqp_b_id=322a07098ce1b5fc252bd11e0d5e47a3; st_si=14659486845284; st_asi=delete; EMFUND1=null; EMFUND2=null; EMFUND3=null; EMFUND4=null; EMFUND5=null; EMFUND6=null; EMFUND7=null; EMFUND8=null; EMFUND0=null; EMFUND9=10-25 15:54:59@#$%u540C%u6CF0%u4F18%u9009%u914D%u7F6E3%u4E2A%u6708%u6301%u6709%u6DF7%u5408%28FOF%29C@%23%24013850; st_pvi=43096458836794; st_sp=2021-10-25%2014%3A14%3A39; st_inirUrl=https%3A%2F%2Fwww.google.com%2F; st_sn=15; st_psi=20211025225113945-113200313002-5195901490'"



function! s:get_industry()
    let up_num = 0
    let down_num = 0
    let industry = {3:[], 2:[], 1:[], 0:[]}
    try
        let res = system(s:curl)[2:-3]
        let res = json_decode(res)['data']['diff']
    catch
        echoerr '获取数据失败'
        return {'total_num': 0, 'industry':industry, 'up_num':0, 'down_num':0}
    endtry
    let max_up = {'up_down': 0}
    let max_down = {'up_down': 0}
    for item in res
        if item['f3'] >= 0
            let up_num += 1
            if item['f3'] > max_up['up_down']
                let max_up = {'name': item['f14'], 'up_down': item['f3']}
            endif
        else
            let down_num += 1
            if item['f3'] < max_down['up_down']
                let max_down = {'name': item['f14'], 'up_down': item['f3']}
            endif
        endif
        if abs(item['f3']) >= 2
            call add(industry[3], {'name': item['f14'], 'up_down': item['f3'], 'stock': item['f128'], 'stock_up_down': item['f136']})
        elseif abs(item['f3']) < 2 && abs(item['f3']) >= 1
            call add(industry[2], {'name': item['f14'], 'up_down': item['f3'], 'stock': item['f128'], 'stock_up_down': item['f136']})
        elseif abs(item['f3']) < 1 && abs(item['f3']) >= 0.6
            call add(industry[2], {'name': item['f14'], 'up_down': item['f3'], 'stock': item['f128'], 'stock_up_down': item['f136']})
        else
            call add(industry[1], {'name': item['f14'], 'up_down': item['f3'], 'stock': item['f128'], 'stock_up_down': item['f136']})
        endif
    endfor
    return {'total_num': up_num + down_num, 'industry':industry, 'up_num': up_num, 'down_num': down_num, 'max_up': max_up, 'max_down': max_down}
endfunction

let s:green = ['#55bb8a', '#3c9566', '#207f4c', '#43b244', '#8cc269', '#20a162', '#41ae3c', '#5bae23', '#5dbe8a', '#579572', '#2c9678']

let s:red = ['#ef498b', '#c21f30', '#e60000', '#d11a2d', '#cf4813', '#f04a3a', '#d2568c', '#ec2b24', '#eb507e', '#e16c96', '#eb261a']

let s:size = {
            \0:{'width': 12, 'height': 6},
            \1:{'width': 14, 'height': 7},
            \2:{'width': 16, 'height': 8},
            \3:{'width': 20, 'height': 10},
            \}

function! s:popup_filter(winid, key)
    if a:key == 'z'
        call popup_close(a:winid)
    elseif a:key == 'q'
        call popup_clear()
    endif
endfunction

function! s:get_start_list(total, num)
    let res = []
    let per = a:total / a:num
    for x in range(1, a:num)
        if x == 1
            call add(res, [1, per])
        elseif x == a:num
            call add(res, [(x-1) * per, a:total])
        else
            call add(res, [(x-1)*per, x * per])
        endif
    endfor
    return res
endfunction

function! s:get_industry_to_tile(size_index, industry)
    let size_index = a:size_index
    let industry = a:industry
    if len(industry[0]) == 0 && len(industry[3]) == 0 && len(industry[2]) == 0 && len(industry[1]) == 0
        return {'name': '', 'up_down': 0}
    endif
    if len(industry[size_index]) > 0
        let index = float2nr(stock#random() * len(industry[size_index]))
        let item = industry[size_index][index]
        call remove(industry[size_index], index)
        return item
    endif
    if size_index == 0
        return s:get_industry_to_tile(3, industry)
    else
        return s:get_industry_to_tile(size_index -1, industry)
    endif
endfunction

function! s:tile_stock_industry(...)
    let disappear = 0
    if len(a:000) == 1
        let disappear = a:000[0] + 0
    endif
    let total_columns = &columns + 1
    let total_lines = &lines + 1
    let x_list = s:get_start_list(total_columns, g:stock_width_split_num)
    let y_list = s:get_start_list(total_lines, g:stock_height_split_num)
    let sub = {}
    let industry = s:get_industry()
    let total_industry = industry['total_num']
    let up_num = industry['up_num']
    let down_num = industry['down_num']
    let max_up = industry['max_up']
    let max_down = industry['max_down']
    let extra_color = '#e60000'
    if down_num > up_num
        let extra_color = '#61ac85'
    endif
    let industry = industry['industry']
    let gap_num = 0
    call popup_clear()
    for y in range(g:stock_height_split_num)
        let y_border = y_list[y]
        for x in range(g:stock_width_split_num)
            let x_border = x_list[x]
            let start_x = x_border[0]
            let start_y = y_border[0]
            let size_index = float2nr(stock#random() * 4)
            let size = s:size[size_index]
            let height = size['height']
            let width = size['width']
            while start_y < y_border[1]
                while start_x < x_border[1]
                    if x_border[1] - start_x < size['width'] && x < (g:stock_width_split_num -1)
                        if !has_key(sub, x.y)
                            let x_list[x+1][0] = x_list[x+1][0] - (x_border[1]-start_x)
                            let sub[x.y] = 0
                        endif
                    else
                        let sub_x = x_border[1] - start_x
                        let width = min([size['width'], sub_x])
                        if x == (g:stock_width_split_num -1) && sub_x > size['width'] && sub_x < 10 + size['width']
                            let width = sub_x
                        endif
                        let sub_y = y_border[1]-start_y
                        let height = min([size['height'], sub_y])
                        if sub_y > size['height'] && sub_y < 3 + size['height']
                            let height = sub_y
                        endif
                        let item = s:get_industry_to_tile(size_index, industry)
                        let industry_name = item['name']
                        let up_down = item['up_down']
                        if up_down >= 0
                            let color = s:red[float2nr(stock#random() * 11)]
                            let up_down = '+'.up_down.'%'
                        else
                            let color = s:green[float2nr(stock#random() * 11)]
                            let up_down = '-'.up_down.'%'
                        endif
                        if len(item['name']) == 0
                            if gap_num == 0
                                let color = extra_color
                                let up_down = '下跌 ↓ '.down_num
                                let industry_name = '上涨 ↑ '.up_num
                            elseif gap_num == 1
                                let color = '#fca104'
                                let industry_name = '+'.max_up['up_down'].'%'
                                let up_down = '★'.max_up['name'].'☆'
                            elseif gap_num == 2
                                let color = '#223e36'
                                let industry_name = '-'.max_down['up_down'].'%'
                                let up_down = '☆'.max_down['name'].'★'
                                let industry = s:get_industry()['industry']
                            endif
                            let gap_num += 1
                        endif
                        call s:_show_color(color, start_y, start_x, width, height, disappear, industry_name, up_down)
                    endif
                    let start_x = start_x + width
                endwhile
                let start_x = x_border[0]
                let start_y = start_y + height
            endwhile
        endfor
        let x_list = s:get_start_list(total_columns, g:stock_width_split_num)
    endfor
endfunction

function! s:get_blank(ss, width)
    let occupied_width = strdisplaywidth(a:ss)
    let blank = ''
    if (a:width - occupied_width) / 2 > 0
        for x in range((a:width - occupied_width) / 2)
            let blank = blank.' '
        endfor
    endif
    return blank
endfunction

function! s:_show_color(color, line, column, width, height, disappear, industry_name, up_down)
    if !s:has_popup
        echoerr "don't support popup"
        return
    endif
    let color = a:color
    if (color-1) >= 0 && len(color) == 6 && match(color, '#') == -1
        let color = '#'.color
    endif
    let options = {'highlight': 'ColorHi'.substitute(a:color, '#', '', ''), 'filter': function('s:popup_filter'), 'minwidth': a:width, 'minheight': a:height}
    if a:line != -1
        let options['line'] = a:line
        let options['col'] = a:column
        if a:disappear
            let options['time'] = float2nr(stock#random() * 6666)
        endif
    else
        call popup_clear()
    endif
    let winid = popup_create('', options)
    let winbuf = winbufnr(winid)
    if a:height / 2 > 1
        for l in range(1, a:height / 2 - 1)
            call setbufline(winbuf, l, '')
        endfor
    endif
    if strdisplaywidth(a:industry_name) <= a:width
        call setbufline(winbuf, a:height / 2, s:get_blank(a:industry_name, a:width).a:industry_name)
    endif
    if strdisplaywidth(a:up_down) <= a:width
        call setbufline(winbuf, a:height / 2 + 1, s:get_blank(a:up_down, a:width).a:up_down)
    endif
    call setbufvar(winid, '&termguicolors', 1)
    call setbufvar(winid, '&t_Co', 256)
    let guifg='#d8e3e7'
    if match(color, '#') != -1
        if eval(substitute(color, '#', '0x', '')) > (0xffffff / 2)
            let guifg = '#161823'
        endif
    endif
    silent execute 'highlight ColorHi'.substitute(a:color, '#', '', '').'  guifg='.guifg.' guibg='.color
endfunction

command! -nargs=* Ca call <SID>tile_stock_industry(<f-args>)
