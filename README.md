node.js 的小I机器人客户端
===

# Usage

## In command line terminate
```
npm i xiaoi -g
xiaoi
```

## In your node project

```javascript
var xiaoi = require('xiaoi') ;

// connect to xiaoi.com
xiaoi.connect(function(error,client){

    // send words and waiting for reply
    client.send("hello robot",function(error,reply){
        console.log ('xiaoi say:', replay.body.content) ;
    }) ;

}) ;
```
