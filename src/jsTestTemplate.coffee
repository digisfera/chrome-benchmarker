module.exports = (jsCode) ->
  """
<html><head></head>
<body>
<script type="text/javascript">
setTimeout(function() {#{jsCode}}, 0);
</script>
</body>
</html>
  """