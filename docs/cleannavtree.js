// Make the "Modules" section the root section.
NAVTREE[0][2] = NAVTREE[0][2][0][2];

// Remove the Nimbus prefix before every feature.
for (var i = 0; i < NAVTREE[0][2].length; ++i) {
  var name = NAVTREE[0][2][i][0];
  if (name.indexOf('Nimbus ') == 0) {
    NAVTREE[0][2][i][0] = name.substr('Nimbus '.length);
  }
}