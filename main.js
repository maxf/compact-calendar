import Calendar from './calendar';

$(() => {
  'use strict';

  var cal = new Calendar("calendar");

//  $('#calendar').html(cal.toHtml());
  cal.setEventListeners();


});
