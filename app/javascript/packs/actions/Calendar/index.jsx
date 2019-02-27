import calendarApi from '../../apis/Calendars';

export const FETCH_CALENDARS = 'FETCH_CALENDARS';

// export function fetchCalendars() {
//   const url = '/calendars.json';
//   const request = calendarApi.get(url);

//   return {
//     type: FETCH_CALENDARS,
//     payload: request
//   };
// }

export const fetchCalendars = () => async dispatch => {
  const url = '/calendars.json';
  const response = await calendarApi.get(url);

  dispatch({ type: 'FETCH_CALENDARS', payload: response.data.data });
}


// async dispatch => {
//   const url = '/calendars.json';
//   const response = await calendarApi.get(url);

//   dispatch({ type: 'FETCH_CALENDARS', payload: response.data });
// };