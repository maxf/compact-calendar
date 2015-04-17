import CalendarDate from './calendarDate';
import StorageSync from './storageSync';

export default class Calendar {

  constructor(year = new Date().getFullYear()) {
    this.year = year;
    this.months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    this.daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    this.markedDays = Calendar.fetchFromLocalStorage('markedDays');
    this.weekNotes =  Calendar.fetchFromLocalStorage('weekNotes');

    new StorageSync(10); // first sync should happen before any interaction. Need a "loading" indicator and synchronous loading.
  }

  setEventListeners() {
    $('td.day').on('click', event => {
      const target = $(event.target);
      target.toggleClass('marked');
      if (target.hasClass('marked')) {
        this.markedDays[target.attr('id')] = true;
      } else {
        delete this.markedDays[target.attr('id')];
      }
      window.localStorage.setItem('markedDays', JSON.stringify(this.markedDays));
    });

    $('input').on('change', event => {
      const weekId = $(event.target).parents('tr').attr('id');
      if (event.target.value) {
        this.weekNotes[weekId] = event.target.value;
      } else {
        delete this.weekNotes[weekId];
      }
      window.localStorage.setItem('weekNotes', JSON.stringify(this.weekNotes));
    });

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
        let dayClasses="day";
        const id = 'day-' + day.getTime();
        if (this.markedDays[id]) { dayClasses += ' marked'; }
        if (classAttr) { dayClasses += ' ' + classAttr; }
        week.push(`<td id="day-${day.getTime()}" class="${dayClasses}">${date}</td>`);

        day.setToTomorrow();
      }
      const weekId = "week-"+weekNumber;
      calHtml.push(`<tr id="${weekId}"><td ${isFirstWeekInMonth?'class="newMonth"':''}>${firstColText}</td>${week.join('')}<td><input id="input${weekNumber}" type="text" value="${this.weekNotes[weekId]||''}"/></td></tr>`);
      weekNumber++;
    }

    calHtml.push('</tbody></table>');

    return calHtml.join('');
  }

  //== static ==============

  static fetchFromLocalStorage(name) {
    try {
      return JSON.parse(window.localStorage[name]);
    } catch(err) {
      return {};
    }
  }
}
