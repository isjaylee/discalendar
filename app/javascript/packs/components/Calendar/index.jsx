import React from 'react';
import { connect } from 'react-redux';
import { bindActionCreators }     from 'redux';
import { fetchCalendars } from '../../actions/Calendar';
import dateFns from 'date-fns';
import Cell from './cell';
import _ from 'lodash';
import Popup from 'react-popup';

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

  renderCalendars() {
    const calendarsList = [];
    this.props.calendars.map((calendar) => {
      calendarsList.push(
        <li key={calendar.id}>
          {calendar.attributes.name}
        </li>
      )
    });

    return calendarsList;
  }

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

  onDateClick = (day, events) => {
    if (events.length) {
      this.createPopup(day, events);
    }

    this.setState({
      selectedDate: day
    });
  };

  setMonth = (month) => {
    this.setState({
      currentMonth: month
    });
  };

  createPopup = (day, events) => {
    Popup.create({
      title: `Events on ${dateFns.format(day, 'MMMM DD, YYYY')}`,
      content: (
        <div className="event-list">
          {events.map(function(event){
            let attrs = event.data.attributes;
            let time = dateFns.format(new Date(attrs.starting), 'h:mmA');
            let participants = attrs.participants.map(function(participant){
              return participant.data.attributes.user.data.attributes.username ;
            })

            let participantList = participants.length ? participants.join(', ') : "None"

            return (
              <div key={event.data.id}>
                <p>
                  <strong>{attrs.name} at {time}</strong> - <small>{attrs.calendar.name}</small>
                  <br />
                  <small>Event ID: {attrs.discord_message_identifier}</small>
                </p>
                <p>
                  Going: {participantList}
                </p>
              </div>
            )
          })}
        </div>
      ),
      className: 'alert',
      buttons: {
        left: ['cancel']
      },
    });
  }

  render() {
    if (_.isEmpty(this.props.calendars)) {
      return(
        <div className="loading">
          Loading calendars.<br/>
          If you don't have any calendars, create or join one!
        </div>
      );
    }

    return (
      <div>
        <div className="sidebar">
          <div className="sidebar-header">
            <p>Calendars</p>
          </div>
          <ul>
            {this.renderCalendars()}
          </ul>
        </div>
        <Popup />
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
  return { calendars: state.calendars.data };
};

const mapDispatchToProps = dispatch => bindActionCreators(
  { fetchCalendars },
  dispatch
);

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Calendar);