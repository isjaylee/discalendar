'use strict';

/* eslint-disable require-jsdoc */
/* eslint-env jquery */
/* global moment, tui, chance */
/* global findCalendar, CalendarList, ScheduleList, generateSchedule */

(function(window, Calendar) {
  getCalendars();
  var cal, resizeThrottled;
  var useCreationPopup = true;
  var useDetailPopup = true;
  var datePicker, selectedCalendar;
  cal = new Calendar('#calendar', {
    defaultView: 'month',
    taskView: false,
    useCreationPopup: false,
    useDetailPopup: true,
    isReadOnly: true,
    calendars: CalendarList,
    template: {
      time: function(schedule) {
        return getTimeTemplate(schedule, false);
      }
    }
  });

  // event handlers
  cal.on({
    'createSchedules': function(e){
      console.log('FDFD');
    },
    'clickMore': function(e) {
      console.log('clickMore', e);
    },
    'clickSchedule': function(e) {
      console.log('clickSchedule', e);
    },
    'clickDayname': function(date) {
      console.log('clickDayname', date);
    },
    'beforeCreateSchedule': function(e) {
      console.log('beforeCreateSchedule', e);
      e.guide.clearGuideElement();
  // saveNewSchedule(e);
  },
  'beforeUpdateSchedule': function(e) {
    console.log('beforeUpdateSchedule', e);
    e.schedule.start = e.start;
    e.schedule.end = e.end;
    cal.updateSchedule(e.schedule.id, e.schedule.calendarId, e.schedule);
  },
  'beforeDeleteSchedule': function(e) {
    console.log('beforeDeleteSchedule', e);
    cal.deleteSchedule(e.schedule.id, e.schedule.calendarId);
  },
  'afterRenderSchedule': function(e) {
    var schedule = e.schedule;
  // var element = cal.getElement(schedule.id, schedule.calendarId);
  // console.log('afterRenderSchedule', element);
  },
  'clickTimezonesCollapseBtn': function(timezonesCollapsed) {
    console.log('timezonesCollapsed', timezonesCollapsed);

    if (timezonesCollapsed) {
      cal.setTheme({
        'week.daygridLeft.width': '77px',
        'week.timegridLeft.width': '77px'
      });
    } else {
      cal.setTheme({
        'week.daygridLeft.width': '60px',
        'week.timegridLeft.width': '60px'
      });
    }

    return true;
  }
  });

  document.getElementById('calendar').addEventListener('keydown', e => {
      console.log('keydown', e);
  });

  /**
   * Get time template for time and all-day
   * @param {Schedule} schedule - schedule
   * @param {boolean} isAllDay - isAllDay or hasMultiDates
   * @returns {string}
   */
  function getTimeTemplate(schedule, isAllDay) {
      var html = [];
      var start = moment(schedule.start.toUTCString());
      if (!isAllDay) {
          html.push('<strong>' + start.format('HH:mm') + '</strong> ');
      }
      if (schedule.isPrivate) {
          html.push('<span class="calendar-font-icon ic-lock-b"></span>');
          html.push(' Private');
      } else {
          if (schedule.isReadOnly) {
              html.push('<span class="calendar-font-icon ic-readonly-b"></span>');
          } else if (schedule.recurrenceRule) {
              html.push('<span class="calendar-font-icon ic-repeat-b"></span>');
          } else if (schedule.attendees.length) {
              html.push('<span class="calendar-font-icon ic-user-b"></span>');
          } else if (schedule.location) {
              html.push('<span class="calendar-font-icon ic-location-b"></span>');
          }
          html.push(' ' + schedule.title);
      }

      return html.join('');
  }

  /**
   * A listener for click the menu
   * @param {Event} e - click event
   */
  function onClickMenu(e) {
      var target = $(e.target).closest('a[role="menuitem"]')[0];
      var action = getDataAction(target);
      var options = cal.getOptions();
      var viewName = '';

      console.log(target);
      console.log(action);
      switch (action) {
          case 'toggle-daily':
              viewName = 'day';
              break;
          case 'toggle-weekly':
              viewName = 'week';
              break;
          case 'toggle-monthly':
              options.month.visibleWeeksCount = 0;
              viewName = 'month';
              break;
          case 'toggle-weeks2':
              options.month.visibleWeeksCount = 2;
              viewName = 'month';
              break;
          case 'toggle-weeks3':
              options.month.visibleWeeksCount = 3;
              viewName = 'month';
              break;
          case 'toggle-narrow-weekend':
              options.month.narrowWeekend = !options.month.narrowWeekend;
              options.week.narrowWeekend = !options.week.narrowWeekend;
              viewName = cal.getViewName();

              target.querySelector('input').checked = options.month.narrowWeekend;
              break;
          case 'toggle-start-day-1':
              options.month.startDayOfWeek = options.month.startDayOfWeek ? 0 : 1;
              options.week.startDayOfWeek = options.week.startDayOfWeek ? 0 : 1;
              viewName = cal.getViewName();

              target.querySelector('input').checked = options.month.startDayOfWeek;
              break;
          case 'toggle-workweek':
              options.month.workweek = !options.month.workweek;
              options.week.workweek = !options.week.workweek;
              viewName = cal.getViewName();

              target.querySelector('input').checked = !options.month.workweek;
              break;
          default:
              break;
      }

      cal.setOptions(options, true);
      cal.changeView(viewName, true);

      setDropdownCalendarType();
      setRenderRangeText();
      setSchedules();
  }

  function onClickNavi(e) {
      var action = getDataAction(e.target);

      switch (action) {
          case 'move-prev':
              cal.prev();
              break;
          case 'move-next':
              cal.next();
              break;
          case 'move-today':
              cal.today();
              break;
          default:
              return;
      }

      setRenderRangeText();
      setSchedules();
  }

  function onNewSchedule() {
      var title = $('#new-schedule-title').val();
      var location = $('#new-schedule-location').val();
      var isAllDay = document.getElementById('new-schedule-allday').checked;
      var start = datePicker.getStartDate();
      var end = datePicker.getEndDate();
      var calendar = selectedCalendar ? selectedCalendar : CalendarList[0];

      if (!title) {
          return;
      }

      cal.createSchedules([{
          id: String(chance.guid()),
          calendarId: calendar.id,
          title: title,
          isAllDay: isAllDay,
          start: start,
          end: end,
          category: isAllDay ? 'allday' : 'time',
          dueDateClass: '',
          color: calendar.color,
          bgColor: calendar.bgColor,
          dragBgColor: calendar.bgColor,
          borderColor: calendar.borderColor,
          raw: {
              location: location
          },
          state: 'Busy'
      }]);

      $('#modal-new-schedule').modal('hide');
  }

  function onChangeCalendars(e) {
      var calendarId = e.target.value;
      var checked = e.target.checked;
      var viewAll = document.querySelector('.lnb-calendars-item input');
      var calendarElements = Array.prototype.slice.call(document.querySelectorAll('#calendarList input'));
      var allCheckedCalendars = true;

      if (calendarId === 'all') {
          allCheckedCalendars = checked;

          calendarElements.forEach(function(input) {
              var span = input.parentNode;
              input.checked = checked;
              span.style.backgroundColor = checked ? span.style.borderColor : 'transparent';
          });

          CalendarList.forEach(function(calendar) {
              calendar.checked = checked;
          });
      } else {
          findCalendar(calendarId).checked = checked;

          allCheckedCalendars = calendarElements.every(function(input) {
              return input.checked;
          });

          if (allCheckedCalendars) {
              viewAll.checked = true;
          } else {
              viewAll.checked = false;
          }
      }

      refreshScheduleVisibility();
  }

  function refreshScheduleVisibility() {
      var calendarElements = Array.prototype.slice.call(document.querySelectorAll('#calendarList input'));

      CalendarList.forEach(function(calendar) {
          cal.toggleSchedules(calendar.id, !calendar.checked, false);
      });

      cal.render(true);

      calendarElements.forEach(function(input) {
          var span = input.nextElementSibling;
          span.style.backgroundColor = input.checked ? span.style.borderColor : 'transparent';
      });
  }

  function setDropdownCalendarType() {
      var calendarTypeName = document.getElementById('calendarTypeName');
      var calendarTypeIcon = document.getElementById('calendarTypeIcon');
      var options = cal.getOptions();
      var type = cal.getViewName();
      var iconClassName;

      if (type === 'day') {
          type = 'Daily';
          iconClassName = 'calendar-icon ic_view_day';
      } else if (type === 'week') {
          type = 'Weekly';
          iconClassName = 'calendar-icon ic_view_week';
      } else if (options.month.visibleWeeksCount === 2) {
          type = '2 weeks';
          iconClassName = 'calendar-icon ic_view_week';
      } else if (options.month.visibleWeeksCount === 3) {
          type = '3 weeks';
          iconClassName = 'calendar-icon ic_view_week';
      } else {
          type = 'Monthly';
          iconClassName = 'calendar-icon ic_view_month';
      }

      calendarTypeName.innerHTML = type;
      calendarTypeIcon.className = iconClassName;
  }

  function setRenderRangeText() {
    var renderRange = document.getElementById('renderRange');
    var options = cal.getOptions();
    var viewName = cal.getViewName();
    var html = [];
    if (viewName === 'day') {
      html.push(moment(cal.getDate().getTime()).format('MMMM DD, YYYY'));
    } else if (viewName === 'month' &&
      (!options.month.visibleWeeksCount || options.month.visibleWeeksCount > 4)) {
      html.push(moment(cal.getDate().getTime()).format('MMMM YYYY'));
    } else {
      html.push(moment(cal.getDateRangeStart().getTime()).format('MMMM DD, YYYY'));
      html.push(' - ');
      html.push(moment(cal.getDateRangeEnd().getTime()).format(' MMMM DD, YYYY'));
    }
    renderRange.innerHTML = html.join('');
  }

  function setSchedules() {
    cal.clear();
    // generateSchedule(cal.getViewName(), cal.getDateRangeStart(), cal.getDateRangeEnd());
    CalendarList.forEach(function(calendar) {
      var schedules = calendar.events.map(function (event) {
        var attributes = event.data.attributes;
        console.log(attributes.starting);

        var data = {
          id: attributes.id,
          calendarId: calendar.id,
          title: attributes.name,
          isAllDay: false,
          start: attributes.starting,
          end: attributes.ending,
          goingDuration: 30,
          comingDuration: 30,
          color: '#ffffff',
          isVisible: true,
          bgColor: '#69BB2D',
          dragBgColor: '#69BB2D',
          borderColor: '#69BB2D',
          category: 'time',
          dueDateClass: '',
          customStyle: 'cursor: default;',
          isPending: false,
          isFocused: false,
          isPrivate: false,
          location: attributes.location,
          attendees: getParticipants(attributes.participants)
        }
        return {...event, ...data};
      });

      cal.createSchedules(schedules);
      refreshScheduleVisibility();
    });
  }

  function getParticipants(participants) {
    var event_participants = participants.map(function(participant) {
      return participant.data.attributes.user.data.attributes.username;
    });

    return event_participants;
  }

  function setEventListener() {
      $('#menu-navi').on('click', onClickNavi);
      $('.dropdown-menu a[role="menuitem"]').on('click', onClickMenu);
      $('#lnb-calendars').on('change', onChangeCalendars);

      window.addEventListener('resize', resizeThrottled);
  }

  function getDataAction(target) {
      return target.dataset ? target.dataset.action : target.getAttribute('data-action');
  }

  resizeThrottled = tui.util.throttle(function() {
      cal.render();
  }, 50);

  window.cal = cal;

  setDropdownCalendarType();
  setRenderRangeText();
  setEventListener();
  setSchedules();
})(window, tui.Calendar);

// set calendars
(function() {
  var calendarList = document.getElementById('calendarList');
  var html = [];
  CalendarList.forEach(function(calendar) {
      html.push('<div class="lnb-calendars-item"><label>' +
          '<input type="checkbox" class="tui-full-calendar-checkbox-round" value="' + calendar.id + '" checked>' +
          '<span style="border-color: ' + calendar.borderColor + '; background-color: ' + calendar.borderColor + ';"></span>' +
          '<span>' + calendar.name + '</span>' +
          '</label></div>'
      );
  });
  calendarList.innerHTML = html.join('\n');
})();
