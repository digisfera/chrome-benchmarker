// Example from https://groups.google.com/forum/#!msg/v8-users/C7nFesbzFcg/nsxJbke8xa4J
var createArray = function (length) {
  var arr = new Float64Array(length);
  for(var i = 0; i < length; ++i) {
    arr[i] = 0.1;
  }
  return arr;
};

function copy(a1, a2, length) {
  for (var i = 0; i < length; ++i) {
    a1[i] = a2[i];
  }
}
length = 10000,
arr1 = createArray(length),
arr2 = createArray(length);



setTimeout(function() {
console.timeStamp('testStart');
copy(arr1, arr2, length);
console.timeStamp('testEnd');
}, 0);
