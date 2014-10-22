//Generate garbage
var a = [];
for(var i = 0; i < 1000000; i++) {
  a.push({i: i});
}

setTimeout(function() {
  console.timeStamp('testStart');
  console.timeStamp('testEnd');
}, 100);
