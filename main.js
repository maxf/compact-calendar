import Calendar from './calendar.js';

$(document).ready(function() {
  'use strict';

  var cal = new Calendar();

//  console.log(cal);

  $('#calendar').html(cal.toHtml());

});
