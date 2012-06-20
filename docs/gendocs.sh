doxygen docs/Doxyfile

TEMP="$(mktemp /tmp/output.XXXXXXXXXX)"
grep -v "Main Page" docs/output/html/navtree.js | grep -v "Class Index" | grep -v "Class Members" > $TEMP
mv $TEMP docs/output/html/navtree.js