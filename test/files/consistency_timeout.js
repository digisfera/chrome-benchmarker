setTimeout(function() {
  console.timeStamp('testStart');
  for(var i = 0; i < 100; i++) {
    generateGarbage();  
  }
  setTimeout(function() { console.timeStamp('testEnd'); }, 100);
}, 100);

function generateGarbage() {
  var a = [];
  for(var i = 0; i < 10000; i++) {
    a.push({i: i});
  }
}
