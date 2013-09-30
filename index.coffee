http = require 'http'
querystring = require 'querystring'
robotsig = require './robotsig.js'

parseCookies = (cookies) ->
    ret = {}
    return ret if not cookies
    for c in cookies
        if r=/^(.*?)=(.*);Path=./.exec(c)
            ret[r[1]] = r[2]
    ret



module.exports = class
    robotid: 'webbot'
    httpUserAgent: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.65'
    xisessionid: undefined

    constructor : ->
        # 每隔 15分钟 更新会话
        setInterval @connect.bind(this), 15*60*1000

    connect: (cb)->

        try
            req = http.get
                hostname: 'i.xiaoi.com'
                path: "/robot/webrobot?data=%7B%22type%22%3A%22open%22%7D&callback=__webrobot__processOpenResponse&ts=#{(new Date).getTime()}"

                , (res)=>
                    content = ''
                    res.on 'data', (chunk) ->
                        content+= chunk
                    res.on 'end', =>
                        cookies = parseCookies res.headers['set-cookie']
                        @nonce = cookies.nonce
                        @xisessionid = cookies.XISESSIONID

                        try
                            __webrobot__processOpenResponse = (rspn)=>
                                @sessionid = rspn.sessionId
                                @userId = rspn.userId
                                console.log 'got nonce & XISESSIONID:', @nonce, @xisessionid
                                cb null, this
                            eval content
                        catch error
                            cb error
        catch error
            cb error
            undefined

        req.on 'err', (err)->
            cb err

    keeplive: ->

        nonce = robotsig(@nonce)
        cookieline = "cnonce=#{nonce.cnonce}; sig=#{nonce.sig}; nonce=#{@nonce} ; XISESSIONID=#{@xisessionid}"
        req = http.get
            hostname: 'i.xiaoi.com'
            path: "/robot/webrobot?callback=__webrobot_processMsg&data=%7B%22type%22%3A%22keepalive%22%7D&ts=#{(new Date).getTime()}"
            headers:
                "Cookie":cookieline
            , (res) =>
                res.on 'end', =>
                    cookies = parseCookies res.headers['set-cookie']
                    if cookies.XISESSIONID
                        if @xisessionid!=cookies.XISESSIONID
                            console.log "\nxiao server change session:", @xisessionid, ' -> ', cookies.XISESSIONID, ' time:', (new Date).toISOString()
                            @xisessionid = cookies.XISESSIONID
                        else
                            process.stdout.write '-'
                    else
                        process.stdout.write '.'

        req.on 'error', (error) ->
            console.log 'keeplive', error

    send: (sentence,cb) ->
        data =
            "sessionId":@sessionid
            "robotId":@robotid
            "userId":@uid
            "body":
                "content": sentence
            "type":"txt"
        cookies = robotsig(@nonce)
        req = http.get
            hostname: 'i.xiaoi.com'
            path: "/robot/webrobot?callback=__webrobot_processMsg&data=#{querystring.escape JSON.stringify data}&ts=#{(new Date).getTime()}"
            headers:
                "User-Agent": @httpUserAgent
                Referer:"http://i.xiaoi.com/"
                Connection:"keep-alive"
                Accept:"*/*"
                "Accept-Language":"zh-CN,zh;q=0.8"
                "Cookie":"cnonce=#{cookies.cnonce}; sig=#{cookies.sig}; nonce=#{@nonce} ; XISESSIONID=#{@xisessionid}"
            , (res) =>

                c = ''
                res.on 'data', (chunk)->
                    c+= chunk
                res.on 'end', ()=>

                    # 记录 nonce
                    if res.headers['set-cookie']
                        cookies = parseCookies res.headers['set-cookie']
                        @nonce = cookies.nonce if cookies.nonce
                        if cookies.XISESSIONID
                            @xisessionid = cookies.XISESSIONID
                            console.log 'XISESSIONID has changed:', @xisessionid

                    lastrspn = null
                    __webrobot_processMsg = (rspn)->
                        return if rspn.type=='ex'
                        lastrspn = rspn
                    try
                        eval c
                        cb null, lastrspn
                    catch error
                        cb error


        req.on 'error', (err)->
            cb err
