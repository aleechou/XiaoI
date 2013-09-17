http = require 'http'
querystring = require 'querystring'
robotsig = require './robotsig.js'

parseCookies = (cookies) ->
    ret = {}
    for c in cookies
        if r=/^(.*?)=(.*);Path=./.exec(c)
            ret[r[1]] = r[2]
    ret

exports.connect = (cb) ->

    req = http.get
        hostname: 'i.xiaoi.com'
        path: "/robot/webrobot?data=%7B%22type%22%3A%22open%22%7D&callback=__webrobot__processOpenResponse&ts=#{(new Date).getTime()}"
        headers:
            Cookie:"XISESSIONID=16rsnjb3c6qmb1xy8lg89nkzt4"

        , (res)->
            content = ''
            res.on 'data', (chunk) ->
                content+= chunk
            res.on 'end', ->
                cookies = parseCookies res.headers['set-cookie']

                try
                    __webrobot__processOpenResponse = (rspn)->
                        client =  new exports.XiaoI rspn.sessionId, rspn.userId
                        client.nonce = cookies.nonce
                        cb null, client
                    eval content
                catch error
                    cb error

    req.on 'err', (err)->
        cb err


exports.XiaoI = class
    robotid: 'webbot'
    httpUserAgent: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.65'
    constructor: (@sessionid,@uid) ->
    send: (sentence,cb) ->
        data =
            "sessionId":@sessionid
            "robotId":@robotid
            "userId":@uid
            "body":
                "content": sentence
            "type":"txt"

        url = "http://i.xiaoi.com/robot/webrobot?callback=__webrobot_processMsg&data=#{querystring.escape JSON.stringify data}&ts=#{(new Date).getTime()}" ;

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
                "Cookie":"cnonce=#{cookies.cnonce}; sig=#{cookies.sig}; nonce=#{@nonce} ; XISESSIONID=16rsnjb3c6qmb1xy8lg89nkzt4"
            , (res) =>

                c = ''
                res.on 'data', (chunk)->
                    c+= chunk
                res.on 'end', ()=>

                    # 记录 nonce
                    if res.headers['set-cookie']
                        cookies = parseCookies res.headers['set-cookie']
                        if cookies.nonce
                            @nonce = cookies.nonce

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

###
http://i.xiaoi.com/robot/webrobot?&callback=__webrobot_processMsg&data=%7B%22sessionId%22%3A%224832053f457f49edb6205fe349450125%22%2C%22robotId%22%3A%22webbot%22%2C%22userId%22%3A%227ae8c1efdd504ebf986beb7861be31fb%22%2C%22body%22%3A%7B%22content%22%3A%22hi%22%7D%2C%22type%22%3A%22txt%22%7D&ts=1379321261487

http://i.xiaoi.com/robot/webrobot?callback=__webrobot_processMsg&data=%7B%22sessionId%22%3A%227d62647688c5401cb9d32906abc65022%22%2C%22robotId%22%3A%22webbot%22%2C%22userId%22%3A%224288d24db7854570979fc5f4a5dcd517%22%2C%22body%22%3A%7B%22content%22%3A%22hi%5Cn%22%7D%2C%22type%22%3A%22txt%22%7D&ts=1379322664909

%7B%22sessionId%22%3A%224832053f457f49edb6205fe349450125%22%2C%22robotId%22%3A%22webbot%22%2C%22userId%22%3A%227ae8c1efdd504ebf986beb7861be31fb%22%2C%22body%22%3A%7B%22content%22%3A%22hi%22%7D%2C%22type%22%3A%22txt%22%7D
%7B%22sessionId%22%3A%227d62647688c5401cb9d32906abc65022%22%2C%22robotId%22%3A%22webbot%22%2C%22userId%22%3A%224288d24db7854570979fc5f4a5dcd517%22%2C%22body%22%3A%7B%22content%22%3A%22hi%5Cn%22%7D%2C%22type%22%3A%22txt%22%7D


###
