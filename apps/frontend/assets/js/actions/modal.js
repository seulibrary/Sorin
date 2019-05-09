import Constants from "../constants"

export const openModal = (obj) => {
    return {
        type: Constants.OPEN_MODAL,
        payload: obj,
    }
}

export const closeModal = (obj) => {
    return {
        type: Constants.CLOSE_MODAL,
        payload: obj,
    }
}