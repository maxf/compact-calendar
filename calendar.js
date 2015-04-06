import CalendarDate from './calendarDate';

export default class Calendar {

  constructor(year = new Date().getFullYear()) {
    this.year = year;
    this.months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    this.daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    this.markedDays = this._fetchFromLocalStorage('markedDays');
    for (let markedDay in this.markedDays) {
      $(`#${markedDay}`).addClass('marked');
    }
  }


  setEventListeners() {
    var _this = this;
    $('td.day').on('click', function() {
      $(this).toggleClass('marked');
      if ($(this).hasClass('marked')) {
        _this.markedDays[$(this).attr('id')] = true;
      } else {
        delete _this.markedDays[$(this).attr('id')];
      }

      window.localStorage.setItem('markedDays', JSON.stringify(_this.markedDays));
    });
  }

  _fetchFromLocalStorage(name) {
    try {
      return JSON.parse(window.localStorage[name]);
    } catch(err) {
      return {};
    }
  }

  toHtml() {
    let calHtml=['<table><thead><tr><th>Month</th>'];
    let day = new CalendarDate(this.year, 0, 1, 12); /* new year's day at midday */
    let weekNumber = 1;

    // populate header with labels for days of week
    for (let dow=0; dow<7; dow++) {
      calHtml.push(`<th>${this.daysOfWeek[dow].substr(0,2)}</th>`);
    }

    calHtml.push('</thead></tbody>');

    day = day.previousMonday();

    // iterate weeks
    while (day.getFullYear() <= this.year) {
      let date = day.getDate();
      let isFirstWeekInMonth = date===1 || date > day.nextDays(6).getDate();
      let firstColText = isFirstWeekInMonth ? this.months[day.nextWeek().getMonth()] : '';
      let week = [];

      // iterate day of this week
      for (let dow=0; dow<7; dow++) {
        let classAttr;
        date = day.getDate();
        if (isFirstWeekInMonth) {
          if (date >= 23) {
            classAttr = 'beforeFirst'; // this day is before the first day of the next month
          } else if (date === 1) {
            classAttr = 'firstDayOfMonth'; // this day is the first day of the next month
          } else {
            classAttr = 'afterFirst'; // this day is after the first day of the next month
          }
        }
        week.push(`<td id="day-${day.getTime()}" class="day ${classAttr||''}">${date}</td>`);

        day.setToTomorrow();
      }
      calHtml.push(`<tr id="week${weekNumber}"><td ${isFirstWeekInMonth?'class="newMonth"':''}>${firstColText}</td>${week.join('')}<td><input id="input${weekNumber}" type="text"/></td></tr>`);
      weekNumber++;
    }

    calHtml.push('</tbody></table>');

    return calHtml.join('');
  }

};

