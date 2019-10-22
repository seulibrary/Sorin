import Constants from "../constants"

const initialState = {
    newNotification: false, // Could be used for a notification center/dashboard
    saveNotificationCount: 0,
    notifications: [], // List of all notifications that come in. (Currently not used)
}

const notifications = (state = initialState, action) => {
    switch (action.type) {
    case Constants.ADD_SAVE_NOTIFICATION:
        return {
            ...state,
            saveNotificationCount: state.saveNotificationCount + 1
        }
    case Constants.CLEAR_SAVE_NOTIFICATIONS:
        return {
            ...state,
            saveNotificationCount: 0
        }
    default:
        return state
    }
}

export default notifications
