import Constants from "../constants"

const initialState = {
    modals: [],
}

const modals = (state = initialState, action) => {
    switch (action.type) {
    case Constants.OPEN_MODAL:
        return {
            ...state,
            modals: state.modals.concat(action.payload)
        }
    case Constants.CLOSE_MODAL:
        return {
            ...state,
            modals: state.modals.filter(item => item.id !== action.payload.id)
        }
    default:
        return state
    }
}

export default modals