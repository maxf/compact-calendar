/*global $*/

import Calendar from './calendar';

$(() => {
  var cal = new Calendar('calendar');
  cal.draw();

  $('#clear').on('click', () => {
    window.localStorage.clear();
  });
});
