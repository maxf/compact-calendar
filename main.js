import Calendar from './calendar';
import $ from './jquery';

$(document).ready(function() {
  'use strict';

  var cal = new Calendar();

  $('#calendar').html(cal.toHtml());
  cal.setEventListeners();


});
