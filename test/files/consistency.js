console.timeStamp('testStart');
for(var i = 0; i < 100; i++) {
  generateGarbage();  
}
console.timeStamp('testEnd');

function generateGarbage() {
  var a = [];
  for(var i = 0; i < 10000; i++) {
    a.push({i: i});
  }
}
