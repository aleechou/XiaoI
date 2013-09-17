// Generated by CoffeeScript 1.6.3
(function() {
  var http, parseCookies, querystring, robotsig;

  http = require('http');

  querystring = require('querystring');

  robotsig = require('./robotsig.js');

  parseCookies = function(cookies) {
    var c, r, ret, _i, _len;
    ret = {};
    for (_i = 0, _len = cookies.length; _i < _len; _i++) {
      c = cookies[_i];
      if (r = /^(.*?)=(.*);Path=./.exec(c)) {
        ret[r[1]] = r[2];
      }
    }
    return ret;
  };

  exports.connect = function(cb) {
    var req;
    req = http.get({
      hostname: 'i.xiaoi.com',
      path: "/robot/webrobot?data=%7B%22type%22%3A%22open%22%7D&callback=__webrobot__processOpenResponse&ts=" + ((new Date).getTime())
    }, function(res) {
      var content;
      content = '';
      res.on('data', function(chunk) {
        return content += chunk;
      });
      return res.on('end', function() {
        var cookies, error, __webrobot__processOpenResponse;
        cookies = parseCookies(res.headers['set-cookie']);
        try {
          __webrobot__processOpenResponse = function(rspn) {
            var client;
            client = new exports.XiaoI(rspn.sessionId, rspn.userId);
            client.nonce = cookies.nonce;
            client.xisessionid = cookies.XISESSIONID;
            console.log('got nonce & XISESSIONID:', client.nonce, client.xisessionid);
            return cb(null, client);
          };
          return eval(content);
        } catch (_error) {
          error = _error;
          return cb(error);
        }
      });
    });
    return req.on('err', function(err) {
      return cb(err);
    });
  };

  exports.XiaoI = (function() {
    _Class.prototype.robotid = 'webbot';

    _Class.prototype.httpUserAgent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.65';

    function _Class(sessionid, uid) {
      this.sessionid = sessionid;
      this.uid = uid;
    }

    _Class.prototype.send = function(sentence, cb) {
      var cookies, data, req,
        _this = this;
      data = {
        "sessionId": this.sessionid,
        "robotId": this.robotid,
        "userId": this.uid,
        "body": {
          "content": sentence
        },
        "type": "txt"
      };
      cookies = robotsig(this.nonce);
      req = http.get({
        hostname: 'i.xiaoi.com',
        path: "/robot/webrobot?callback=__webrobot_processMsg&data=" + (querystring.escape(JSON.stringify(data))) + "&ts=" + ((new Date).getTime()),
        headers: {
          "User-Agent": this.httpUserAgent,
          Referer: "http://i.xiaoi.com/",
          Connection: "keep-alive",
          Accept: "*/*",
          "Accept-Language": "zh-CN,zh;q=0.8",
          "Cookie": "cnonce=" + cookies.cnonce + "; sig=" + cookies.sig + "; nonce=" + this.nonce + " ; XISESSIONID=" + this.xisessionid
        }
      }, function(res) {
        var c;
        c = '';
        res.on('data', function(chunk) {
          return c += chunk;
        });
        return res.on('end', function() {
          var error, lastrspn, __webrobot_processMsg;
          if (res.headers['set-cookie']) {
            cookies = parseCookies(res.headers['set-cookie']);
            if (cookies.nonce) {
              _this.nonce = cookies.nonce;
            }
            if (cookies.XISESSIONID) {
              _this.xisessionid = cookies.XISESSIONID;
              console.log('XISESSIONID has changed:', _this.xisessionid);
            }
          }
          lastrspn = null;
          __webrobot_processMsg = function(rspn) {
            if (rspn.type === 'ex') {
              return;
            }
            return lastrspn = rspn;
          };
          try {
            eval(c);
            return cb(null, lastrspn);
          } catch (_error) {
            error = _error;
            return cb(error);
          }
        });
      });
      return req.on('error', function(err) {
        return cb(err);
      });
    };

    return _Class;

  })();

}).call(this);
