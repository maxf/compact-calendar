class CalendarDate { // Date can't be subclassed :(
  constructor(...date) {
    this.date = new Date(...date);
  }

  setToTomorrow() { return this._addDays(1); }
  setToNextWeek() { return this._addDays(7); }
  setToYesterday() { return this._addDays(-1); }
  setToPrevWeek() { return this._addDays(-7); }
  setToNextDays(numDays) { return this._addDays(numDays); }

  nextWeek() {
    return this.clone().setToNextWeek();
  }

  nextDays(numDays) {
    return this.clone().setToNextDays(numDays);
  }

  clone() {
    return new CalendarDate(this.date);
  }

  previousMonday() {
    var newDate = this.clone();

    while (newDate.date.getDay() !== 1) {
      newDate.setToYesterday();
    }
    return newDate;
  }

  getDate() {
    return this.date.getDate();
  }

  getMonth() {
    return this.date.getMonth();
  }

  getFullYear() {
    return this.date.getFullYear();
  }

  toString() {
    return this.date.toString();
  }

  /* private */

  _addDays(numDays) {
    this.date.setTime(this.date.getTime()+numDays*24*3600*1000);
    return this;
  }
}




class Calendar {

  constructor(year = new Date().getFullYear()) {
    this.year = year;
    this.months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    this.daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  }

  toHtml() {
    let calHtml=['<table><thead><tr><th>Month</th>'];
    let day = new CalendarDate(this.year, 0, 1, 12); /* new year's day at midday */

    // populate header with labels for days of week
    for (let dow=0; dow<7; dow++) {
      calHtml.push(`<th>${this.daysOfWeek[dow].substr(0,2)}</th>`);
    }

    calHtml.push('</thead></tbody>');

    day = day.previousMonday();
    while (day.getFullYear() <= this.year) {
      let date = day.getDate();
      let isFirstWeekInMonth = date===1 || date > day.nextDays(6).getDate();
      let firstColText = isFirstWeekInMonth ? this.months[day.getMonth()] : '';
      let week = [];

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
        week.push(`<td ${classAttr?'class="'+classAttr+'"':''}>${date}</td>`);

        day.setToTomorrow();
      }
      calHtml.push(`<tr><td ${isFirstWeekInMonth?'class="newMonth"':''}>${firstColText}</td>${week.join('')}</tr>`);
    }

    calHtml.push('</tbody></table>');

    return calHtml.join('');
  }

}
