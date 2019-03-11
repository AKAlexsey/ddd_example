// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"


/**
 * Is adding 'click' event for some TD elements of the main view table (with data)
 * Such 'td' element must have properties:
 * - class="clickable"
 * - data-click-path="/some/url/when/click"
 */

var tdElements = document.getElementsByClassName('clickable');
for(var i = 0; i < tdElements.length; i++) {
  tdElements[i].addEventListener('click', function(mEvent) {
    window.location.href = mEvent.currentTarget.dataset.clickPath
  })
}





