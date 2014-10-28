#!/bin/bash
echo ""
echo "immediate.html"
../../bin/chrome-benchmarker.js immediate.html
echo ""
echo "timeout.html"
../../bin/chrome-benchmarker.js timeout.html
echo ""
echo "domcontentloaded.html"
../../bin/chrome-benchmarker.js domcontentloaded.html
echo ""
echo "both.html"
../../bin/chrome-benchmarker.js both.html