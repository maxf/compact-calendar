import Calendar from './calendar';

$(() => {
  'use strict';

  const cal = new Calendar("calendar");

  $('#clear').on('click', () => {
    window.localStorage.clear();
  });


});
