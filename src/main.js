import Calendar from './calendar';

var $;

$(() => {

  var cal = new Calendar('calendar');
  cal.draw();

  $('#clear').on('click', () => {
    window.localStorage.clear();
  });


});
