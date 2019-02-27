import React from 'react';
import { connect } from 'react-redux';
import { bindActionCreators }     from 'redux';
import { fetchCalendars } from '../../actions/Calendar';
import dateFns from 'date-fns';
import Cell from './cell';
import _ from 'lodash';

import Header from '../Calendar/Header';

class Calendar extends React.Component {
  constructor(props) {
    super(props);
    this.days = [];
  }

  state = {
    currentMonth: new Date(),
    selectedDate: new Date()
  };

  componentDidMount() {
    this.props.fetchCalendars()
  }

  // componentDidUpdate() {
  //   this.props.calendars.forEach((calendar) => {
  //     calendar.attributes.events.forEach((event) => {
  //       let eventDay = new Date(event.data.attributes.starting)
  //       let abc = _.filter(this.days, function(day){
  //         if (day !== null ) {
  //           console.log(dateFns.isSameDay(eventDay, day.props.day));
  //         }
  //         let cellDay = new Date(day.props.day)
  //         return dateFns.isSameDay(eventDay, cellDay)
  //         return item.category.parent === 'Food';
  //       });
  //     });
  //   });
  // }

  renderDays() {
    const dateFormat = "dddd";
    const days = [];

    let startDate = dateFns.startOfWeek(this.state.currentMonth);

    for (let i = 0; i < 7; i++) {
      days.push(
        <div className="col col-center" key={i}>
          {dateFns.format(dateFns.addDays(startDate, i), dateFormat)}
        </div>
      );
    }

    return <div className="days row">{days}</div>;
  }

  renderCells() {
    const { currentMonth, selectedDate } = this.state;
    const monthStart = dateFns.startOfMonth(currentMonth);
    const monthEnd = dateFns.endOfMonth(monthStart);
    const startDate = dateFns.startOfWeek(monthStart);
    const endDate = dateFns.endOfWeek(monthEnd);

    const dateFormat = "D";
    const rows = [];

    let days = [];
    let day = startDate;
    let formattedDate = "";

    while (day <= endDate) {
      for (let i = 0; i < 7; i++) {
        formattedDate = dateFns.format(day, dateFormat);
        let dayEvents = [];
        this.props.calendars.forEach(function(calendar) {
          let calEvent = _.filter(calendar.attributes.events, function(event) {
            let eventDate = dateFns.format(event.data.attributes.starting, "M D YY");
            let cellDate = dateFns.format(day, "M D YY");
            return eventDate === cellDate;
          });
          dayEvents.push(calEvent);
        });

        days.push(
          <Cell
            ref={(day) => { this.days.push(day) }}
            disabled={!dateFns.isSameMonth(day, monthStart) ? "disabled" : dateFns.isSameDay(day, selectedDate) ? "selected" : ""}
            key={day}
            formattedDate={formattedDate}
            day={day}
            events={dayEvents.flat()}
            clickDay={this.onDateClick}
          />
        );
        day = dateFns.addDays(day, 1);
      }

      rows.push(
        <div className="row" key={day}>
          {days}
        </div>
      );
      days = [];
    }
    return <div className="body">{rows}</div>;
  }

  onDateClick = day => {
    this.setState({
      selectedDate: day
    });
  };

  setMonth = (month) => {
    this.setState({
      currentMonth: month
    });
  };

  render() {
    return (
      <div>
        <div className="sidebar">
          <div className="sidebar-header">
            <p>Calendars</p>
          </div>
          <ul>
          {this.props.calendars.map((calendar) => {
            return(
              <li key={calendar.id}>
                {calendar.attributes.name}
              </li>
            )
          })}
          </ul>
        </div>
        <div className="calendar">
          <Header
            currentMonth={this.state.currentMonth}
            setMonth={this.setMonth}
          />
          {this.renderDays()}
          {this.renderCells()}
        </div>
      </div>
    );
  }
}

const mapStateToProps = state => {
  return { calendars: state.calendar };
};

const mapDispatchToProps = dispatch => bindActionCreators(
  { fetchCalendars },
  dispatch
);

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Calendar);