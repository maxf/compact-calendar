import Calendar from './calendar';

$(() => {
  'use strict';

  var cal = new Calendar();

  $('#calendar').html(cal.toHtml());
  cal.setEventListeners();


});
