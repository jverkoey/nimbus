/**
 * Welcome to janky-town. This code is messy as shit.
 */

var GitHubAPI = {};

GitHubAPI.Repo = function(username, reponame, callback) {
  requestURL = "https://api.github.com/repos/"+username+"/"+reponame+'?callback=?';
  $.getJSON(requestURL, function(json, status){
    callback(json.data, status);
  });
};
GitHubAPI.RepoEvents = function(username, reponame, callback) {
  requestURL = "https://api.github.com/repos/"+username+"/"+reponame+"/events?callback=?";
  $.getJSON(requestURL, function(json, status){
    callback(json.data, status);
  });
};
GitHubAPI.RepoIssues = function(username, reponame, labels, callback) {
  requestURL = "https://api.github.com/repos/"+username+"/"+reponame+'/issues?labels='+labels+'&callback=?';
  $.getJSON(requestURL, function(json, status){
    callback(json.data, status);
  });
};
function normalizeDate(date) {
  var relative_to = new Date();
  var delta = parseInt((relative_to.getTime() - date.getTime()) / 1000);

  var out = '';
  if (delta < 60) {
    out = 'a minute ago';
  } else if(delta < 120) {
    out = 'couple of minutes ago';
  } else if(delta < (45*60)) {
    out = (parseInt(delta / 60)).toString() + ' minutes ago';
  } else if(delta < (90*60)) {
    out = 'an hour ago';
  } else if(delta < (24*60*60)) {
    out = '' + (parseInt(delta / 3600 + 0.5)).toString() + ' hours ago';
  } else if(delta < (48*60*60)) {
    out = '1 day ago';
  } else {
    out = (parseInt(delta / 86400)).toString() + ' days ago';
  }

  return out;
}

function fetchIssues(feature, element, type, typename) {
  var labels = type+',['+feature+']';
  element.attr('href', 'http://github.com/jverkoey/nimbus/issues?labels='+labels);
  GitHubAPI.RepoIssues('jverkoey', 'nimbus', labels, function(json, status) {
    if (json) {
      var text = json.length;
      if (json.length == 0) {
        text = 'No '+typename+'s'
      } else if (json.length == 1) {
        text = text + ' ' + typename;
      } else {
        text = text + ' ' + typename + 's';
      }
      element.html(text);
      if (type == 'bug') {
        if (json.length == 0) {
          element.addClass('no-issues');
        } else if (json.length < 3) {
          element.addClass('few-issues');
        } else {
          element.addClass('many-issues');
        }
      }
    }
  });
}

$(document).ready(function(){
  var element = $('#github');
  if (element && element.length > 0) {
    // Move the node higher in the page.
    element.remove();
    $('#doc-content .header').prepend(element);
    var bugs = $('<a class="issues">');
    var features = $('<a class="issues">');
    var updatingText = 'Updating...';
    bugs.html(updatingText);
    features.html(updatingText);

    element.append(bugs).append(features);

    fetchIssues(element.attr('feature'), bugs, 'bug', 'bug');
    fetchIssues(element.attr('feature'), features, 'feature', 'feature request');
  }
});