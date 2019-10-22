import Constants from "../constants"

export const addSaveNotification = () => {
    return {
        type: Constants.ADD_SAVE_NOTIFICATION
    }
}

export const clearSaveNotification = () => {
    return {
        type: Constants.CLEAR_SAVE_NOTIFICATIONS
    }
}