import Constants from "../constants"

const initialState = {
    accordions: [],
}

const accordions = (state = initialState, action) => {
    switch (action.type) {
    case Constants.OPEN_ACCORDION:
        return {
            ...state,
            modals: state.accordions.concat(action.payload)
        }
    case Constants.CLOSE_ACCORDION:
        return {
            ...state,
            modals: state.accordions.filter(item => item.id !== action.payload.id)
        }
    default:
        return state
    }
}

export default accordions