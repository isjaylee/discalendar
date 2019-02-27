import { FETCH_TITLE }     from '../../actions/Calendar';

export default (state = {}, action) => {
  switch (action.type) {
    case 'FETCH_CALENDARS':
      return action.payload;
    default:
      return state;
  }
};