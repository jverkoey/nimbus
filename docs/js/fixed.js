var cookie_namespace = 'doxygen'; 
var sidenav,navtree,content,header;

function resizeHeight() 
{
  var headerHeight = header.height();
  var windowHeight = $(window).height() - headerHeight;
  content.css({height:windowHeight + "px"});
  navtree.css({height:windowHeight + "px"});
  sidenav.css({height:windowHeight + "px",top: headerHeight+"px"});
}

function initResizable()
{
  header  = $("#top");
  sidenav = $("#side-nav");
  content = $("#doc-content");
  navtree = $("#nav-tree");
  footer  = $("#nav-path");
  $(window).resize(function() { resizeHeight(); });
  resizeHeight();
  var url = location.href;
  var i=url.indexOf("#");
  if (i>=0) window.location.hash=url.substr(i);
}

