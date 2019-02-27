import 'regenerator-runtime/runtime'
import { combineReducers }        from 'redux';
import CalendarsReducer           from './Calendar';

const rootReducer = combineReducers({
  calendars: CalendarsReducer
});

export default rootReducer;
