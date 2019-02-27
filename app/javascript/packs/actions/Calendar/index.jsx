import calendarApi from '../../apis/Calendars';

export const FETCH_CALENDARS = 'FETCH_CALENDARS';

export const fetchCalendars = () => async dispatch => {
  const url = '/calendars.json';
  const response = await calendarApi.get(url);

  dispatch({ type: 'FETCH_CALENDARS', payload: response.data });
}
