import Constants from "../constants"

const initialState = {
    deletingFile: {},
    uploadingFile: false
}

const files = (state = initialState, action) => {
    switch (action.type) {
    case Constants.FILE_START_DELETE:
        return {
            ...state,
            deletingFile: action.payload
        }

    case Constants.FILE_START_UPLOAD:
        return {
            ...state,
            uploadingFile: true
        }

    case Constants.FILE_RESET_STATUS:
        return {
            initialState
        }

    default:
        return state
    }
}

export default files