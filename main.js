import Calendar from './calendar';

$(document).ready(function() {
  'use strict';

  var cal = new Calendar();

  $('#calendar').html(cal.toHtml());

});
