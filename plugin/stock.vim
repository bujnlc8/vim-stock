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
            call add(industry[3], {'name': item['f14'], 'up_down': item['f3'], 'stock': item['f128'], 'stock_up_down': item['f136'], 'market_value': item['f20']})
        elseif abs(item['f3']) < 2 && abs(item['f3']) >= 1
            call add(industry[2], {'name': item['f14'], 'up_down': item['f3'], 'stock': item['f128'], 'stock_up_down': item['f136'], 'market_value': item['f20']})
        elseif abs(item['f3']) < 1 && abs(item['f3']) >= 0.6
            call add(industry[1], {'name': item['f14'], 'up_down': item['f3'], 'stock': item['f128'], 'stock_up_down': item['f136'], 'market_value': item['f20']})
        else
            call add(industry[0], {'name': item['f14'], 'up_down': item['f3'], 'stock': item['f128'], 'stock_up_down': item['f136'], 'market_value': item['f20']})
        endif
    endfor
    return {'total_num': up_num + down_num, 'industry':industry, 'up_num': up_num, 'down_num': down_num, 'max_up': max_up, 'max_down': max_down}
endfunction

let s:red = ['#e597b2', '#eb507e', '#ec4e8a', '#d13c74', '#de3f7c', '#bf3553', '#ed3b2f', '#d9333f', '#c21f30', '#cc163a',  '#e60000', '#7c1823']

let s:green = ['#9eccab', '#bacf65', '#55bb8a', '#248067', '#1a6840', '#057748', '#207f4c', '#0c8918', '#5bae23', '#229453', '#00bc12', '#00e500']


function! s:get_color(up_down, all_up, all_down)
    if a:up_down == 0
        return '#2b333e'
    endif
    let up_down = float2nr(a:up_down * 100)
    let index = 0
    if up_down > 0
        for x in a:all_up
            if x == up_down
                return s:red[float2nr(index * 1.0 / len(a:all_up) * 12)]
            endif
            let index +=1
        endfor
    endif
    if up_down < 0
        for x in a:all_down
            let index += 1
            if x == up_down
                return s:green[float2nr((len(a:all_down)- index) * 1.0 / len(a:all_down) * 12)]
            endif
        endfor
    endif
endfunction

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

function! s:sort_area(left, right)
    if a:left[1] > a:right[1]
        return -1
    elseif a:left[1] == a:right[1]
        return 0
    else
        return  1
    endif
endfunction

function! s:sort_market_value(left, right)
    if a:left['market_value'] > a:right['market_value']
        return -1
    elseif a:left['market_value'] == a:right['market_value']
        return 0
    else
        return  1
    endif
endfunction

function! s:tile_stock_industry_repeatable(times)
    let index = 0
    while index < a:times + 0
        call s:tile_stock_industry()
        let index += 1
        redraw!
        15sleep
    endwhile
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
    let all_indusrty = []
    let all_down = []
    let all_up = []
    for x in range(4)
        for y in industry[x]
            call add(all_indusrty, y)
            if y['up_down'] > 0
                call add(all_up, float2nr(y['up_down'] * 100))
            elseif y['up_down'] < 0
                call add(all_down, float2nr(y['up_down'] * 100))
            endif
        endfor
    endfor
    let all_down = sort(all_down, 'f')
    let all_up = sort(all_up, 'f')
    let all_indusrty = sort(all_indusrty, function('s:sort_market_value'))
    let gap_num = 0
    call popup_clear()
    let win_area = []
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
                    let r = stock#random()
                    if r < 0.15
                        let w = -2
                    elseif 0.15 <= r && r < 0.25
                        let w = -1
                    elseif 0.25 <= r && r < 0.375
                        let w = 0
                    elseif 0.375 <= r && r < 0.5
                        let w = 1
                    elseif 0.5 <= r && r < 0.75
                        let w = 2
                    else
                        let w = 3
                    endif
                    let sub_x = x_border[1] - start_x
                    let tmp_width = min([size['width'] + w, sub_x])
                    if sub_x < tmp_width + 10
                        let tmp_width = sub_x
                    endif
                    if x_border[1] - start_x < tmp_width && x < (g:stock_width_split_num -1)
                        if !has_key(sub, x.y)
                            let x_list[x+1][0] = x_list[x+1][0] - (x_border[1]-start_x)
                            let sub[x.y] = 0
                        endif
                    else
                        let width = tmp_width
                        let sub_y = y_border[1]-start_y
                        let height = min([size['height'], sub_y])
                        if sub_y > size['height'] && sub_y < 4 + size['height']
                            let height = sub_y
                        endif
                        let item = s:get_industry_to_tile(size_index, industry)
                        let industry_name = item['name']
                        let up_down = item['up_down']
                        let color = s:get_color(up_down, all_up, all_down)
                        if up_down >= 0
                            let up_down = '+'.up_down.'%'
                        else
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
                        let winid = s:_show_color(color, start_y, start_x, width, height, disappear, industry_name, up_down)
                        if gap_num != 1 && gap_num != 2 && gap_num!=3
                            call add(win_area, [winid, width * height, width, height, start_x, start_y])
                        endif
                    endif
                    let start_x = start_x + width
                endwhile
                let start_x = x_border[0]
                let start_y = start_y + height
            endwhile
        endfor
        let x_list = s:get_start_list(total_columns, g:stock_width_split_num)
    endfor
    " 根据市值大小重新绘制
    let win_area = sort(win_area, function('s:sort_area'))
    let index = 0
    for item in all_indusrty
        let industry_name = item['name']
        let up_down = item['up_down']
        let color = s:get_color(up_down, all_up, all_down)
        if up_down >= 0
            let up_down = '+'.up_down.'%'
        else
            let up_down = '-'.up_down.'%'
        endif
        let win = win_area[index]
        call s:_show_color(color, win[5], win[4], win[2], win[3], disappear, industry_name, up_down, win[0])
        let index += 1
        if index == len(win_area)
            break
        endif
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

function! s:_show_color(color, line, column, width, height, disappear, industry_name, up_down, winid=0)
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
    let winid = a:winid
    if !winid
        let winid = popup_create('', options)
    else
        call popup_close(winid)
        let winid = popup_create('', options)
    endif
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
    return winid
endfunction

command! -nargs=* Ca call <SID>tile_stock_industry(<f-args>)
command! -nargs=1 Car call <SID>tile_stock_industry_repeatable(<f-args>)
