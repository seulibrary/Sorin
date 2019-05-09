import Constants from "../constants"

const initialState = {  
    currentUser: null,
    socket: null,
    channel: null,
    error: null,
    dashboardChannel: null,
    inbox_id: null
}

const session = (state = initialState, action) => {
    switch (action.type) {
    case Constants.CURRENT_USER:
        return {
            ...state,
            currentUser: action.currentUser, socket: action.socket, channel: action.channel, error: null
        }
    case Constants.SETTING_UP_DASHBOARD:
        return {
            ...state,
            dashboardChannel: action.dashboardChannel
        }
    case Constants.SET_INBOX_ID:
        return {
            ...state,
            inbox_id: action.inbox_id
        }
    case Constants.USER_SIGNED_OUT:
        return initialState
    default:
        return state
    }
}

export default session