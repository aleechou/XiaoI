module.exports = function(nonce){
    var d = {cookie:'nonce='+nonce} ;
    return (function() {
        function n() {
            return Math.PI + "I"
        }
        function c() {
            return "no"
        }
        function h(k) {
            return g(f(p(k)))
        }
        function f(K) {
            var H = K;
            var I = Array(80);
            var G = 1732584193;
            var F = -271733879;
            var E = -1732584194;
            var D = 271733878;
            var C = -1009589776;
            for (var z = 0; z < H.length; z += 16) {
                var B = G;
                var A = F;
                var y = E;
                var v = D;
                var k = C;
                for (var u = 0; u < 80; u++) {
                    if (u < 16) {
                        I[u] = H[z + u]
                    } else {
                        I[u] = l(I[u - 3] ^ I[u - 8] ^ I[u - 14] ^ I[u - 16], 1)
                    }
                    var J = q(q(l(G, 5), s(u, F, E, D)), q(q(C, I[u]), i(u)));
                    C = D;
                    D = E;
                    E = l(F, 30);
                    F = G;
                    G = J
                }
                G = q(G, B);
                F = q(F, A);
                E = q(E, y);
                D = q(D, v);
                C = q(C, k)
            }
            return new Array(G, F, E, D, C)
        }
        function s(u, k, w, v) {
            if (u < 20) {
                return (k & w) | ((~k) & v)
            }
            if (u < 40) {
                return k ^ w ^ v
            }
            if (u < 60) {
                return (k & w) | (k & v) | (w & v)
            }
            return k ^ w ^ v
        }
        function i(k) {
            return (k < 20) ? 1518500249 : (k < 40) ? 1859775393 : (k < 60) ? -1894007588 : -899497514
        }
        function q(k, w) {
            var v = (k & 65535) + (w & 65535);
            var u = (k >> 16) + (w >> 16) + (v >> 16);
            return (u << 16) | (v & 65535)
        }
        function l(k, u) {
            return (k << u) | (k >>> (32 - u))
        }
        function p(v) {
            var k = ((v.length + 8) >> 6) + 1,
                w = new Array(k * 16);
            for (var u = 0; u < k * 16; u++) {
                w[u] = 0
            }
            for (u = 0; u < v.length; u++) {
                w[u >> 2] |= v.charCodeAt(u) << (24 - (u & 3) * 8)
            }
            w[u >> 2] |= 128 << (24 - (u & 3) * 8);
            w[k * 16 - 1] = v.length * 8;
            return w
        }
        function g(v) {
            var u = "0123456789abcdef";
            var w = "";
            for (var k = 0; k < v.length * 4; k++) {
                w += u.charAt((v[k >> 2] >> ((3 - k % 4) * 8 + 4)) & 15) + u.charAt((v[k >> 2] >> ((3 - k % 4) * 8)) & 15)
            }
            return w
        }
        function e(B) {
            var v, u, A, w = d.cookie.split(";");
            for (v = 0; v < w.length; v++) {
                var z = w[v];
                var k = z.indexOf("=");
                u = z.substr(0, k);
                A = z.substr(k + 1);
                u = u.replace(/^\s+|\s+$/g, "");
                if (u == B) {
                    return unescape(A)
                }
            }
        }
        function b() {
            return "n"
        }
        function o(u, k) {
            d.cookie = u + "=" + escape(k) + ";path=/robot/"
        }
        function a() {
            return "ce"
        }
        function j(u) {
            var w = "",
                x = n().substr(0, 7);
            for (var v = 0; v < x.length; v++) {
                var y = x.charAt(v);
                if (y != ".") {
                    w = y + w
                }
            }
            return h(u + w)
        }
        function m() {
            return c() + b() + a()
        }
        var r = e(m());
        if (r) {
            var t = "" + (Math.ceil(Math.random() * 899999) + 100000);
            return {
                sig: h(j(r) + t)
                , cnonce: t
            } ;
        }
        else
            return ;
    }) () ;
}
